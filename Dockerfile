#syntax=docker/dockerfile:1.6.0

ARG COMPOSER_VERSION=2.6.5
ARG NODE_VERSION=16.20.2-alpine3.18
ARG PHP_INSTALLER_VERSION=2.1.55
ARG PHP_VERSION=8.1.24-alpine3.18

FROM composer:${COMPOSER_VERSION} AS composer
FROM node:${NODE_VERSION} AS node
FROM mlocati/php-extension-installer:${PHP_INSTALLER_VERSION} AS php_installer
FROM php:${PHP_VERSION} AS base

WORKDIR /opt/

RUN set -eux; \
    SECURITY_UPGRADES="" \
    && apk add --no-cache --upgrade ${SECURITY_UPGRADES}

RUN set -eux; \
    apk add --no-cache libstdc++ \
    openssh \
    git \
    patch \
    make \
    rsync \
    zip \
    vim \
    bash

COPY --from=php_installer /usr/bin/install-php-extensions /usr/local/bin/

RUN set -eux; \
    install-php-extensions \
    bcmath \
    gd \
    intl \
    pcntl \
    pdo_mysql \
    soap \
    sockets \
    xsl \
    zip

COPY --from=composer /usr/bin/composer /usr/bin/composer

COPY --from=node /usr/local/include/ /usr/local/include/
COPY --from=node /usr/local/lib/ /usr/local/lib/
COPY --from=node /usr/local/bin/ /usr/local/bin/

RUN set -eux; \
    corepack disable \
    && corepack enable

ADD --chmod=755 https://github.com/deployphp/deployer/releases/download/v7.3.1/deployer.phar /usr/local/bin/dep

ENTRYPOINT ["/bin/sh"]