class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  
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
    @user = User.find_by_platform_id(payload["from"]["id"])
    if @user
      session[:user] = @user 
    else
      @user = User.new(user_params(payload))
      if @user.save
        respond_with :message, text: "Создан пользователь"
        @user.category.new({:cat_1 => 0, :cat_2 => 0}).save
        
      else
        respond_with :message, text: "Вы не сохранились в бд"
      end
    end
    
    menu()
  end

  def main_menu!
    menu()
  end

  def menu(value = nil, *)
    save_context :menu
    # respond_with :message, text: "Это главное меню чат-бота", reply_markup: {
    #   inline_keyboard: [
    #     [
    #       {text: "Выбрать категории", callback_data: 'Выбрать категории'}
    #     ],
    #     [
    #       {text: "Канал автора", url: 'https://t.me/asxabal'}
    #     ]
    #   ]
    # }

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
    respond_with :message, text: "Всего количество пользователей в боте: #{User.all.size}"
  end

  def choice_category
    respond_with :message, text: "Выберите категории", reply_markup: {
      inline_keyboard: [
        [
          {text: "Тех-спец 🪫", callback_data: 'no_alert'},
          {text: "Сайты 🪫", callback_data: 'no_alert'}
        ],
        [
          {text: "Таргет 🪫", callback_data: 'no_alert'},
          {text: "Копирайт 🪫", callback_data: 'no_alert'}
        ],
        [
          {text: "Дизайн 🪫", callback_data: 'no_alert'},
          {text: "Ассистент 🪫", callback_data: 'no_alert'}
        ],
        [
          {text: "Маркетинг 🪫", callback_data: 'no_alert'},
          {text: "Продажи 🪫", callback_data: 'no_alert'}
        ]
      ],
    }
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
    when 'no_alert'
      answer_callback_query t('.no_alert')
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

  # As there is no chat id in such requests, we can not respond instantly.
  # So we just save the result_id, and it's available then with `/last_chosen_inline_result`.
  def chosen_inline_result(result_id, _query)
    session[:last_chosen_inline_result] = result_id
  end

  def last_chosen_inline_result!(*)
    result_id = session[:last_chosen_inline_result]
    if result_id
      respond_with :message, text: t('.selected', result_id: result_id)
    else
      respond_with :message, text: t('.prompt')
    end
  end

  def message(message)
    respond_with :message, text: t('.content', text: message['text'])
  end

  def action_missing(action, *_args)
    if action_type == :command
      respond_with :message,
        text: t('telegram_webhooks.action_missing.command', command: action_options[:command])
    end
  end

  def rename!(*)
    # set context for the next message
    save_context :rename_from_message
    respond_with :message, text: 'What name do you like?'
  end

  # register context handlers to handle this context
  def rename_from_message(message)
    
    respond_with :message, text: "Renamed! #{message}"
  end

  

  private

  # In this case session will persist for user only in specific chat.
  # Same user in other chat will have different session.
  def session_key
    "#{bot.username}:#{chat['id']}:#{from['id']}" if chat && from
  end

  def user_params(data)
    {
      :username => data["from"]["username"],
      :platform_id => data["from"]["id"],
      :name => data["from"]["first_name"]
    }
  end
end
