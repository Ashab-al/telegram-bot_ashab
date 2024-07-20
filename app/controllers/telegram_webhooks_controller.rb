# frozen_string_literal: true
require_relative '../services/pagination_service'
# require_relative '../mutations/payment/make_payment'

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  
  before_action :load_user, except: [:update_bonus_users!, :total_vacancies_sent, :get_the_mail,
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
      choice_help
      menu
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "start err: #{e}")
    end
  end
  def pre_checkout_query(pay_info)
    uri = "https://api.telegram.org/bot6733083435:AAEe5p9zB1ssYcxwbqwV4_4WPbFJk2TVvHk/answerPreCheckoutQuery"
    body = {
      pre_checkout_query_id: pay_info["id"],
      ok: true
    }

    headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
    puts body
    puts pay_info
    begin
      response = RestClient.post(uri, body.to_json, headers)
      puts response.body
    rescue RestClient::ExceptionWithResponse => e
      puts e.response.body
    end
    
  end

  def pay!
    respond_with :message, text: "Тест оплаты"
    uri = "https://api.telegram.org/bot6733083435:AAEe5p9zB1ssYcxwbqwV4_4WPbFJk2TVvHk/sendInvoice"

    body = {
      chat_id: @user.platform_id,
      title: "Тестовый заголовок",
      description: "Тестовое описание",
      provider_token: "381764678:TEST:87813",
      currency: "RUB",
      payload: @user.platform_id.to_i * rand(14..999999999),
      prices: [{label: "Покупка поинтов", amount: 100 * 100}],
      max_tip_amount: 1000000
    }.to_json

    headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
    puts body

    begin
      response = RestClient.post(uri, body, headers)
      puts response.body
    rescue RestClient::ExceptionWithResponse => e
      puts e.response.body
    end
  end

  def payment_verification(data)
    begin 
      result_check_paid = Yookassa.payments.find(payment_id: data[:payment_id])
      if result_check_paid[:status] == "succeeded"
        @user.update({:point => @user.point + result_check_paid[:metadata][:quantity_points].to_i})
        answer_callback_query 'Платеж успешно прошёл! 🔋🎉', show_alert: true
        bot.edit_message_text text: "Поздравляю! Платеж успешно прошёл! 🔋🎉\n" \
                                    "Вам зачислено #{result_check_paid[:metadata][:quantity_points].to_i} поинтов. 💳\n\n",
                            message_id: data[:message_id],
                            chat_id: @user.platform_id  
        bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "Оплата прошла успешно:\n\n" \
                                                    "Клиент: #{@user.name}\n" \
                                                    "Поинты: #{result_check_paid[:metadata][:quantity_points].to_i}")                     
        points              
      else
        respond_with :message,
                    text: "Похоже, ваш платеж не был подтвержден. 😕 \n\n" \
                          "Если вы уже произвели оплату и видите это сообщение, пожалуйста, подождите 5 минут. ⏳ И попробуйте снова нажать на кнопку \"Проверить платеж\"\n\n" \
                          "Если вы подождали 5 минут и проблема не решена, обратитесь к администратору @AshabAl. 📬"                 
      end

    rescue => e
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "payment_verification err: #{e}")
    end
  end

  def create_payment(data)
    begin 
      result_create_payment = Payment::MakePayment.run({
        value: "#{data[:cost]}",
        description: "#{data[:description]}",
        platform_id: "#{@user.platform_id}",
        email: "#{@user.email}",
        quantity_points: "#{data[:quantity_points]}"
      })

      if result_create_payment.success?
        result_send_message = respond_with :message,
                                          text: "Не забудьте нажать кнопку \"Проверить платеж\" после совершения оплаты.\n" \
                                                "Это необходимо для подтверждения вашей транзакции. 🌟 \n\n" \
                                                "💎 Количество поинтов: #{data[:quantity_points]}\n" \
                                                "🔋Стоимость: #{data[:cost].to_i}₽\n\n" \
                                                "Ссылка для оплаты - #{result_create_payment.result.confirmation.confirmation_url}",
                                          reply_markup: {
                                            inline_keyboard: [[{ text: 'Проверить платеж', callback_data: "pay_id_#{result_create_payment.result.id}" }]]
                                          }
        session[:create_payment_message_id] = result_send_message['result']['message_id'] 

        bot.edit_message_text text: "Не забудьте нажать кнопку \"Проверить платеж\" после совершения оплаты.\n" \
                                    "Это необходимо для подтверждения вашей транзакции. 🌟 \n\n" \
                                    "💎 Количество поинтов: #{data[:quantity_points]}\n" \
                                    "🔋Стоимость: #{data[:cost].to_i}₽\n\n" \
                                    "Ссылка для оплаты - #{result_create_payment.result.confirmation.confirmation_url}",
                              message_id: result_send_message['result']['message_id'],
                              chat_id: @user.platform_id,
                              reply_markup: {
                                inline_keyboard: [
                                  [{ text: 'Проверить платеж', 
                                    callback_data: "pay_id_#{result_create_payment.result.id}_mes_id_#{result_send_message['result']['message_id']}" }]
                                ]
                              } 
      end
    rescue => e
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "create_payment err: #{e}")
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
        marketing
        menu
      when 'Помощь'
        choice_help
        menu
      when 'Поинты'
        points
      else
        respond_with :message, text: total_vacancies_sent,
                                parse_mode: 'HTML'

        respond_with :message, text: 'Это главное меню чат-бота', reply_markup: {
          keyboard: [['Поинты 💎', 'Реклама ✨', 'Помощь ⚙️'], ['Категории 🧲']],
          resize_keyboard: true,
          one_time_keyboard: true,
          selective: true
        }
      end
    rescue => e
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "menu err: #{e}")
    end
  end

  def total_vacancies_sent
    vacancies_by_category = Vacancy.group(:category_title).count
    text = "<b>Всего вакансий отправлено:</b> #{Vacancy.count} ⚡️\n"
    
    Category.all.each do |category|  
      category_vacancies_count = vacancies_by_category[category.name] || 0
      text += if category_vacancies_count.positive?
                "<b>#{category.name}:</b> #{category_vacancies_count}\n"
              else
                "#{category.name}: #{category_vacancies_count}\n"
              end
    end
    
    text 
  end

  def points
    begin
      points_message = respond_with :message,
                  text: "#{from['first_name']}\n\n" \
                        "🔍 Ваш баланс: #{@user.point} \n" \
                        "🎁 Бонусные: #{@user.bonus} \n\n" \
                        'Используйте поинты, чтобы открывать вакансии и расширять свои возможности!',
                  reply_markup: {
                    inline_keyboard: [[{ text: 'Купить поинты',
                                          callback_data: 'Купить поинты' }]]
                  }
      session[:by_points_message_id] = points_message['result']['message_id']
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "points err: #{e}")
    end
  end

  def get_the_mail(*args)
    begin
      if args.any?
        session[:email] = args.first
        case session[:email]
          when /^[-\w.]+@([A-z0-9][-A-z0-9]+\.)+[A-z]{2,4}$/
            get_the_mail_message = respond_with :message, 
                    text: "Ваша почта: #{args.first}",
                    reply_markup: {inline_keyboard: [[{ text: 'Поменять почту', callback_data: 'Поменять почту' }],
                                                      [{ text: 'Все четко✅', callback_data: 'Все четко' }]]}
            session[:by_points_message_id] = get_the_mail_message['result']['message_id']
            
          else  
            save_context :get_the_mail 
            respond_with :message, text: "Некорректная почта. Напишите еще раз"
        end
                                                                        
      else 
        save_context :get_the_mail 
        respond_with :message, text: "Напишите свою почту в этот чат (Почта нужна для отправки чека)"
      end
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "get_the_mail err: #{e}")
    end
  end

  def by_points
    begin
      if @user.email
        choice_tarif
      else
        get_the_mail
      end
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "by_points err: #{e}")
    end
  end

  def choice_tarif
    begin 
      bot.edit_message_text text: "Ваш e-mail: #{@user.email}\n\n" \
                                  "С поинтами вы всегда в плюсе!\n\n" \
                                  "Выберите подходящий тарифный пакет.",
                            message_id: session[:by_points_message_id],
                            chat_id: @user.platform_id,
                            reply_markup: {
                              inline_keyboard: [
                                [{ text: '💎 10 поинтов - 60₽', callback_data: '10 поинтов' }],
                                [{ text: '💎 30 поинтов - 171₽', callback_data: '30 поинтов' }],
                                [{ text: '💎 50 поинтов - 270₽', callback_data: '50 поинтов' }],
                                [{ text: '💎 100 поинтов - 510₽', callback_data: '100 поинтов' }],
                                [{ text: '💎 150 поинтов - 720₽', callback_data: '150 поинтов' }],
                                [{ text: '💎 200 поинтов - 900₽', callback_data: '200 поинтов' }]
                              ]
                            }            
    rescue => e
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "choice_tarif err: #{e}")
    end
  end

  def choice_help
    begin
      respond_with :message, text: "👉⚡️ Инструкция:\n\n" \
      "1️⃣ Нажми \"Категории 🧲\" для старта ✅\n\n" \
      "2️⃣ Выбери свою область 💼\n" \
      "🔹 Получай интересные предложения мгновенно\n\n" \
      "3️⃣ В разделе \"Поинты 💎\" проверь баланс\n" \
      "🔹 Поинты - валюта для доступа к контактам ⚜️\n" \
      "🔹 Ежедневно 2 бесплатных поинта\n\n" \
      'Готовы к новым возможностям? "Категории 🧲" - и вперёд!' 

    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "choice_help err: #{e}")
    end
  end

  def marketing
    begin
      text = ""
      Category.all.each_with_index do |category, index|
        text += "#{index+1}. #{category.name}: #{category.user.size}\n"
      end
      respond_with :message, text: "(Еще в разработке)\n\n" \
                                  "Количество пользователей в боте:\n" + text     
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "marketing err: #{e}")
    end
  end

  def choice_category
    begin
      category_send_message = respond_with :message,
                                          text: "Выберите категории \n" \
                                                "(Просто нажмите на интересующие кнопки)\n\n" \
                                                "🔋 - означает что категория выбрана\n" \
                                                "\u{1FAAB} - означает что категория НЕ выбрана",
                                          reply_markup: formation_of_category_buttons

      session[:category_message_id] = category_send_message['result']['message_id']
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "choice_category err: #{e}")
    end
  end
  

  def callback_query(data_callback)
    begin
      
      case data_callback
      when 'Выбрать категории'
        choice_category
        return true
      when 'Купить поинты'
        by_points
        return true
      when 'Поинты'
        points
        return true
      when 'Поменять почту'
        get_the_mail
        return true
      when 'Все четко'
        case session[:email]
        when /^[-\w.]+@([A-z0-9][-A-z0-9]+\.)+[A-z]{2,4}$/
          @user.update({:email => session[:email]})
          choice_tarif
        else
          get_the_mail
        end       
        return true
      when /^\d{1,3} поинтов$/
        tarifs = {
          "10 поинтов": {
            :cost => 60.00,
            :description => "10 поинтов",
            :quantity_points => 10
          },
          "30 поинтов": {
            :cost => 171.00,
            :description => "30 поинтов",
            :quantity_points => 30
          },
          "50 поинтов": {
            :cost => 270.00,
            :description => "50 поинтов",
            :quantity_points => 50
          },
          "100 поинтов": {
            :cost => 510.00,
            :description => "100 поинтов",
            :quantity_points => 100
          },
          "150 поинтов": {
            :cost => 720.00,
            :description => "150 поинтов",
            :quantity_points => 150
          },
          "200 поинтов": {
            :cost => 900.00,
            :description => "200 поинтов",
            :quantity_points => 200
          }
        }
        create_payment({
          :cost => tarifs[:"#{data_callback}"][:cost],
          :description => tarifs[:"#{data_callback}"][:description],
          :quantity_points => tarifs[:"#{data_callback}"][:quantity_points]
        })
        return true
      when /^mid_\d+_bdid_\d+/
        data_scan = data_callback.scan(/\d+/)
        open_a_vacancy({ :message_id => data_scan[0], :vacancy_id => data_scan[1] })
        return true
      when /^spam_mid_\d+_bdid_\d+/
        data_scan = data_callback.scan(/\d+/)
        spam_vacancy({ :message_id => data_scan[0], :vacancy_id => data_scan[1] })
        return true
      when /pay_id_\S+/
        match_data = data_callback.scan(/pay_id_(\w+-\w+-\w+-\w+-\w+)_.*mes_id_(\d+)/)
        payment_verification({
          :payment_id => match_data[0][0],
          :message_id => match_data[0][1]
        })
        return true
      when "Получить вакансии"
        send_vacancy_start # Доработка
        return true
      when "more_vacancies"
        send_vacancy_next
        return true
      end

      category = Category.find_by(name: data_callback)
      checking_subscribed_category(category.id) if category

    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "callback_query err: #{e.inspect}")
    end
  end

  def send_vacancy_start
    subscribed_categories_name = @subscribed_categories.map(&:name)
    vacancy_list = Vacancy.where(category_title: subscribed_categories_name).
                    where.not(platform_id: Blacklist.pluck(:contact_information)).
                    where(created_at: 7.days.ago..Time.now).order(created_at: :asc)

    if subscribed_categories_name.empty? 
      answer_callback_query "📜 Выберите хотя бы одну категорию из предложенного списка", 
                              show_alert: true
      return false
    elsif vacancy_list.empty?
      answer_callback_query "📜 Вакансий не найдено 😞", 
                              show_alert: true
      return false
    end

    session[:vacancy_list_start_number] = 0
    paginationservice = PaginationService.new(@user, vacancy_list.reverse, session[:vacancy_list_start_number])

    session[:vacancy_list_start_number] = paginationservice.send_vacancy_pagination
  end

  def send_vacancy_next
    subscribed_categories_name = @subscribed_categories.map(&:name)
    vacancy_list = Vacancy.where(category_title: subscribed_categories_name).
                    where.not(platform_id: Blacklist.pluck(:contact_information)).
                    where(created_at: 7.days.ago..Time.now).order(created_at: :asc)
    
    if subscribed_categories_name.empty? 
      answer_callback_query "📜 Выберите хотя бы одну категорию из предложенного списка", 
                              show_alert: true
      return false
    elsif vacancy_list.empty?
      answer_callback_query "📜 Вакансий не найдено 😞", 
                              show_alert: true
      return false
    elsif session[:vacancy_list_start_number].nil?
      choice_category
      return false
    end

    paginationservice = PaginationService.new(@user, vacancy_list.reverse, session[:vacancy_list_start_number])
    if session[:vacancy_list_start_number] >= vacancy_list.count 
      answer_callback_query "📜 Все вакансии из ваших интересующих категорий успешно отправлены! ✅", 
                                show_alert: true
    else
      session[:vacancy_list_start_number] = paginationservice.send_vacancy_pagination
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

  def load_user
    begin
      @user = User.find_by_platform_id(payload['from']['id'])
      unless @user
        @user = User.new(user_params(payload))
        if @user.save
          bot.send_message(chat_id: 377884669, 
          text: "Новый пользователь в боте\n\n" \
                "Имя: #{@user.name}\n" \
                "username: @#{@user.username}\n\n" \
                "Всего пользователей в боте: #{User.all.size}\n" \
                "Все у кого статус works: #{User.where(bot_status: "works").size}\n" \
                "Все у кого статус bot_blocked: #{User.where(bot_status: "bot_blocked").size}"
          )
        else
          bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, 
          text: "Пользователь не сохранился в бд #{payload}")
        end
      end
      subscriptions = @user.subscriptions.includes(:category)
      @subscribed_categories = subscriptions.map(&:category)
      @user.update({:bot_status => "works"}) if @user.bot_status != "works"
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "load_user err: #{e}")
    end
  end

  def user_params(data)
    begin
      {
        username: data['from']['username'] || "",
        platform_id: data['from']['id'],
        name: data['from']['first_name'] || "",
        point: 0,
        bonus: 5
      }
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "user_params err: #{e}")
    end
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
      buttons << [{text: "Получить вакансии 🔍", callback_data: "Получить вакансии"}]
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

  def open_a_vacancy(data)
    begin
      vacancy = Vacancy.find(data[:vacancy_id])
      contact_information = vacancy.source == "tg_chat" ? vacancy.platform_id : vacancy.contact_information
  
      blacklist = Blacklist.find_by(:contact_information => contact_information)
      if blacklist and blacklist.complaint_counter >= 3
        answer_callback_query "Эта вакансия была определена как нежелательная и добавлена в наш черный список. 🚫😕", show_alert: true
        return true
      end
      button = [
        [{ text: "Купить поинты #{@user.point <= 5 ? "🪫" : "🔋"}", callback_data: "Поинты" }],
        [{ text: "🤖 Спам 🤖", callback_data: "spam_mid_#{data[:message_id]}_bdid_#{data[:vacancy_id]}" }]
      ]
      text_formation = "<b>Категория:</b> #{vacancy.category_title}\n" \
                      "<b>Всего поинтов на счету:</b> #{@user.point + @user.bonus - 1}\n\n" \
                      "#{vacancy.description}\n\n" \
                      "<b>Контакты:</b>\n" \
                      "#{vacancy.contact_information}"
                      
      if @user.bonus > 0
        update_point_send_messag(text_formation, {:bonus => @user.bonus - 1}, data[:message_id], button)
      elsif @user.point > 0
        update_point_send_messag(text_formation, {:point => @user.point - 1}, data[:message_id], button)
      else
        answer_callback_query "У вас закончились поинты \u{1FAAB}\n\n" \
                              "Покупка поинтов - выгодное вложение!" \
                              "💎 Бонусный счет: #{@user.bonus}\n" \
                              "💎 Платный счет: #{@user.point}\n", 
                              show_alert: true
      end
    rescue => e 
      bot.send_message(chat_id: Rails.application.secrets.errors_chat_id, text: "open_a_vacancy err: #{e}")
    end
  end

  def spam_vacancy(data)
    vacancy = Vacancy.find(data[:vacancy_id])
    contact_information = vacancy.source == "tg_chat" ? vacancy.platform_id : vacancy.contact_information
  
    blacklist = Blacklist.find_or_create_by(contact_information: contact_information) do |blacklist|
      blacklist.complaint_counter = 0
    end
  
    if blacklist.complaint_counter >= 3
      answer_callback_query "Эта вакансия была определена как нежелательная и добавлена в наш черный список. 🚫😕", show_alert: true
    else
      answer_callback_query "Ваша жалоба на данную вакансию успешно отправлена. 🚀✅", show_alert: true
      blacklist.increment!(:complaint_counter)
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
end
