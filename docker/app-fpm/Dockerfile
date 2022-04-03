ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm AS base

ARG TZ
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

# hadolint ignore=DL3009
RUN apt-get update -yqq && apt-get install -yqq \
    git \
    make \
    wget \
    unzip

ARG EXT_IGBINARY_VERSION
ARG EXT_REDIS_VERSION

RUN docker-php-source extract \
    # ext-opache
    && docker-php-ext-enable opcache \
    # ext-igbinary
    && mkdir -p /usr/src/php/ext/igbinary \
    &&  curl -fsSL https://github.com/igbinary/igbinary/archive/${EXT_IGBINARY_VERSION}.tar.gz | tar xvz -C /usr/src/php/ext/igbinary --strip 1 \
    && docker-php-ext-install -j$(nproc) igbinary \
    # ext-redis
    && mkdir -p /usr/src/php/ext/redis \
    && curl -fsSL https://github.com/phpredis/phpredis/archive/${EXT_REDIS_VERSION}.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && docker-php-ext-configure redis --enable-redis-igbinary \
    && docker-php-ext-install -j$(nproc) redis \
    # ext-postgresql
    && apt-get install -yqq libpq-dev \
    && docker-php-ext-install -j$(nproc) pdo pdo_pgsql pgsql \
    && apt-get remove libpq-dev -y \
    && docker-php-ext-install -j$(nproc) pcntl bcmath

ARG COMPOSER_VERSION
COPY ./shared/scripts/install-composer.sh /tmp/scripts/install-composer.sh
RUN sh /tmp/scripts/install-composer.sh /usr/bin composer ${COMPOSER_VERSION}  \
    && composer --ansi --version --no-interaction

# php-fpm pool config
COPY ./app-fpm/php-fpm.d/docker.conf /usr/local/etc/php-fpm.d/
COPY ./app-fpm/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/

COPY ./shared/scripts/cleanup.sh /tmp/scripts/cleanup.sh

RUN ln -sf /proc/1/fd/1 /var/log/laravel-scheduler.log


FROM base AS local

RUN apt-get install -yqq \
    sudo \
    nano \
    dnsutils \
    iproute2 \
    iputils-ping

ARG USER_UID
RUN usermod -u ${USER_UID} www-data
RUN chown -R www-data:1000 /var/www
RUN echo "www-data  ALL=NOPASSWD: ALL" >> /etc/sudoers
RUN /tmp/scripts/cleanup.sh
        
# entrypoint
COPY ./shared/scripts/docker-entrypoint/resolve-docker-host-ip.sh /bin/docker-entrypoint/
ENTRYPOINT ["/bin/docker-entrypoint/resolve-docker-host-ip.sh"]
