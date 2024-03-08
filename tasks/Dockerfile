FROM ruby:3.2.2

RUN mkdir -p /app
WORKDIR /app

COPY ./tasks/Gemfile  /app/Gemfile
COPY ./tasks/Gemfile.lock /app/Gemfile.lock

RUN gem install rails bundler
RUN bundle install
EXPOSE 3001
CMD ["rails", "server"]