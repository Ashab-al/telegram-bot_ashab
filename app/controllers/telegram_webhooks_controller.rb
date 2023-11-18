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
                       "🔍 Ваш баланс: 0 отк\n" \
                       "🎁 Бонусные: 2 отк.\n\n" \
                       '(Две бонусные открывашки предоставляются бесплатно каждые 24 часа)',
                 reply_markup: {
                   inline_keyboard: [[{ text: 'Купить открывашки (не дорого)',
                                        callback_data: 'Купить открывашки (не дорого)' }]]
                 }
  end

  def buy_points
    respond_with :message,
                 text: "🔍 Твой баланс: 0 отк\n" \
                       "🎁 Бонусные: 2 отк.\n\n" \
                       '(Две бонусные открывашки предоставляются бесплатно каждые 24 часа)'
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
    respond_with :message, text: "(Еще в разработке)\n\n" \
                                 "Общее количество пользователей в боте: #{User.all.size} 🤝\n\n" \
                                 "Активные направления:\n" \
                                 "1. Тех-спец: #{Category.all[0].user.size} 👨‍💻\n" \
                                 "2. Сайты: #{Category.all[1].user.size} 🌐\n" \
                                 "3. Таргет: #{Category.all[2].user.size} 🚀\n" \
                                 "4. Копирайт: #{Category.all[3].user.size} 📝\n" \
                                 "5. Дизайн: #{Category.all[4].user.size} 🎨\n" \
                                 "6. Ассистент: #{Category.all[5].user.size} 🤖\n" \
                                 "7. Маркетинг: #{Category.all[6].user.size} 📣\n" \
                                 "8. Продажи: #{Category.all[7].user.size} 💼\n\n" \
                                 'Вместе мы сила! 💪'
  end

  def choice_category
    category_send_message = respond_with :message,
                                         text: "Выберите категории \n" \
                                               "(Просто нажмите на интересующие кнопки)\n\n" \
                                               "🔋 - означает что категория выбрана\n" \
                                               "\u{1FAAB} - означает что категория НЕ выбрана",
                                         reply_markup: formation_of_category_buttons

    session[:category_message_id] = category_send_message['result']['message_id']
    session[:chat_id] = category_send_message['result']['chat']['id']
  end

  def memo!(*args)
    if args.any?
      session[:memo] = args.join(' ')
      respond_with :message, text: t('.notice')
    else
      respond_with :message, text: t('.prompt')
      save_context :memo!
    end
  end

  def keyboard!(value = nil, *)
    if value
      respond_with :message, text: t('.selected', value: value)
    else
      save_context :keyboard!
      respond_with :message, text: t('.prompt'), reply_markup: {
        keyboard: [t('.buttons')],
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true
      }
    end
  end

  def inline_keyboard!(*)
    respond_with :message, text: t('.prompt'), reply_markup: {
      inline_keyboard: [
        [
          { text: t('.alert'), callback_data: 'alert' },
          { text: t('.no_alert'), callback_data: 'no_alert' }
        ],
        [{ text: t('.repo'), url: 'https://github.com/telegram-bot-rb/telegram-bot' }]
      ]
    }
  end

  def callback_query(data)
    category = Category.find_by(name: data)
    checking_subscribed_category(category.id) if category

    case data
    when 'alert'
      answer_callback_query 'data', show_alert: true
    when 'Выбрать категории'
      choice_category
    when 'Купить открывашки (не дорого)'
      buy_points
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

  def formation_of_category_buttons
    subscriptions = @user.subscriptions.includes(:category)
    @subscribed_categories = subscriptions.map(&:category)
    all_category = Category.all
    {
      inline_keyboard: [
        [
          { text: "Тех-спец #{@subscribed_categories.include?(all_category[0]) ? '🔋' : "\u{1FAAB}"}",
            callback_data: 'Тех-спец' },
          { text: "Сайты #{@subscribed_categories.include?(all_category[1]) ? '🔋' : "\u{1FAAB}"}",
            callback_data: 'Сайты' }
        ],
        [
          { text: "Таргет #{@subscribed_categories.include?(all_category[2]) ? '🔋' : "\u{1FAAB}"}",
            callback_data: 'Таргет' },
          { text: "Копирайт #{@subscribed_categories.include?(all_category[3]) ? '🔋' : "\u{1FAAB}"}",
            callback_data: 'Копирайт' }
        ],
        [
          { text: "Дизайн #{@subscribed_categories.include?(all_category[4]) ? '🔋' : "\u{1FAAB}"}",
            callback_data: 'Дизайн' },
          { text: "Ассистент #{@subscribed_categories.include?(all_category[5]) ? '🔋' : "\u{1FAAB}"}",
            callback_data: 'Ассистент' }
        ],
        [
          { text: "Маркетинг #{@subscribed_categories.include?(all_category[6]) ? '🔋' : "\u{1FAAB}"}",
            callback_data: 'Маркетинг' },
          { text: "Продажи #{@subscribed_categories.include?(all_category[7]) ? '🔋' : "\u{1FAAB}"}",
            callback_data: 'Продажи' }
        ]
      ]
    }
  end

  def edit_message_category
    bot.edit_message_text(text: "Выберите категории \n" \
                                "(Просто нажмите на интересующие кнопки)\n\n" \
                                "🔋 - означает что категория выбрана\n" \
                                "\u{1FAAB} - означает что категория НЕ выбрана",
                          message_id: session[:category_message_id],
                          chat_id: session[:chat_id],
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

  def user_params(data)
    {
      username: data['from']['username'],
      platform_id: data['from']['id'],
      name: data['from']['first_name'],
      point: 0,
      bonus: 2
    }
  end
end
