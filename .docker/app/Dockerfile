FROM harbor.k8s.temple.edu/library/ruby:2.7-alpine

WORKDIR /app

COPY . .

USER root

ARG RAILS_MASTER_KEY

RUN apk add -U --no-cache \
      bash=5.1.0-r0 \
      libxslt=1.1.34-r0 \
      tzdata=2021a-r0 \
      shared-mime-info=2.0-r0 && \
    apk add -U --no-cache --virtual build-dependencies \
      git=2.30.2-r0 \
      build-base=0.5-r2 \
      libxslt-dev=1.1.34-r0 \
      sqlite-dev=3.34.1-r0 \
      nodejs=14.16.1-r1 \
      yarn=1.22.10-r0 && \
    gem update --system && \
    gem install bundler:2.2.17 && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle install && \
    yarn install --check-files && \
    bundle exec rails assets:precompile && \
    yarn cache clean && \
    chown nobody -R /app/db && \
    chown nobody -R /app/tmp && \
    chown nobody -R /app/log

USER nobody

ENTRYPOINT [".docker/app/entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
