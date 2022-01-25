FROM harbor.k8s.temple.edu/library/ruby:2.7-alpine

WORKDIR /app

COPY . .

USER root

ARG RAILS_MASTER_KEY

RUN apk add -U --no-cache \
      bash=5.1.8-r0 \
      libxslt=1.1.34-r1 \
      tzdata=2021e-r0 \
      shared-mime-info=2.1-r0 \
      imagemagick=7.1.0.16-r0 \
      mariadb-connector-c=3.1.13-r2 && \
    apk add -U --no-cache --virtual build-dependencies \
      git=2.34.1-r0 \
      build-base=0.5-r2 \
      libxslt-dev=1.1.34-r1 \
      mariadb-dev=10.6.4-r2 \
      nodejs=16.13.2-r0 \
      yarn=1.22.17-r0 && \
    gem install bundler:2.2.33 && \
    gem update --system && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle config set --local without "development test" && \
    bundle install --jobs=8 && \
    find "$GEM_HOME" -name Gemfile.lock -exec rm "{}" \; && \
    find "$GEM_HOME" -name yarn.lock -exec rm "{}" \; && \
    RAILS_ENV=production RAILS_MASTER_KEY=$RAILS_MASTER_KEY bundle exec rails assets:precompile && \
    rm -rf node_modules && \
    rm -rf /var/cache/apk/ && \
    rm -rf /usr/local/lib/ruby/gems/2.7.0/specifications/default/cgi-0.1.0.1.gemspec && \
    rm -rf /usr/local/lib/ruby/gems/2.7.0/specifications/default/rdoc-6.2.1.1.gemspec && \
    rm -rf /usr/local/lib/ruby/gems/2.7.0/specifications/default/rexml-3.2.3.1.gemspec && \
    chown nobody -R /app/db && \
    chown nobody -R /app/public && \
    chown nobody -R /app/tmp && \
    chown nobody -R /app/log && \
    chmod +x .docker/app/entrypoint.sh

USER nobody

ENTRYPOINT [".docker/app/entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
