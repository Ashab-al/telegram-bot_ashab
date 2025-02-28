# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Pagy::Backend

  IGNORED_FOR_USER_AND_SUBSCRIBED_CATEGORIES=[:send_category, :message]

  CHAT_TYPE = "private"
  
  before_action :find_or_create_user_and_send_analytics, except: IGNORED_FOR_USER_AND_SUBSCRIBED_CATEGORIES
  before_action :subscribed_categories, except: IGNORED_FOR_USER_AND_SUBSCRIBED_CATEGORIES

  rescue_from Exception, with: :send_error_in_admin_group
  # bin/rake telegram:bot:poller   запуск бота

  # chat - выдает такие данные
  # {"id":3778846691,"first_name":"Асхаб Алхазуров | Чат-боты | Python | Ruby",
  # "username":"AshabAl","type":"private"}

  # from - выдает такие данные
  # {"id":3778846691,"is_bot":false,
  # "first_name":"Асхаб Алхазуров | Чат-боты | Python | Ruby",
  # "username":"AshabAl","language_code":"ru","is_premium":true}

  # payload - выдает такие данные
  # {"message_id":335409,"from":{"id":3778846691,"is_bot":false,
  # "first_name":"Асхаб Алхазуров | Чат-боты | Python | Ruby",
  # "username":"AshabAl","language_code":"ru","is_premium":true},
  # "chat":{"id":3778846691,
  # "first_name":"Асхаб Алхазуров | Чат-боты | Python | Ruby",
  # "username":"AshabAl","type":"private"},
  # "date":1698134713,"text":"asd"}

  # session[:user]
  
  def start!(*)
    respond_with :message, text: Tg::Common.erb_render("menu/instructions"), parse_mode: 'HTML'
    menu
  end

  def main_menu!
    menu
  end

  def menu(value = nil, *)
    save_context :menu

    case value
    when t('buttons.menu.categories')
      send_category
    when t('buttons.menu.advertisement')
      respond_with :message, text: Tg::Common.erb_render("menu/advertisement", { outcome: Tg::AdvertisementInteractor.run().result }), parse_mode: 'HTML'
      menu
    when t('buttons.menu.help')
      respond_with :message, text: Tg::Common.erb_render("menu/instructions"), parse_mode: 'HTML'
      menu
    when t('buttons.menu.points')
      view_tarifs
    else
      respond_with :message, text: Tg::Common.erb_render("menu/vacancies_info", {outcome: Tg::TotalVacanciesInteractor.run().result}), parse_mode: 'HTML'

      respond_with :message, text: Tg::Common.erb_render("menu/default"), parse_mode: 'HTML', reply_markup: {
        keyboard: [[Tg::Common.erb_render("menu/button/points"), Tg::Common.erb_render("menu/button/advertisement"), Tg::Common.erb_render("menu/button/help")], 
                   [Tg::Common.erb_render("menu/button/categories")]], resize_keyboard: true, one_time_keyboard: true, selective: true 
      }
    end
  end


  def callback_query(data_callback)
    return false unless chat["type"] == CHAT_TYPE
      
    case data_callback
    when t('callback_query.choice_categories')
      send_category
    when t('callback_query.points')
      view_tarifs
    when Buttons::WithAllTarifsRenderer::POINTS_REGEX
      send_invoice data_callback.scan(/\d+/).first.to_i
    when Tg::OpenVacancyInteractor::OPEN_VACANCY_REGEX
      view_vacancy data_callback.scan(/\d+/)
    when Tg::SpamVacancyInteractor::SPAM_VACANCY_REGEX
      answer_callback_query Tg::Common.erb_render("callback_query/spam_vacancy", { outcome: Tg::SpamVacancyInteractor.run(id: data_callback.scan(/\d+/)[1]).result }), show_alert: true
    when Buttons::WithAllCategoriesRenderer::PAGINATION_START_REGEX
      start_pagination_from data_callback.scan(/\d+/).first
    else
      return subscribe_or_unsubscribe_and_edit_message data_callback
    end
  end

  def pre_checkout_query(data)  
    bot.answer_pre_checkout_query(
      pre_checkout_query_id: data["id"],
      ok: true
    )

    points = data["invoice_payload"].to_i

    update_points = Tg::User::UpdatePointsInteractor.run(user: user, points: points, stars: data["total_amount"].to_i)    
    
    if update_points.errors.present?
      bot.send_message(
        text: Tg::Common.erb_render('pre_checkout_query/fail_payment'), 
        message_id: data[:message_id],
        chat_id: user.platform_id  
      )
      
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "#{errors_converter(update_points.errors)}, #{payload}")
      
      raise errors_converter(update_points.errors)
    end

    bot.send_message(
      text: Tg::Common.erb_render('pre_checkout_query/success_payment', { points: points }), 
      message_id: data[:message_id],
      chat_id: user.platform_id
    )
  end

  def message(_message)
    menu
  end

  def my_chat_member(data)
    outcome = Tg::User::StatusChangesForBlockInteractor.run(user: user)

    if outcome.errors.present?
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "#{errors_converter(outcome.errors)}, #{payload}")

      raise errors_converter(outcome.errors)
    end
  end

  private

  def subscribe_or_unsubscribe_and_edit_message(data_callback)
    outcome = Tg::User::UpdateSubscriptionWithCategoryInteractor.run(
        user: user, 
        category_name: data_callback,
        subscribed_categories: subscribed_categories
      )
    if outcome.errors.present?
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "#{errors_converter(outcome.errors)}, #{payload}")

      raise errors_converter(outcome.errors)
    end

    answer_callback_query Tg::Common.erb_render("callback_query/#{outcome.result[:status]}"), show_alert: true

    bot.edit_message_text(
      text: Tg::Common.erb_render('choice_category'), 
      message_id: session[:category_message_id], 
      chat_id: user.platform_id, 
      reply_markup: Buttons::WithAllCategoriesRenderer.new(subscribed_categories).call
    ) if outcome.result[:status] 
  end

  def start_pagination_from(page)
    vacancies = Tg::Vacancy::VacanciesForTheWeekInteractor.run(user: user).result

    case vacancies[:status]
    when :subscribed_categories_empty
      answer_callback_query Tg::Common.erb_render("pagination/#{vacancies[:status]}"), show_alert: true
    when :vacancy_list_empty
      answer_callback_query Tg::Common.erb_render("pagination/#{vacancies[:status]}"), show_alert: true
    when :ok
      pagy, records = pagy(vacancies[:vacancies], page: page, params: {})

      send_vacancies(records, pagy.from)

      respond_with :message,
        text: Tg::Common.erb_render("pagination/sended_vacancies", { pagy: pagy }), 
        parse_mode: 'HTML',
        reply_markup: {
        inline_keyboard: [
        [{ text: Tg::Common.erb_render("pagination/get_more_vacancies"), 
          callback_data: "#{Buttons::WithAllCategoriesRenderer::VACANSIES_START}#{pagy.next || pagy.last}" }],
        [{ text: "#{I18n.t('buttons.for_vacancy_message.by_points')}", callback_data: "#{I18n.t('buttons.points')}" }]
        ]
      }
    
      answer_callback_query Tg::Common.erb_render("pagination/sended_vacancies", { pagy: pagy }), show_alert: true if pagy.next.nil?
    end
  end

  def view_vacancy(data_scan)
    open_vacancy = Tg::OpenVacancyInteractor.run(user: user, id: data_scan[1]).result

    answer_callback_query Tg::Common.erb_render(open_vacancy[:path_view], { open_vacancy: open_vacancy }), show_alert: true if open_vacancy[:status] == :warning
    bot.edit_message_text(
      text: Tg::Common.erb_render(open_vacancy[:path_view], { open_vacancy: open_vacancy, user: user }), message_id: data_scan[0], chat_id: user.platform_id, parse_mode: 'HTML', 
      reply_markup: {
        inline_keyboard: [
          [{ text: Tg::Common.erb_render("button/by_points", { user: user }), 
            callback_data: "#{I18n.t('buttons.points')}" }],
          [{ text: "#{I18n.t('buttons.for_vacancy_message.spam')}", 
            callback_data: I18n.t('buttons.for_vacancy_message.callback_data', message_id: data_scan[0], vacancy_id: data_scan[1] ) }]
        ]
      }
    ) if open_vacancy[:status] == :open_vacancy
  end

  def send_invoice(tarif)
    bot.send_invoice(
        chat_id: user.platform_id,
        title: Tg::Common.erb_render('payment/title', { tarif: tarif }),
        description: Tg::Common.erb_render('points/tarif_callback', { tarif: tarif }),
        payload: tarif,
        currency: Buttons::WithAllTarifsRenderer::CURRENCY,
        prices: [
          Telegram::Bot::Types::LabeledPrice.new(
            label: Tg::Common.erb_render('points/tarif_callback', { tarif: tarif }), 
            amount: Buttons::WithAllTarifsRenderer::TARIFS_PRICES[tarif]
          )
        ]
      )
  end

  def send_category
    category_send_message = respond_with :message, text: Tg::Common.erb_render('choice_category'), reply_markup: Buttons::WithAllCategoriesRenderer.new(subscribed_categories).call

    session[:category_message_id] = category_send_message['result']['message_id']
  end

  def view_tarifs
    respond_with(:message, text: Tg::Common.erb_render("points/description", { user: user }), reply_markup: { inline_keyboard: Buttons::WithAllTarifsRenderer.new.call })
  end

  def subscribed_categories
    @subscribed_categories = Tg::Category::FindSubscribeInteractor.run(user: user).result
  end

  def find_or_create_user_and_send_analytics
    outcome = Tg::User::FindOrCreateWithUpdateByPlatformIdInteractor.run(chat: from)

    if outcome.errors.present?
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "#{errors_converter(outcome.errors)}, #{payload}")

      raise errors_converter(outcome.errors)
    end

    @user = outcome.result[:user]
  end

  def user
    @user ||= find_or_create_user_and_send_analytics
  end
  

  def send_vacancies(vacancies, start_number_vacancy)
    delay = Tg::Vacancy::VacanciesForTheWeekInteractor::DELAY / Pagy::DEFAULT[:limit]
    
    number = start_number_vacancy
    vacancies.each do | vacancy |
      hash = { vacancy: vacancy, number: number, user: user }
     
      message_id = respond_with(:message, text: Tg::Common.erb_render("pagination/vacancy", hash),
                                parse_mode: 'HTML')['result']['message_id']
      
      bot.edit_message_text(text: Tg::Common.erb_render("pagination/vacancy", hash), message_id: message_id, chat_id: user.platform_id, parse_mode: 'HTML', 
                                reply_markup: {
                                  inline_keyboard: [
                                    [{ text: Tg::Common.erb_render("button/get_contact"), callback_data: "mid_#{message_id}_bdid_#{vacancy.id}" }],
                                    [{ text: Tg::Common.erb_render("button/by_points", { user: user }), callback_data: "#{I18n.t('buttons.points')}" }],
                                    [{ text: "#{I18n.t('buttons.for_vacancy_message.spam')}", callback_data: I18n.t('buttons.for_vacancy_message.callback_data', message_id: message_id, vacancy_id: vacancy.id ) }]
                                  ]
                                })

      number += 1
      sleep(delay)
    end
  end


  def errors_converter(errors)
    errors.reduce([]) do |errors_list, error| 
      errors_list << {
        "attribute" => errors.first.attribute,
        "name" => errors.first.type,
        "options" => errors.first.options
      } 
    end
  end


  def send_error_in_admin_group(exception)
    bot.send_message(
      chat_id: Rails.application.secrets.errors_chat_id,
      text: exception.message.inspect
    )
  end
end