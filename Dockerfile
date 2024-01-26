FROM ruby:3.0.0

# Используйте базовый образ с Alpine Linux
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client cron
WORKDIR /chatbottg


# Install application gems
ENV BUNDLE_PATH="/usr/local/bundle"

COPY Gemfile /chatbottg/Gemfile
COPY Gemfile.lock /chatbottg/Gemfile.lock
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]

EXPOSE 3000

CMD ["rails", "start", "-b", "0.0.0.0"]