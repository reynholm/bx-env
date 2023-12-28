FROM php:8.1-fpm

ARG APCU_VERSION=5.1.22

ARG CONTAINER_GID
ARG CONTAINER_UID
ARG CONTAINER_USER
ARG CONTAINER_GROUP

ARG BX_XDEBUG_IP
ARG BX_XDEBUG_PORT
ARG BX_DEFAULT_CHARSET

ARG BX_SMTP_PORT
ARG BX_SMTP_FROM

RUN apt-get update \
    && apt-get install -y vim zip unzip default-mysql-client git msmtp \
    && echo "syntax on" > ~/.vimrc \
    && apt-get -y install \
        libmagickwand-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        memcached \
        libmemcached-dev \
        libicu-dev \
        libzip-dev \
        zlib1g-dev \
        libpng-dev \
        libxml2-dev \
        libpq-dev \
        --no-install-recommends \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pgsql pdo_pgsql mysqli pdo_mysql opcache exif intl sockets bz2 zip \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-source extract \
    && mkdir -p /usr/src/php/ext/apcu \
    && curl -fsSL https://github.com/krakjoe/apcu/archive/v$APCU_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/apcu --strip 1 \
    && docker-php-ext-install apcu \
    && docker-php-source delete \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apt/lists/*

RUN cd /tmp && \
    # imagick
    git clone https://github.com/Imagick/imagick && \
    cd imagick && \
    phpize && \
    ./configure && \
    make && make install && \
    docker-php-ext-enable imagick && \
    cd /tmp && rm -rf imagick && \
    # memcached
    git clone https://github.com/php-memcached-dev/php-memcached && \
    cd php-memcached && \
    phpize && \
    ./configure && \
    make && make install && \
    docker-php-ext-enable memcached && \
    cd /tmp && rm -rf php-memcached && \
    # xdebug
    git clone -b xdebug_3_2 https://github.com/xdebug/xdebug.git && \
    cd xdebug && \
    phpize && \
    ./configure && \
    make && make install && \
    docker-php-ext-enable xdebug && \
    cd /tmp && rm -rf xdebug

RUN groupadd -g ${CONTAINER_GID} ${CONTAINER_GROUP} && \
    useradd -u ${CONTAINER_UID} -g ${CONTAINER_GID} ${CONTAINER_USER}

RUN chmod -R 777 /usr/local/etc/php/ \
    && chown -R ${CONTAINER_USER} /usr/local/etc/php/ \
    && curl -sS https://getcomposer.org/installer | php ; mv composer.phar /usr/bin/composer

COPY ./conf.d /usr/local/etc/php/conf.d/
COPY ./php-fpm.d /usr/local/etc/php-fpm.d/
COPY ./msmtp /usr/local/etc/msmtp/

RUN sed -i "$ a xdebug.client_host="${BX_XDEBUG_IP} /usr/local/etc/php/conf.d/xdebug.ini \
    && sed -i "$ a xdebug.client_port="${BX_XDEBUG_PORT} /usr/local/etc/php/conf.d/xdebug.ini \
    && sed -i "$ a default_charset="${BX_DEFAULT_CHARSET} /usr/local/etc/php/conf.d/php.ini \
    && sed -i "$ a mbstring.internal_encoding="${BX_DEFAULT_CHARSET} /usr/local/etc/php/conf.d/mbstring.ini \
    && sed -i "$ a port "${BX_SMTP_PORT} /usr/local/etc/msmtp/msmtp.conf \
    && sed -i "$ a from "${BX_SMTP_FROM} /usr/local/etc/msmtp/msmtp.conf

 # PHPUnit
RUN mkdir /var/composer && \
    mkdir /var/config && \
    cd /var/composer && \
    composer require "phpunit/phpunit:^10" \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist

ENTRYPOINT php-fpm -F
