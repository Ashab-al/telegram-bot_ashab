FROM ruby:3.0.0

RUN apt-get update -qq && \ 
    apt-get install --no-install-recommends -y nodejs postgresql-client build-essential \ 
    git libpq-dev libvips pkg-config curl gnupg2 nano
    

WORKDIR /chatbottg

COPY Gemfile /chatbottg/Gemfile
COPY Gemfile.lock /chatbottg/Gemfile.lock

RUN bundle install

COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]