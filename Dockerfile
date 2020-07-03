FROM ruby:2.3.4-onbuild

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN bundle install

CMD ["$@"]
