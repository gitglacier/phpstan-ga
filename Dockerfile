FROM php:7.4-cli

LABEL "com.github.actions.name"="OSKAR-phpstan"
LABEL "com.github.actions.description"="phpstan"
LABEL "com.github.actions.icon"="check"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="http://github.com/oskarstark/phpstan-ga"
LABEL "homepage"="http://github.com/actions"
LABEL "maintainer"="Oskar Stark <oskarstark@googlemail.com>"

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN mkdir /composer
ENV COMPOSER_HOME=/composer

RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini

# https://github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN install-php-extensions bcmath intl memcached ssh2 gd zip
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git unzip wget

ENV REVIEWDOG_VERSION=v0.10.0
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
