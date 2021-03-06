FROM ruby:3.0.0-alpine

RUN apk update && apk --no-cache add build-base postgresql-dev tzdata git bash nodejs postgresql-client

RUN mkdir -p /app/tmp/pids

COPY Gemfile* /tmp/

ARG GIT_COMMIT
ENV GIT_COMMIT $GIT_COMMIT

WORKDIR /tmp

RUN gem install bundler -v 2.2.11 && bundle install -j 4 --full-index --without development test

WORKDIR /app

COPY . /app

CMD bundle exec puma -C config/puma.rb
