# Example telegram bot app

This app uses [telegram-bot](https://github.com/telegram-bot-rb/telegram-bot) gem.
Want to see the [bot code](https://github.com/telegram-bot-rb/telegram_bot_app/blob/master/app/controllers/telegram_webhooks_controller.rb)
first?

Explore separate commits to check evolution of code.

Want a clean setup instead?
Here is [app teamplate](https://github.com/telegram-bot-rb/rails_template) to help you.


## Run

### Development

```
bin/rake telegram:bot:poller
```

### Production

One way is just to run poller. You don't need anything else, just check
your production secrets & configs. But there is better way: use webhooks.

__You may want to use different token: after you setup the webhook,
you need to unset it to run development poller again.__

First you need to setup the webhook. There is rake task for it,
but you're free to set it manually with API call.
To use rake task you need to set host in `routes.default_url_options`
for production environment (`config.routes` for Rails < 5).
There is already such line in the repo in `production.rb`.
Uncomment it, change the values, and you're ready for:

```
bin/rake telegram:bot:set_webhook RAILS_ENV=production
```

Now deploy your app in any way you like. You don't need run anything special for bot,
but `rails server` as usual. Your rails app will receive webhooks and bypass them
to bot's controller.

By default session is configured to use FileStore at `Rails.root.join('tmp', 'session_store')`.
To use it in production make sure to share this folder between releases
(ex., add to list shared of shared folders in capistrano).
Read more about different session stores in
[original readme](https://github.com/telegram-bot-rb/telegram-bot#session).

# telegram-bot_ashab
