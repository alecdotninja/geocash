FROM ruby:2.3.1

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN useradd -d /app -m -r -s /bin/bash app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN chown -R app /app

USER app
RUN bundle install
ENTRYPOINT ["bundle", "exec"]
