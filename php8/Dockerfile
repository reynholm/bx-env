FROM php:8.0-fpm

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

COPY ./conf.d /usr/local/etc/php/conf.d/
COPY ./php-fpm.d /usr/local/etc/php-fpm.d/
COPY ./msmtp /usr/local/etc/msmtp/

RUN apt-get update \
    && apt-get install -y vim zip unzip default-mysql-client git msmtp \
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
    && pecl install apcu-${APCU_VERSION} \
    && docker-php-ext-enable apcu \
    && pecl install memcached \
    && docker-php-ext-enable memcached \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysqli pdo_mysql opcache exif intl sockets bz2 zip \
    && docker-php-ext-configure opcache --enable-opcache \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apt/lists/* \
    && pecl install xdebug && docker-php-ext-enable xdebug

RUN cd /tmp && \
    git clone https://github.com/Imagick/imagick && \
    cd imagick && \
    phpize && \
    ./configure && \
    make && make install && \
    docker-php-ext-enable imagick && \
    cd /tmp && rm -rf imagick

RUN groupadd -g ${CONTAINER_GID} ${CONTAINER_GROUP} && \
    useradd -u ${CONTAINER_UID} -g ${CONTAINER_GID} ${CONTAINER_USER}

RUN chmod -R 777 /usr/local/etc/php/ \
    && chown -R ${CONTAINER_USER} /usr/local/etc/php/ \
    && curl -sS https://getcomposer.org/installer | php ; mv composer.phar /usr/bin/composer

RUN sed -i "$ a xdebug.client_host="${BX_XDEBUG_IP} /usr/local/etc/php/conf.d/xdebug.ini \
    && sed -i "$ a xdebug.client_port="${BX_XDEBUG_PORT} /usr/local/etc/php/conf.d/xdebug.ini \
    && sed -i "$ a default_charset="${BX_DEFAULT_CHARSET} /usr/local/etc/php/conf.d/php.ini \
    && sed -i "$ a mbstring.internal_encoding="${BX_DEFAULT_CHARSET} /usr/local/etc/php/conf.d/mbstring.ini \
    && sed -i "$ a port "${BX_SMTP_PORT} /usr/local/etc/msmtp/msmtp.conf \
    && sed -i "$ a from "${BX_SMTP_FROM} /usr/local/etc/msmtp/msmtp.conf

ENTRYPOINT php-fpm -F