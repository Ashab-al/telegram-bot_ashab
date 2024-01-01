FROM ruby:3.0.0

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /chatbottg

COPY Gemfile /chatbottg/Gemfile
COPY Gemfile.lock /chatbottg/Gemfile.lock

RUN bundle install

COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]

EXPOSE 3000

CMD ["bin/dev", "-b", "0.0.0.0"]