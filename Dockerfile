FROM ubuntu:22.04 as base
LABEL org.opencontainers.image.authors="adwolf15@gmail.com"

ENV TZ=Europe/Kyiv \
    WWW_ROOT=/var/www/mediawiki \
    MW_VERSION=1.39.0 \
    HASH=eb9e25b3b2163f48fe8f9b585d8004b4
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN set x; \
    apt update && apt install -y php8.1 php8.1-cli php8.1-intl php8.1-pdo php8.1-mysql \
    php8.1-gd php8.1-mbstring php8.1-curl php8.1-zip php8.1-sqlite3 php8.1-xml php8.1-apcu \
    apache2 apache2-utils wget software-properties-common gpg ca-certificates imagemagick \
    less nano \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www
RUN wget -nv https://releases.wikimedia.org/mediawiki/1.39/mediawiki-${MW_VERSION}.tar.gz \
    && tar -xzf mediawiki-${MW_VERSION}.tar.gz \
    && rm mediawiki-${MW_VERSION}.tar.gz \
    && mv mediawiki-${MW_VERSION} mediawiki

COPY scripts/*.sh /
COPY configs/mediawiki.conf /etc/apache2/sites-enabled/mediawiki.conf
COPY configs/.htaccess ${WWW_ROOT}/
COPY configs/robots.txt ${WWW_ROOT}/

RUN set -x; \
    chmod -v +x /*.sh \
    && mkdir /var/www/data && chown www-data:www-data /var/www/data \
    && mkdir ${WWW_ROOT}/user-extensions && chown www-data:www-data ${WWW_ROOT}/user-extensions \
    && mkdir ${WWW_ROOT}/user-skins && chown www-data:www-data ${WWW_ROOT}/user-skins \
    && a2enmod rewrite expires \
    && sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf \
    && rm /etc/apache2/sites-enabled/000-default.conf \
    && service apache2 restart

EXPOSE 80
WORKDIR ${WWW_ROOT}

#HEALTHCHECK --interval=1m --timeout=10s \
#	CMD wget -q --method=HEAD localhost/w/api.php

CMD ["/mwrun.sh"]