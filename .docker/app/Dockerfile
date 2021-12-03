# FROM harbor.k8s.temple.edu/library/ruby:2.7-alpine
FROM harbor.k8s.temple.edu/library/ruby@sha256:26bc67d442972808126abb9b986af02b958891776c3261a2323f2ed9da32b8ca

WORKDIR /app

COPY . .

USER root

ARG RAILS_MASTER_KEY
ARG SPOTLIGHT_DB_USER
ARG SPOTLIGHT_DB_PASSWORD

RUN apk add -U --no-cache \
      bash=5.1.4-r0 \
      libxslt=1.1.34-r1 \
      tzdata=2021e-r0 \
      shared-mime-info=2.1-r0 \
      imagemagick=7.0.11.14-r0 \
      mariadb-connector-c=3.1.13-r0 && \
    apk add -U --no-cache --virtual build-dependencies \
      git=2.32.0-r0 \
      build-base=0.5-r2 \
      libxslt-dev=1.1.34-r1 \
      mariadb-dev=10.5.13-r0 \
      mariadb-client=10.5.13-r0 \
      python3=3.9.5-r2 \
      nodejs=14.18.1-r0 \
      yarn=1.22.10-r0 && \
    python3 -m ensurepip && \
    gem install bundler:2.2.18 && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle config set --local without "development test" && \
    bundle install --jobs=8 && \
    find "$GEM_HOME" -name Gemfile.lock -exec rm "{}" \; && \
    find "$GEM_HOME" -name yarn.lock -exec rm "{}" \; && \
    RAILS_ENV=production RAILS_MASTER_KEY=$RAILS_MASTER_KEY bundle exec rails assets:precompile && \
    cp /app/my.cnf /.my.cnf && chmod 600 /.my.cnf && chown nobody:nobody /.my.cnf && \
    sed -i -r "s/DB_USER/${SPOTLIGHT_DB_USER}/g" /.my.cnf && sed -i -r "s/DB_PASSWORD/$SPOTLIGHT_DB_PASSWORD/g" /.my.cnf && \
    cp /app/dbdumptos3 /usr/local/bin/dbdumptos3 && chmod a+rx /usr/local/bin/dbdumptos3 && chown root:root /usr/local/bin/dbdumptos3 && \
    pip3 install awscli==1.22.19 && \
    chmod +x .docker/app/entrypoint.sh && \
    rm -rf node_modules && \
    rm -rf /var/cache/apk/ && \
    chown nobody -R /app/db && \
    chown nobody -R /app/public && \
    chown nobody -R /app/tmp && \
    chown nobody -R /app/log

USER nobody

ENTRYPOINT [".docker/app/entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
