# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  
  before_action :load_user # потом ограничить , only: [:example] или  except: [:example]
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

  def send_custom_message(message_text, chat_id)
    respond_with :message, text: message_text, chat_id: chat_id
  end

  def create_payment(data)
    pay_data = {
      amount: {
          value:    data[:cost],
          currency: 'RUB'
      },
      capture:      true,
      confirmation: {
          type:       'redirect',
          return_url: 'https://yookassa.ru/'
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
      }
    }

    payment = Yookassa.payments.create(payment: pay_data)
    puts "=========== СОЗДАНИЕ ПЛАТЕЖА ============="
    p payment.confirmation.confirmation_url
    p payment.confirmation
    p payment
    
    respond_with :message, text: "#{payment.confirmation.confirmation_url}"
  end

  def main_menu!
    p default_url_options[:locale]
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
        keyboard: [['Категории 🧲', 'Поинты 💎', 'Помощь ⚙️'], ['Реклама ✨']],
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true
      }
    end
  end

  def points
    respond_with :message,
                 text: "#{from['first_name']}\n\n" \
                       "🔍 Ваш баланс: #{@user.point} \n" \
                       "🎁 Бонусные: #{@user.bonus} \n\n" \
                       '(Два бонусных поинта предоставляются бесплатно каждые 24 часа)',
                 reply_markup: {
                   inline_keyboard: [[{ text: 'Купить поинты',
                                        callback_data: 'Купить поинты' }]]
                 }
  end

  def get_the_mail(*args)
    save_context :get_the_mail 
    if args.any?
      session[:email] = args.first
      case session[:email]
        when /^[-\w.]+@([A-z0-9][-A-z0-9]+\.)+[A-z]{2,4}$/
          get_the_mail_message = respond_with :message, 
                   text: "Ваша почта: #{args.first}",
                   reply_markup: {inline_keyboard: [[{ text: 'Поменять почту', callback_data: 'Поменять почту' }],
                                                    [{ text: 'Все четко✅', callback_data: 'Все четко' }]]}
          session[:get_the_mail_message_id] = get_the_mail_message['result']['message_id']
          session[:get_the_mail_chat_id] = get_the_mail_message['result']['chat']['id'] 
        else  
          respond_with :message,
                        text: "Некорректная почта. Напишите еще раз"
      end
                                                 
                                           
    elsif @user.email
      respond_with :message,
      text: "Вот ссылка на оплату открывашек"
    else 
      respond_with :message,
      text: "Напишите свою почту в этот чат"
    end
  end

  def choice_tarif
    bot.edit_message_text text: "Ваша почта: #{session[:email]}\n\n" \
                                "Выберите тариф",
                          message_id: session[:get_the_mail_message_id] ,
                          chat_id: session[:get_the_mail_chat_id],
                          reply_markup: {
                            inline_keyboard: [
                              [{ text: '💎 20 поинтов - 100₽', callback_data: '20 поинтов' }],
                              [{ text: '💎 100 поинтов - 400₽', callback_data: '100 поинтов' }]
                            ]
                          }      
    # RestClient.get 'https://api.telegram.org/bot5127742801:AAHNyXy90gXJlzOWNLF67O5CZjlYlM3Y-0g/НАЗВАНИЕ_МЕТОДА', 
    #                 {params: {id: 50, 'foo' => 'bar'}}        
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
    puts text
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

  def callback_query(data)
    category = Category.find_by(name: data)
    checking_subscribed_category(category.id) if category

    case data
    # when 'alert'
    #   answer_callback_query 'data', show_alert: true
    when 'Выбрать категории'
      choice_category
    when 'Купить поинты'
      get_the_mail
    when 'Поменять почту'
      get_the_mail
    when 'Все четко'
      @user.update({:email => session[:email]})
      choice_tarif
    when /mid_\d+_bdid_\d+/
      data_scan = data.scan(/\d+/)
      open_a_vacancy({ :message_id => data_scan[0], :vacancy_id => data_scan[1] })
    when '20 поинтов'
      create_payment({
        :cost => 10.00,
        :email => @user.email,
        :description => "20 поинтов"
      })
    when '100 поинтов'
      create_payment({
        :cost => 10.00,
        :email => @user.email,
        :description => "100 поинтов"
      })
    end
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
        p 'GOOD'
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
                          chat_id: chat["id"],
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
                          chat_id: chat["id"],
                          reply_markup: {})
    @user.update(data)
  end

  def default_url_options
    { locale: "http://www.example.com/" }
  end

  def session_key
    "#{bot.username}:#{from ? "from:#{from['id']}" : "chat:#{chat['id']}"}"
  end
end
