# Вакантист: Telegram-бот для получения вакансий

Вакантист — это Telegram-бот, который позволяет пользователям подписываться на вакансии по интересующим категориям и получать уведомления о новых предложениях.

## Как работает бот?

1. Пользователь заходит в бота: [Перейти к рабочему боту](https://t.me/infobizaa_bot).
2. Нажимает на кнопку «Категории».
3. Выбирает нужные категории вакансий.
4. После выбора категорий пользователь сразу получает ранее опубликованные вакансии и начинает получать новые вакансии по выбранным тематикам.

## Установка и запуск проекта

Следуйте этим шагам, чтобы запустить бота на своем устройстве:

### 1. Настройка бота и ключей
- Скачайте проект.
- В файле `config/secrets.yml` добавьте токен вашего Telegram-бота и ID чата, в который будут отправляться ошибки.

### 2. Установка Ngrok
- Для работы вебхуков установите Ngrok: [Инструкция по установке Ngrok](https://ngrok.com/docs/getting-started/).

### 3. Настройка Docker
- Файл `docker-compose.yml` для режима разработки должен иметь следующую конфигурацию:

  ```yaml
  services:
    db:
      image: postgres
      volumes:
        - ./tmp/db:/var/postgresql/data
      environment:
        POSTGRES_PASSWORD: password
    tgbot:
      build: .
      command: bash -c "bin/rake telegram:bot:poller"
      volumes:
        - .:/chatbottg
    web:
      build: .
      command: bash -c "rm -f tmp/pids/server.pid && RAILS_ENV=development bundle exec rails s -p 3000 -b '0.0.0.0'"
      volumes:
        - .:/chatbottg
      ports:
        - "3000:3000"
      depends_on:
        - db
        - tgbot
    ngrok:
      image: ngrok/ngrok:latest
      command:
        - "http"
        - "web:3000"  
      environment:
        NGROK_AUTHTOKEN: "Ваш_Token"
      ports:
        - "4040:4040"

### 4. Запуск приложения
- Выполните команды:
```bash
docker compose build
docker compose up
```
После запуска бот будет доступен. Чтобы остановить приложение, нажмите `Ctrl + C`в консоли или выполните команду:
```bash
docker compose stop
```
### Примечание
- Убедитесь, что токен для Ngrok заменен на ваш личный NGROK_AUTHTOKEN.
- Проект использует PostgreSQL в качестве базы данных и предполагает, что у вас установлена Docker среда.
