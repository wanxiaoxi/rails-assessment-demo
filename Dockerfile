FROM ruby:2.6.3-slim

RUN apt-get update -qq \
  && apt-get install -y \
  # Needed for certain gems
  build-essential \
  # Needed for postgres gem
  libpq-dev \
  # Others
  nodejs \
  vim-tiny \   
  # The following are used to trim down the size of the image by removing unneeded data
  && apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf \
  /var/lib/apt \
  /var/lib/dpkg \
  /var/lib/cache \
  /var/lib/log

ENV APP_HOME /rails_docker

RUN mkdir ${APP_HOME}
WORKDIR ${APP_HOME}

COPY Gemfile ${APP_HOME}/Gemfile
COPY Gemfile.lock ${APP_HOME}/Gemfile.lock

RUN gem install bundler -v 2.2.16
RUN bundle install

COPY . ${APP_HOME}

EXPOSE 8080

ENTRYPOINT ["sh", "./entrypoint.sh"]

# CMD bash -c "rm -f tmp/pids/server.pid && rails s -p 3000 -b '0.0.0.0'"