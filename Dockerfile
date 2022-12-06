FROM ubuntu:22.04 as base
LABEL org.opencontainers.image.authors="adwolf15@gmail.com"

ENV TZ=Europe/Kyiv \
    WWW_ROOT=/var/www/mediawiki
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN set x; \
    apt update && apt install -y php8.1 php8.1-cli php8.1-intl php8.1-pdo php8.1-mysql \
    php8.1-gd php8.1-mbstring php8.1-curl php8.1-zip php8.1-sqlite3 php8.1-xml \
    apache2 apache2-utils wget software-properties-common gpg ca-certificates imagemagick \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www
RUN wget https://releases.wikimedia.org/mediawiki/1.39/mediawiki-1.39.0.tar.gz \
    && tar -xzvf mediawiki-1.39.0.tar.gz \
    && rm mediawiki-1.39.0.tar.gz \
    && mv mediawiki-1.39.0 mediawiki

COPY configs/mediawiki.conf /etc/apache2/sites-enabled/mediawiki.conf
COPY configs/.htaccess ${WWW_ROOT}/
COPY configs/robots.txt ${WWW_ROOT}/

RUN set -x; \
    a2enmod rewrite expires \
    && sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf \
    && rm /etc/apache2/sites-enabled/000-default.conf \
    && service apache2 restart

EXPOSE 80

HEALTHCHECK --interval=1m --timeout=10s \
	CMD wget -q --method=HEAD localhost/w/api.php

CMD ["apache2ctl", "-D", "FOREGROUND"]