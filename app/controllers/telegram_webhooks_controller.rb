# frozen_string_literal: true
require_relative '../services/pagination_service'

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Pagy::Backend

  IGNORED_FOR_USER_AND_SUBSCRIBED_CATEGORIES=[:choice_category, :message, :session_key]
  
  before_action :set_locale
  before_action :find_or_create_user_and_send_analytics, except: IGNORED_FOR_USER_AND_SUBSCRIBED_CATEGORIES
  before_action :subscribed_categories, except: IGNORED_FOR_USER_AND_SUBSCRIBED_CATEGORIES
  
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
    begin
      respond_with :message, text: Tg::Common.erb_render("menu/instructions", binding), parse_mode: 'HTML'
      menu
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "start err: #{e}")
    end
  end

  def main_menu!
    begin
      menu
    rescue => e
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "main_menu err: #{e}")
    end
  end

  def menu(value = nil, *)
    save_context :menu

    case value
    when t('buttons.menu.categories')
      choice_category
    when t('buttons.menu.advertisement')
      @outcome = Tg::AdvertisementInteractor.run().result
      respond_with :message, text: Tg::Common.erb_render("menu/advertisement", binding), parse_mode: 'HTML'
      menu
    when t('buttons.menu.help')
      respond_with :message, text: Tg::Common.erb_render("menu/instructions", binding), parse_mode: 'HTML'
      menu
    when t('buttons.menu.points')
      points
    else
      @outcome = Tg::TotalVacanciesInteractor.run().result
      respond_with :message, text: Tg::Common.erb_render("menu/vacancies_info", binding), parse_mode: 'HTML'

      respond_with :message, text: Tg::Common.erb_render("menu/default", binding), parse_mode: 'HTML', reply_markup: {
        keyboard: [[Tg::Common.erb_render("menu/button/points", binding), Tg::Common.erb_render("menu/button/advertisement", binding), Tg::Common.erb_render("menu/button/help", binding)], 
                   [Tg::Common.erb_render("menu/button/categories", binding)]], resize_keyboard: true, one_time_keyboard: true, selective: true 
      }
    end
  end

  def points
    session[:by_points_message_id] = respond_with(:message, text: Tg::Common.erb_render("points/description", binding),
                                                  reply_markup: { inline_keyboard: Buttons::WithAllTarifsRenderer.new.call })['result']['message_id']
  end

  def choice_category
    begin
      category_send_message = respond_with :message, text: Tg::Common.erb_render('choice_category', binding), reply_markup: Buttons::WithAllCategoriesRenderer.new(subscribed_categories).call

      session[:category_message_id] = category_send_message['result']['message_id']
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "choice_category err: #{e}")
    end
  end
  

  def callback_query(data_callback)
    return false unless chat["type"] == "private"

    begin
      
      case data_callback
      when 'Выбрать категории'
        choice_category
        return true
      
      when 'Поинты'
        points
        return true

      when /^\d{1,3} поинт(а|ов)?$/
        begin
          Payment::CreateInteractor.run({
            :chat_id => "#{@user.platform_id}",
            :bot => bot,
            :tarif => data_callback,
            :title => t('bot.title')
          })
          return true
        rescue => e 
          bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "Payment::CreateInteractor err: #{e}")
        end
        

      when /^mid_\d+_bdid_\d+/
        begin
          data_scan = data_callback.scan(/\d+/)
          @open_vacancy = Tg::OpenVacancyInteractor.run(user: @user, id: data_scan[1]).result

          answer_callback_query Tg::Common.erb_render(@open_vacancy[:path_view], binding), show_alert: true if @open_vacancy[:status] == :warning
          bot.edit_message_text(text: Tg::Common.erb_render(@open_vacancy[:path_view], binding), message_id: data_scan[0], chat_id: @user.platform_id, parse_mode: 'HTML', 
                                reply_markup: {
                                  inline_keyboard: [
                                    [{ text: "#{I18n.t('buttons.for_vacancy_message.by_points')} #{@open_vacancy[:low_points] ? I18n.t('smile.low_battery') : I18n.t('smile.full_battery')}", 
                                      callback_data: "#{I18n.t('buttons.points')}" }],
                                    [{ text: "#{I18n.t('buttons.for_vacancy_message.spam')}", 
                                      callback_data: I18n.t('buttons.for_vacancy_message.callback_data', message_id: data_scan[0], vacancy_id: data_scan[1] ) }]
                                  ]
                                }) if @open_vacancy[:status] == :open_vacancy

          return true
        rescue => e 
          bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "Tg::OpenVacancyInteractor err: #{e}")
        end
      when /^spam_mid_\d+_bdid_\d+/
        @outcome = Tg::SpamVacancyInteractor.run(id: data_callback.scan(/\d+/)[1]).result
        answer_callback_query Tg::Common.erb_render("callback_query/spam_vacancy", binding), show_alert: true
        return true

      when /^#{Buttons::WithAllCategoriesRenderer::VACANSIES_START}\d+/
        page = data_callback.scan(/\d+/).first
        
        vacancies = Tg::Vacancy::VacanciesForTheWeekInteractor.run(user: @user).result

        case vacancies[:status]
        when :subscribed_categories_empty
          answer_callback_query Tg::Common.erb_render("pagination/subscribed_categories_empty", binding), show_alert: true
          return
        when :vacancy_list_empty
          answer_callback_query Tg::Common.erb_render("pagination/vacancy_list_empty", binding), show_alert: true
          return
        when :ok
          @pagy, @records = pagy(vacancies[:vacancies], page: page, params: {})

          send_vacancies(@records, @pagy.from)

          respond_with :message,
            text: Tg::Common.erb_render("pagination/sended_vacancies", binding), 
            parse_mode: 'HTML',
            reply_markup: {
            inline_keyboard: [
            [{ text: Tg::Common.erb_render("pagination/get_more_vacancies", binding), 
              callback_data: "#{Buttons::WithAllCategoriesRenderer::VACANSIES_START}#{@pagy.next || @pagy.last}" }],
            [{ text: "#{I18n.t('buttons.for_vacancy_message.by_points')}", callback_data: "#{I18n.t('buttons.points')}" }]
            ]
          }
        
          answer_callback_query Tg::Common.erb_render("pagination/sended_vacancies", binding), show_alert: true if @pagy.next.nil?
        end
        return true
      end

      outcome = Tg::User::UpdateSubscriptionWithCategoryInteractor.run(
          user: user, 
          category_name: data_callback,
          subscribed_categories: subscribed_categories
        )
      if outcome.errors.present?
        bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "#{errors_converter(outcome.errors)}, #{payload}")
  
        raise errors_converter(outcome.errors)
      end

      answer_callback_query Tg::Common.erb_render("callback_query/#{outcome.result[:status]}", binding), show_alert: true

      bot.edit_message_text(
        text: Tg::Common.erb_render('choice_category', binding), message_id: session[:category_message_id], 
        chat_id: user.platform_id, reply_markup: formation_of_category_buttons
      ) if outcome.result[:status] 

    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "callback_query err: #{e.inspect}")
    end
  end

  def pre_checkout_query(data)
    begin
      bot.answer_pre_checkout_query(
        pre_checkout_query_id: data["id"],
        ok: true
      )

      @user.update({:point => @user.point + data["invoice_payload"].to_i})
            
      bot.send_message text: "Поздравляю! Платеж успешно прошёл! 🔋🎉\n" \
                              "Вам зачислено #{data["invoice_payload"]} поинтов. 💳\n\n",
                          message_id: data[:message_id],
                          chat_id: @user.platform_id  
      

      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "Оплата прошла успешно:\n\n" \
                                                                                "Клиент: #{@user.name}\n" \
                                                                                "Поинты: #{data["invoice_payload"]}\n" \
                                                                                "Звезд заплатили: #{data["total_amount"]}"
                                                                              )                     
      
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "pre_checkout_query err: #{e.inspect}")
    end
  end

  def message(_message)
    begin
      menu
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "message err: #{e}")
    end
  end

  def my_chat_member(data)
    outcome = Tg::User::StatusChangesForBlockInteractor.run(user: @user)

    if outcome.errors.present?
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "#{errors_converter(outcome.errors)}, #{payload}")

      raise errors_converter(outcome.errors)
    end
  end

  private

  def subscribed_categories
    @subscribed_categories ||= Tg::Category::FindSubscribeInteractor.run(user: @user).result
  end

  def find_or_create_user_and_send_analytics
    outcome = Tg::User::FindOrCreateWithUpdateByPlatformIdInteractor.run(chat: chat)

    if outcome.errors.present?
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "#{errors_converter(outcome.errors)}, #{payload}")

      raise errors_converter(outcome.errors)
    end

    @user = outcome.result[:user]
  end

  def user
    @user ||= find_or_create_user_and_send_analytics
  end
  
  def formation_of_category_buttons
    begin
      subscriptions = @user.subscriptions.includes(:category)
      @subscribed_categories = subscriptions.map(&:category)
      all_category = Category.all
      
      buttons = []
      couple_button = []
      all_category.each do | category |
        couple_button << {
          text: "#{category.name} #{@subscribed_categories.include?(category) ? '🔋' : "\u{1FAAB}"}",
          callback_data: "#{category.name}"
        }

        if couple_button.size == 2 || category == all_category.last
          buttons << couple_button
          couple_button = []
        end
      end
      buttons << [{text: "Получить вакансии 🔍", callback_data: "get_vacancies_start_1"}]
      {inline_keyboard: buttons}
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "formation_of_category_buttons err: #{e}")
    end
  end

  def send_vacancies(vacancies, start_number_vacancy)
    delay = Tg::Vacancy::VacanciesForTheWeekInteractor::DELAY / Pagy::DEFAULT[:limit]
    
    @number = start_number_vacancy
    vacancies.each do | vacancy |
      @vacancy = vacancy
      
      message_id = respond_with(:message, text: Tg::Common.erb_render("pagination/vacancy", binding),
                                parse_mode: 'HTML')['result']['message_id']
      
      bot.edit_message_text(text: Tg::Common.erb_render("pagination/vacancy", binding), message_id: message_id, chat_id: @user.platform_id, parse_mode: 'HTML', 
                                reply_markup: {
                                  inline_keyboard: [
                                    [{ text: Tg::Common.erb_render("button/get_contact", binding), callback_data: "mid_#{message_id}_bdid_#{@vacancy.id}" }],
                                    [{ text: "#{I18n.t('buttons.for_vacancy_message.by_points')}", 
                                      callback_data: "#{I18n.t('buttons.points')}" }],
                                    [{ text: "#{I18n.t('buttons.for_vacancy_message.spam')}", 
                                      callback_data: I18n.t('buttons.for_vacancy_message.callback_data', message_id: message_id, vacancy_id: @vacancy.id ) }]
                                  ]
                                })

      @number += 1
      sleep(delay)
    end
  end

  def session_key
    "#{bot.username}:#{from ? "from:#{from['id']}" : "chat:#{chat['id']}"}"
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

  def set_locale
    I18n.locale = :ru
  end

  def callback_id
    Telegram.bot.get_updates["result"].first["callback_query"]["id"]
  end
end