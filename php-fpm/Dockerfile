FROM php:7.3-fpm

ARG APCU_VERSION=5.1.18

ARG CONTAINER_GID
ARG CONTAINER_UID
ARG CONTAINER_USER
ARG CONTAINER_GROUP

ARG BX_XDEBUG_IP
ARG BX_DEFAULT_CHARSET

COPY ./conf.d /usr/local/etc/php/conf.d/
COPY ./php-fpm.d /usr/local/etc/php-fpm.d/
COPY ./exim/update-exim4.conf.conf /etc/exim4/

RUN apt-get update \
    && apt-get install -y vim exim4 \
    && echo "syntax on" > ~/.vimrc \
    && apt-get -y install \
        libmagickwand-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libmemcached-dev \
        libicu-dev \
        libzip-dev \
        zlib1g-dev \
        libpng-dev \
        libxml2-dev \
        --no-install-recommends \
    && pecl install imagick apcu-${APCU_VERSION} memcached \
    && docker-php-ext-enable imagick \
    && docker-php-ext-enable apcu \
    && docker-php-ext-enable memcached \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysqli pdo_mysql opcache exif intl sockets bz2 zip \
    && docker-php-ext-configure opcache --enable-opcache \
#    && pecl install -o -f redis \
#    && docker-php-ext-enable redis \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && pecl install xdebug-2.9.8 && docker-php-ext-enable xdebug

RUN groupadd -g ${CONTAINER_GID} ${CONTAINER_GROUP} \
    && useradd -u ${CONTAINER_UID} -g ${CONTAINER_GID} ${CONTAINER_USER}

RUN chmod -R 777 /usr/local/etc/php/ \
    && chown -R ${CONTAINER_USER} /usr/local/etc/php/ \
    && curl -sS https://getcomposer.org/installer | php ; mv composer.phar /usr/bin/composer \
    && update-exim4.conf -v

RUN sed -i "$ a xdebug.remote_host="${BX_XDEBUG_IP} /usr/local/etc/php/conf.d/xdebug.ini \
    && sed -i "$ a default_charset="${BX_DEFAULT_CHARSET} /usr/local/etc/php/conf.d/php.ini \
    && sed -i "$ a mbstring.internal_encoding="${BX_DEFAULT_CHARSET} /usr/local/etc/php/conf.d/mbstring.ini

ENTRYPOINT php-fpm -F