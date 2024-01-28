# FROM ubuntu:24.04
FROM ruby:3.1.2

# Обновляем пакеты и устанавливаем необходимые зависимости
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apt-utils \
        nodejs \
        postgresql-client \
        libpq-dev \
        cron \
        make \
        g++ \
        git \
        openssl \
        curl \
        libssl-dev \
        libreadline-dev \
        gawk \
        libsqlite3-dev \
        libtool \
        pkg-config \
        libgmp-dev \
        zlib1g-dev \ 
        autoconf \
        bison \
        build-essential \
        libyaml-dev \
        libncurses5-dev \
        libffi-dev \
        libgdbm-dev \
        libyaml-0-2 \
        libgmp10 \
        libreadline8 \
        libz-dev \
        libncursesw5-dev \
        libffi-dev


WORKDIR /chatbottg

COPY Gemfile /chatbottg/Gemfile
COPY Gemfile.lock /chatbottg/Gemfile.lock
# RUN apt-get install -y ruby
# RUN gem install bundler
RUN bundle update && bundle install
RUN gem install rails -v 7.0.2
COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]