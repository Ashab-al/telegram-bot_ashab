class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::ReplyHelpers
  before_action :load_user # потом ограничить , only: [:example] или  except: [:example]
  # bin/rake telegram:bot:poller   запуск бота

  # chat - выдает такие данные 
  # {"id":377884669,"first_name":"Асхаб Алхазуров | Чат-боты | Python | Ruby",
  # "username":"AshabAl","type":"private"}

  # from - выдает такие данные 
  #{"id":377884669,"is_bot":false,
  #"first_name":"Асхаб Алхазуров | Чат-боты | Python | Ruby",
  #"username":"AshabAl","language_code":"ru","is_premium":true}

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
    unless @user
      @user = User.new(user_params(payload))
      if @user.save
        # @user.category.new(category_defolt_params).save
        p "GOOD"
      else
        respond_with :message, text: "Вы не сохранились в бд"
      end
    end 

    # p @category = Category.all[1]
    # Subscription.create(user: @user, category: @category).save
    # Category.all.each {|cat| 
    #   p @user.subscriptions.all.include?(cat.subscriptions[0])
    # }
    res = respond_with :message, text: "Это главное меню чат-бота"
    p res

    bot.edit_message_text(text: "Новый текст", 
                          message_id: res["result"]["message_id"],
                          chat_id: res["result"]["chat"]["id"],
                          reply_markup: formation_of_category_buttons())
    menu()
  end

  def main_menu!
    menu()
  end

  def menu(value = nil, *)
    save_context :menu

    case value
    when "Категории"
      choice_category()
    when "Реклама"
      marketing()
    else
      respond_with :message, text: "Это главное меню чат-бота", reply_markup: {
        keyboard: [["Категории 🧲", "Поинты 💎", "Помощь ⚙️"], ["Реклама ✨"]],
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true,
      }
    end
  end

  def marketing
    respond_with :message, text: "Всего количество пользователей в боте: #{User.all.size}\n"+
                                 "Выбраны направления:\n" + 
                                 "Тех-спец: #{Category.all[0].user.size}"
  end

  def choice_category
    category_send_message = respond_with :message, 
                                          text: "Выберите категории \n"+
                                                "(Просто нажмите на интересующие кнопки)\n\n" + 
                                                "🔋 - означает что категория выбрана\n" +
                                                "🪫 - означает что категория НЕ выбрана", 
                                          reply_markup: formation_of_category_buttons

    session[:category_message_id] = category_send_message["result"]["message_id"]
    session[:chat_id] = category_send_message["result"]["chat"]["id"]
    p category_send_message
    p session[:chat_id]
  end

  def help!(*)
    respond_with :message, text: t('.content')
  end

  def test!(*args)
    # save_context :test!
    respond_with :message, text: payload
    p session[:user] #<User id: 2, name: "Асхаб Алхазуров | Чат-боты | Python | Ruby", username: "AshabAl", email: nil, phone: nil, platform_id: 377884669, created_at: "2023-11-11 15:20:49.468134000 +0000", updated_at: "2023-11-11 15:20:49.468134000 +0000">

  end

  def memo!(*args)
    if args.any?
      session[:memo] = args.join(' ')
      puts session[:memo]
      p session
      respond_with :message, text: t('.notice')
    else
      respond_with :message, text: t('.prompt')
      save_context :memo!
    end
  end

  def remind_me!(*)
    to_remind = session.delete(:memo)
    reply = to_remind || t('.nothing')
    respond_with :message, text: reply
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
        selective: true,
      }
    end
    p [t('.buttons')]
  end

  def inline_keyboard!(*)
    respond_with :message, text: t('.prompt'), reply_markup: {
      inline_keyboard: [
        [
          {text: t('.alert'), callback_data: 'alert'},
          {text: t('.no_alert'), callback_data: 'no_alert'},
        ],
        [{text: t('.repo'), url: 'https://github.com/telegram-bot-rb/telegram-bot'}],
      ],
    }
  end

  def callback_query(data)
    case data
    when 'alert'
      answer_callback_query "data", show_alert: true
    when 'Выбрать категории'
      choice_category()

    when 'Тех-спец'
      checking_subscribed_category(0)
      edit_message_category

    when 'Сайты'
      checking_subscribed_category(1)
      edit_message_category

    when 'Таргет'
      checking_subscribed_category(2)
      edit_message_category

    when 'Копирайт'
      checking_subscribed_category(3)
      edit_message_category

    when 'Дизайн'
      checking_subscribed_category(4)
      edit_message_category

    when 'Ассистент'
      checking_subscribed_category(5)
      edit_message_category
    when 'Маркетинг'
      checking_subscribed_category(6)
      edit_message_category
    when 'Продажи'
      checking_subscribed_category(7)
      edit_message_category
    # when 'no_alert'
    #   answer_callback_query t('.no_alert')
    end
  end

  def inline_query(query, _offset)
    query = query.first(10) # it's just an example, don't use large queries.
    t_description = t('.description')
    t_content = t('.content')
    results = Array.new(5) do |i|
      {
        type: :article,
        title: "#{query}-#{i}",
        id: "#{query}-#{i}",
        description: "#{t_description} #{i}",
        input_message_content: {
          message_text: "#{t_content} #{i}",
        },
      }
    end
    answer_inline_query results
  end


  def message(message)
    respond_with :message, text: t('.content', text: message['text'])
  end

  # register context handlers to handle this context
  def rename_from_message(message)
    
    respond_with :message, text: "Renamed! #{message}"
  end

  private

  def load_user
    @user = User.find_by_platform_id(payload["from"]["id"])
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
          {text: "Тех-спец #{@subscribed_categories.include?(all_category[0]) ? "🔋" : "🪫"}", callback_data: 'Тех-спец'},
          {text: "Сайты #{@subscribed_categories.include?(all_category[1]) ? "🔋" : "🪫"}", callback_data: 'Сайты'}
        ],
        [
          {text: "Таргет #{@subscribed_categories.include?(all_category[2]) ? "🔋" : "🪫"}", callback_data: 'Таргет'},
          {text: "Копирайт #{@subscribed_categories.include?(all_category[3]) ? "🔋" : "🪫"}", callback_data: 'Копирайт'}
        ],
        [
          {text: "Дизайн #{@subscribed_categories.include?(all_category[4]) ? "🔋" : "🪫"}", callback_data: 'Дизайн'},
          {text: "Ассистент #{@subscribed_categories.include?(all_category[5]) ? "🔋" : "🪫"}", callback_data: 'Ассистент'}
        ],
        [
          {text: "Маркетинг #{@subscribed_categories.include?(all_category[6]) ? "🔋" : "🪫"}", callback_data: 'Маркетинг'},
          {text: "Продажи #{@subscribed_categories.include?(all_category[7]) ? "🔋" : "🪫"}", callback_data: 'Продажи'}
        ]
      ],
    }
  end

  def edit_message_category
    bot.edit_message_text(text: "Выберите категории \n"+
                                "(Просто нажмите на интересующие кнопки)\n\n" + 
                                "🔋 - означает что категория выбрана\n" + 
                                "🪫 - означает что категория НЕ выбрана", 
                          message_id: session[:category_message_id],
                          chat_id: session[:chat_id],
                          reply_markup: formation_of_category_buttons)
  end

  def checking_subscribed_category(category_id)
    all_category = Category.all
    unless @subscribed_categories.include?(all_category[category_id])
      Subscription.create(user: @user, category: all_category[category_id])
    else
      @user.subscriptions.each {|user_subscriptions|
        if user_subscriptions.category == all_category[category_id]
          user_subscriptions.destroy
        end
      }
    end
  end

  def user_params(data)
    {
      :username => data["from"]["username"],
      :platform_id => data["from"]["id"],
      :name => data["from"]["first_name"]
    }
  end
end
