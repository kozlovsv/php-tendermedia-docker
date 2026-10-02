FROM php:5.6-fpm

# 1. Настройка переменных окружения и локализации
ENV LANG=ru_RU.UTF-8 \
    LANGUAGE=ru_RU.UTF-8 \
    LC_ALL=ru_RU.UTF-8 \
    LC_CTYPE=ru_RU.UTF-8

# 2. Обход проблем с устаревшим Debian (archive.debian.org)
# - Перенаправляем репозитории на archive.debian.org
# - Отключаем проверку устаревших GPG-ключей (Check-Valid-Until=false)
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until && \
    echo 'Acquire::AllowInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99no-check-valid-until && \
    echo 'Acquire::AllowDowngradeToInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99no-check-valid-until && \
    sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list

# 3. Установка системных зависимостей и генерация локали ru_RU.UTF-8
RUN apt-get update -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true && \
    apt-get install -y --allow-unauthenticated \
    locales \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libmcrypt-dev \
    libbz2-dev \
    libgmp-dev \
    libc-client-dev \
    libkrb5-dev \
    libtidy-dev \
    libxslt1-dev \
    libzip-dev \
    unzip && \
    sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/*

# 4. Настройка и установка PHP-расширений
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure gmp --with-gmp=/usr/include/x86_64-linux-gnu/ \
    && docker-php-ext-install \
        bz2 \
        calendar \
        exif \
        ftp \
        gd \
        gmp \
        gettext \
        imap \
        mbstring \
        mcrypt \
        mysql \
        mysqli \
        pdo_mysql \
        opcache \
        shmop \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        tidy \
        xmlrpc \
        xsl \
        zip

# 5. Заканчиваем
WORKDIR /app
RUN chown -R www-data:www-data /app

EXPOSE 9000
CMD ["php-fpm"]