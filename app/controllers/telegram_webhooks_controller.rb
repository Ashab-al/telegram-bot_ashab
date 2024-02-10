# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  
  before_action :load_user, only: [:start!, :payment_verification, :create_payment, :points,
                                   :by_points, :choice_tarif, :callback_query, 
                                   :formation_of_category_buttons, :edit_message_category,
                                   :checking_subscribed_category, :subscribe_user_to_category,
                                   :unsubscribe_user_from_category, :open_a_vacancy,
                                   :update_point_send_messag, :menu] # потом ограничить , only: [:example] или  except: [:example]
  # bin/rake telegram:bot:poller   запуск бота

  # chat - выдает такие данные
  # {"id":377884669,"first_name":"Асхаб Алхазуров | Чат-боты | Python | Ruby",
  # "username":"AshabAl","type":"private"}

  # from - выдает такие данные
  # {"id":377884669,"is_bot":false,
  # "first_name":"Асхаб Алхазуров | Чат-боты | Python | Ruby",
  # "username":"AshabAl","language_code":"ru","is_premium":true}

  # payload - выдает такие данные
  # {"message_id":335409,"from":{"id":377884669,"is_bot":false,
  # "first_name":"Асхаб Алхазуров | Чат-боты | Python | Ruby",
  # "username":"AshabAl","language_code":"ru","is_premium":true},
  # "chat":{"id":377884669,
  # "first_name":"Асхаб Алхазуров | Чат-боты | Python | Ruby",
  # "username":"AshabAl","type":"private"},
  # "date":1698134713,"text":"asd"}

  # session[:user]

  def start!(*)
    menu
  end

  def update_bonus_users!
    respond_with :message,
                  text: "Начало обновления бонусов"

    users_to_update = User.where('bonus < ?', 2)
    respond_with :message,
                  text: "Пользователи которые нашлись: #{users_to_update.to_a.size}"
    users_to_update.update_all(bonus: 2)
    respond_with :message,
                  text: "Обновление бонусов завершилось успешно!\n\n" \
                        "Всего пользователей в боте: #{User.all.size}"
  end

  def payment_verification(data)
    result_check_paid = Yookassa.payments.find(payment_id: data[:payment_id])
    if result_check_paid[:status] == "succeeded"
      @user.update({:point => @user.point + result_check_paid[:metadata][:quantity_points].to_i})
      answer_callback_query 'Платеж успешно прошёл! 🔋🎉', show_alert: true
      bot.edit_message_text text: "Поздравляю! Платеж успешно прошёл! 🔋🎉\n" \
                                  "Вам зачислено #{result_check_paid[:metadata][:quantity_points].to_i} поинтов. 💳\n\n",
                          message_id: data[:message_id],
                          chat_id: @user.platform_id   
      menu                    
    else
      respond_with :message,
                  text: "Похоже, ваш платеж не был подтвержден. 😕 \n\n" \
                        "Если вы уже произвели оплату и видите это сообщение, пожалуйста, подождите 5 минут. ⏳ И попробуйте снова нажать на кнопку \"Проверить платеж\"\n\n" \
                        "Если вы подождали 5 минут и проблема не решена, обратитесь к администратору @AshabAl. 📬"                 
    end
  end

  def create_payment(data)
    puts "Создания платежа create_payment"
    pay_data = {
      amount: {
          value:    data[:cost],
          currency: 'RUB'
      },
      capture:      true,
      confirmation: {
          type:       'redirect',
          return_url: 'https://t.me/infobizaa_bot'
      },
      receipt: {
        customer: {
          email: "#{data[:email]}"
        },
        items: [
          {
            "description": "#{data[:description]}",
            "quantity": "1",
            "amount": {
              "value": "#{data[:cost]}",
              "currency": "RUB"
            },
            "vat_code": "1"
          }
        ]
      },
      metadata: {
        platform_id: "#{@user.platform_id}",
        email: "#{@user.email}",
        quantity_points: "#{data[:quantity_points]}"
      }
    }

    payment = Yookassa.payments.create(payment: pay_data)
    
    bot.delete_message(chat_id: @user.platform_id, 
                       message_id: session[:create_payment_message_id]) unless session[:create_payment_message_id].blank?
    bot.delete_message(chat_id: @user.platform_id, message_id: session[:by_points_message_id])
  
    result_send_message = respond_with :message,
                                        text: "Не забудьте нажать кнопку \"Проверить платеж\" после совершения оплаты.\n" \
                                              "Это необходимо для подтверждения вашей транзакции. 🌟 \n\n" \
                                              "💎 Количество поинтов: #{data[:quantity_points]}\n" \
                                              "🔋Стоимость: #{data[:cost].to_i}₽\n\n" \
                                              "Ссылка для оплаты - #{payment.confirmation.confirmation_url}",
                                        reply_markup: {
                                          inline_keyboard: [[{ text: 'Проверить платеж', callback_data: "pay_id_#{payment.id}" }]]
                                        }

    session[:create_payment_message_id] = result_send_message['result']['message_id'] 

    bot.edit_message_text text: "Не забудьте нажать кнопку \"Проверить платеж\" после совершения оплаты.\n" \
                                "Это необходимо для подтверждения вашей транзакции. 🌟 \n\n" \
                                "💎 Количество поинтов: #{data[:quantity_points]}\n" \
                                "🔋Стоимость: #{data[:cost].to_i}₽\n\n" \
                                "Ссылка для оплаты - #{payment.confirmation.confirmation_url}",
                          message_id: result_send_message['result']['message_id'],
                          chat_id: @user.platform_id,
                          reply_markup: {
                            inline_keyboard: [
                              [{ text: 'Проверить платеж', 
                                callback_data: "pay_id_#{payment.id}_mes_id_#{result_send_message['result']['message_id']}" }]
                            ]
                          } 
  end

  def main_menu!
    menu
  end

  def menu(value = nil, *)
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
      respond_with :message, text: 'Это главное меню чат-бота', reply_markup: {
        keyboard: [['Поинты 💎', 'Реклама ✨', 'Помощь ⚙️'], ['Категории 🧲']],
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true
      }
    end
  end

  def points
    points_message = respond_with :message,
                 text: "#{from['first_name']}\n\n" \
                       "🔍 Ваш баланс: #{@user.point} \n" \
                       "🎁 Бонусные: #{@user.bonus} \n\n" \
                       '(Два бонусных поинта предоставляются бесплатно каждые 24 часа)',
                 reply_markup: {
                   inline_keyboard: [[{ text: 'Купить поинты',
                                        callback_data: 'Купить поинты' }]]
                 }
    session[:by_points_message_id] = points_message['result']['message_id']
  end

  def get_the_mail(*args)
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
          respond_with :message,
                        text: "Некорректная почта. Напишите еще раз"
      end
                                                                       
    else 
      save_context :get_the_mail 
      respond_with :message,
      text: "Напишите свою почту в этот чат"
    end
  end

  def by_points
    if @user.email
      choice_tarif
    else
      get_the_mail
    end
  end

  def choice_tarif
    bot.edit_message_text text: "Ваша почта: #{@user.email}\n\n" \
                                "Выберите тариф",
                          message_id: session[:by_points_message_id],
                          chat_id: @user.platform_id,
                          reply_markup: {
                            inline_keyboard: [
                              [{ text: '💎 20 поинтов - 100₽', callback_data: '20 поинтов' }],
                              [{ text: '💎 100 поинтов - 400₽', callback_data: '100 поинтов' }]
                            ]
                          }            
  end

  def choice_help
    respond_with :message, text: "👉⚡️ Инструкция:\n\n" \
                                 "1️⃣ Нажми \"Категории 🧲\" для старта ✅\n\n" \
                                 "2️⃣ Выбери свою область 💼\n" \
                                 "🔹 Получай интересные предложения мгновенно\n\n" \
                                 "3️⃣ В разделе \"Поинты 💎\" проверь баланс\n" \
                                 "🔹 Поинты - валюта для доступа к контактам ⚜️\n" \
                                 "🔹 Ежедневно 2 бесплатных поинта\n\n" \
                                 'Готовы к новым возможностям? "Категории 🧲" - и вперёд!'
  end

  def marketing
    text = ""
    Category.all.each_with_index do |category, index|
      text += "#{index+1}. #{category.name}: #{category.user.size}\n"
    end
    respond_with :message, text: "(Еще в разработке)\n\n" \
                                 "Количество пользователей в боте:\n" + text                             
  end

  def choice_category
    category_send_message = respond_with :message,
                                         text: "Выберите категории \n" \
                                               "(Просто нажмите на интересующие кнопки)\n\n" \
                                               "🔋 - означает что категория выбрана\n" \
                                               "\u{1FAAB} - означает что категория НЕ выбрана",
                                         reply_markup: formation_of_category_buttons

    session[:category_message_id] = category_send_message['result']['message_id']
  end

  def callback_query(data_callback)
    respond_with :message, text: "Нажали на кнопку: #{data_callback}"

    puts "Нажали на кнопку: #{data_callback}"

    case data_callback
    when 'Выбрать категории'
      choice_category
    when 'Купить поинты'
      by_points
    when 'Поменять почту'
      get_the_mail
    when 'Все четко'
      @user.update({:email => session[:email]})
      choice_tarif
    when '20 поинтов'
      create_payment({
        :cost => 100.00,
        :email => @user.email,
        :description => "20 поинтов",
        :quantity_points => 20
      })
    when '100 поинтов'
      create_payment({
        :cost => 400.00,
        :email => @user.email,
        :description => "100 поинтов",
        :quantity_points => 100
      })
    when /mid_\d+_bdid_\d+/
      data_scan = data_callback.scan(/\d+/)
      open_a_vacancy({ :message_id => data_scan[0], :vacancy_id => data_scan[1] })
    when /pay_id_\S+/
      match_data = data_callback.scan(/pay_id_(\w+-\w+-\w+-\w+-\w+)_.*mes_id_(\d+)/)
      payment_verification({
        :payment_id => match_data[0][0],
        :message_id => match_data[0][1]
      })
    end
    category = Category.find_by(name: data_callback)
    checking_subscribed_category(category.id) if category
  end

  def message(_message)
    menu
  end

  private

  def load_user
    @user = User.find_by_platform_id(payload['from']['id'])
    unless @user
      @user = User.new(user_params(payload))
      if @user.save
        bot.send_message(chat_id: 377884669, 
        text: "Новый пользователь в боте\n\n" \
              "Имя: #{@user.name}\n" \
              "username: @#{@user.username}\n\n" \
              "Всего пользователей в боте: #{User.all.size}"
        )
      else
        respond_with :message, text: 'Вы не сохранились в бд'
      end
    end
    subscriptions = @user.subscriptions.includes(:category)
    @subscribed_categories = subscriptions.map(&:category)
  end

  def user_params(data)
    {
      username: data['from']['username'],
      platform_id: data['from']['id'],
      name: data['from']['first_name'],
      point: 0,
      bonus: 2
    }
  end

  def formation_of_category_buttons
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

    {inline_keyboard: buttons}
  end

  def edit_message_category
    bot.edit_message_text(text: "Выберите категории \n" \
                                "(Просто нажмите на интересующие кнопки)\n\n" \
                                "🔋 - означает что категория выбрана\n" \
                                "\u{1FAAB} - означает что категория НЕ выбрана",
                          message_id: session[:category_message_id],
                          chat_id: @user.platform_id,
                          reply_markup: formation_of_category_buttons)
  end

  def checking_subscribed_category(category_id)
    target_category = Category.find(category_id)

    if @subscribed_categories.include?(target_category)
      unsubscribe_user_from_category(target_category)
    else
      subscribe_user_to_category(target_category)
    end
    edit_message_category
  end

  def subscribe_user_to_category(category)
    @user.subscriptions.create(category: category)
  end

  def unsubscribe_user_from_category(category)
    @user.subscriptions.find_by(category: category)&.destroy
  end

  def open_a_vacancy(data)
    vacancy = Vacancy.find(data[:vacancy_id])
    text_formation = "Категория: #{vacancy.category_title}\n\n" \
                     "#{vacancy.description}\n\n" \
                     "Контакты:\n" \
                     "#{vacancy.contact_information}"

    if @user.bonus > 0
      update_point_send_messag(text_formation, {:bonus => @user.bonus - 1}, data[:message_id])
    elsif @user.point > 0
      update_point_send_messag(text_formation, {:point => @user.point - 1}, data[:message_id])
    else
      answer_callback_query "У вас закончились поинты \u{1FAAB}\n\n" \
                            "Покупка поинтов - выгодное вложение!" \
                            "💎 Бонусный счет: #{@user.bonus}\n" \
                            "💎 Платный счет: #{@user.point}\n", 
                            show_alert: true
    end
  end

  def update_point_send_messag(text, data, message_id)
    bot.edit_message_text(text: text,
                          message_id: message_id,
                          chat_id: @user.platform_id,
                          reply_markup: {})
    @user.update(data)
  end

  def session_key
    "#{bot.username}:#{from ? "from:#{from['id']}" : "chat:#{chat['id']}"}"
  end
end
