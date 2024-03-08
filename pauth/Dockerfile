FROM ruby:3.2.2

RUN mkdir -p /app
WORKDIR /app

COPY ./pauth/Gemfile  /app/Gemfile
COPY ./pauth/Gemfile.lock /app/Gemfile.lock

RUN gem install rails bundler
RUN cd /app
RUN bundle install
EXPOSE 3000
CMD ["rails", "server"]
