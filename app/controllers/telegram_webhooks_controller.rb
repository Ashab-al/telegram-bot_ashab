# frozen_string_literal: true
require_relative '../services/pagination_service'

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  
  before_action :set_locale

  before_action :find_user, except: [:update_bonus_users!, :total_vacancies_sent,
                                     :choice_help, :marketing, :choice_category, 
                                     :message, :user_params, :spam_vacancy, :session_key]
  
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
      respond_with :message, text: erb_render("start", binding)
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
    begin
      save_context :menu

      case value
      when 'Категории'
        choice_category
      when 'Реклама'
        @outcome = Tg::AdvertisementInteractor.run().result
        respond_with :message, text: erb_render("menu/advertisement", binding), parse_mode: 'HTML'
        menu
      when 'Помощь'
        respond_with :message, text: t('instructions')
        menu
      when 'Поинты'
        points
      else
        @outcome = Tg::TotalVacanciesInteractor.run().result
        respond_with :message, text: erb_render("menu/vacancies_info", binding),
                                parse_mode: 'HTML'

        respond_with :message, text: erb_render("menu/default", binding), reply_markup: {
          keyboard: [["#{t('buttons.menu.points')}", "#{t('buttons.menu.advertisement')}", "#{t('buttons.menu.help')}"], 
                     ["#{t('buttons.menu.categories')}"]],
          resize_keyboard: true,
          one_time_keyboard: true,
          selective: true
        }
      end
    rescue => e
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "menu err: #{e}")
    end
  end

  def points
    begin
      points_message = respond_with :message,
                  text: "#{t('user.name', name: from['first_name'])}\n\n" \
                        "#{t('user.balance.point', point: @user.point)}\n" \
                        "#{t('user.balance.bonus', bonus: @user.bonus)}\n\n" \
                        "#{t('user.balance.recommendation')}",
                        reply_markup: {
                          inline_keyboard: [10, 30, 50, 100, 150, 200].map { | quantity | [{ text: t("buttons.by_points.point_#{quantity}"), 
                                                                                             callback_data: t("buttons.by_points.point_#{quantity}_callback") }] }
                        } 
      session[:by_points_message_id] = points_message['result']['message_id']
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "points err: #{e}")
    end
  end

  def choice_category
    begin
      category_send_message = respond_with :message, text: "#{t('choice_category')}", reply_markup: formation_of_category_buttons

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

      when /^\d{1,3} поинтов$/
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

          answer_callback_query erb_render(@open_vacancy[:path_view], binding), show_alert: true if @open_vacancy[:status] == :warning
          bot.edit_message_text(text: erb_render(@open_vacancy[:path_view], binding), message_id: data_scan[0], chat_id: @user.platform_id, parse_mode: 'HTML', 
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
        answer_callback_query erb_render("callback_query/spam_vacancy", binding), show_alert: true
        return true

      when /^get_vacancies_start_\d+/
        batch_start = data_callback.scan(/\d+/).first
        @get_vacancies = Pagination::GetVacanciesSliceInteractor.run(
          subscribed_categories: @subscribed_categories, 
          batch_start: batch_start
        ).result
        
        case @get_vacancies[:status]
        when :subscribed_categories_empty
          answer_callback_query erb_render("pagination/subscribed_categories_empty", binding), show_alert: true
        when :vacancy_list_empty
          answer_callback_query erb_render("pagination/vacancy_list_empty", binding), show_alert: true
        when :full_sended
          answer_callback_query erb_render("pagination/sended_vacancies", binding), show_alert: true
        
        when :ok
          send_vacancies(@get_vacancies, batch_start)
          respond_with :message,
            text: erb_render("pagination/sended_vacancies", binding), 
            parse_mode: 'HTML',
            reply_markup: {
            inline_keyboard: [
            [{ text: erb_render("pagination/get_more_vacancies", binding), 
              callback_data: "get_vacancies_start_#{@get_vacancies[:last_item_number]}" }],
            [{ text: "#{I18n.t('buttons.for_vacancy_message.by_points')}", callback_data: "#{I18n.t('buttons.points')}" }]
            ]
          }
        end
          
        return true
      end

      category = Category.find_by(name: data_callback)
      checking_subscribed_category(category.id) if category

    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "callback_query err: #{e.inspect}")
    end
  end

  def send_vacancies(data, last_index)
    delay = Pagination::GetVacanciesSliceInteractor::DELAY / Pagination::GetVacanciesSliceInteractor::QUANTITY_VACANCIES

    data[:batch].each_with_index do |vacancy, index|
      @vacancy = vacancy
      @index = index + last_index.to_i
      
      sleep(delay)
      message_id = respond_with(:message, text: erb_render("pagination/vacancy", binding),
                                parse_mode: 'HTML')['result']['message_id']
      
      bot.edit_message_text(text: erb_render("pagination/vacancy", binding), message_id: message_id, chat_id: @user.platform_id, parse_mode: 'HTML', 
                                reply_markup: {
                                  inline_keyboard: [
                                    [{ text: erb_render("button/get_contact", binding), callback_data: "mid_#{message_id}_bdid_#{@vacancy.id}" }],
                                    [{ text: "#{I18n.t('buttons.for_vacancy_message.by_points')}", 
                                      callback_data: "#{I18n.t('buttons.points')}" }],
                                    [{ text: "#{I18n.t('buttons.for_vacancy_message.spam')}", 
                                      callback_data: I18n.t('buttons.for_vacancy_message.callback_data', message_id: message_id, vacancy_id: @vacancy.id ) }]
                                  ]
                                })

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
    begin
      @user.update({:bot_status => "bot_blocked"})
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "my_chat_member err: #{e}")
    end
  end

  private

  def find_user
    outcome = Tg::User::ByPlatformIdInteractor.run(user_params(payload))

    
    if outcome.errors.present?
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "Пользователь не сохранился в бд #{errors_converter(outcome.errors)}, #{payload}")

      raise errors_converter(outcome.errors)
    end

    @user = outcome.result[:user]
    @user.update({:bot_status => "works"}) if @user.bot_status != "works"

    if outcome.result[:status] == :new_user
      @analytics = {
        users_count: User.count,
        works_users: User.pluck(Arel.sql("(select count(*) from users where users.bot_status = 'works')")),
        bot_blocked_users: User.pluck(Arel.sql("(select count(*) from users where users.bot_status = 'bot_blocked')"))
      }

      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: erb_render("analytics", binding))
    end
    
    subscriptions = @user.subscriptions.includes(:category)
    @subscribed_categories = subscriptions.map(&:category)
  end

  def user_params(data)
    {
      username: data['from']['username'] || "",
      id: data['from']['id'],
      name: data['from']['first_name'] || "",
      point: 0,
      bonus: 5
    }
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
      buttons << [{text: "Получить вакансии 🔍", callback_data: "get_vacancies_start_0"}]
      {inline_keyboard: buttons}
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "formation_of_category_buttons err: #{e}")
    end
  end

  def edit_message_category
    begin
      bot.edit_message_text(text: "Выберите категории \n" \
                                  "(Просто нажмите на интересующие кнопки)\n\n" \
                                  "🔋 - означает что категория выбрана\n" \
                                  "\u{1FAAB} - означает что категория НЕ выбрана",
                            message_id: session[:category_message_id],
                            chat_id: @user.platform_id,
                            reply_markup: formation_of_category_buttons)

    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "edit_message_category err: #{e}")
    end
  end

  def checking_subscribed_category(category_id)
    begin
      target_category = Category.find(category_id)

      if @subscribed_categories.include?(target_category)
        unsubscribe_user_from_category(target_category)
        answer_callback_query "Категория успешно удалена из списка желаемого. 👽✅\n\n" \
                              "Вакансии по этому направлению не будут приходить", show_alert: true
      else
        subscribe_user_to_category(target_category)
        answer_callback_query "Категория успешно добавлена в список желаемого. 🤖✅\n\n" \
                              "Скоро бот будет отправлять вакансии по этому направлению. 😉📩", show_alert: true
      end
      edit_message_category
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "checking_subscribed_category err: #{e}")
    end
  end

  def subscribe_user_to_category(category)
    begin
      @user.subscriptions.create(category: category)
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "subscribe_user_to_category err: #{e}")
    end
  end

  def unsubscribe_user_from_category(category)
    begin
      @user.subscriptions.find_by(category: category)&.destroy
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "unsubscribe_user_from_category err: #{e}")
    end
  end


  def update_point_send_messag(text, data, message_id, button)
    begin
      bot.edit_message_text(text: text,
                            message_id: message_id,
                            chat_id: @user.platform_id,
                            parse_mode: 'HTML',
                            reply_markup: {inline_keyboard: button})
      @user.update(data)
    rescue => e 
      answer_callback_query "Вакансия успешно отправлена ✅", show_alert: true
      respond_with :message,
                  text: text,
                  parse_mode: 'HTML',
                  reply_markup: {inline_keyboard: button}
                  
      @user.update(data)            
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "update_point_send_messag Вакансия успешно отправлена ✅ err: #{e}")
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


  private
  
  def set_locale
    I18n.locale = :ru
  end

  def erb_render(action, new_binding)
    ERB.new(File.read(Rails.root.join "app/views/telegram_webhooks/#{action}.html.erb")).result(new_binding)
  end

  def callback_id
    Telegram.bot.get_updates["result"].first["callback_query"]["id"]
  end
end