FROM alpine:3.14 as builder

RUN apk --no-cache add \
    autoconf file g++ gcc libc-dev make pkgconf re2c linux-headers \
    ca-certificates curl tar xz openssl php7-pear php7-dev php7-openssl

RUN pecl install grpc protobuf

FROM alpine:3.14

# Install packages and remove default server definition
RUN apk --no-cache add \
    composer \
    curl \
    git \
    nginx \
    npm \
    php7 \
    php7-bcmath \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-exif \
    php7-fileinfo \
    php7-fpm \
    php7-gd \
    php7-intl \
    php7-json \
    php7-mbstring \
    php7-mysqli \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-phar \
    php7-session \
    php7-tokenizer \
    php7-xml \
    php7-xmlreader \
    php7-xmlwriter \
    php7-zlib \
    runit

COPY --from=builder /usr/lib/php7/modules/grpc.so /usr/lib/php7/modules/protobuf.so /usr/lib/php7/modules/
RUN echo "extension=grpc.so" > /etc/php7/conf.d/10_grpc.ini
RUN echo "extension=protobuf.so" > /etc/php7/conf.d/10_protobuf.ini

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP
COPY config/php-fpm.conf /etc/php7/php-fpm.d/www.conf

# Configure runit services
RUN echo -e "#!/bin/sh\ntest -S /run/php-fpm.sock || exit 1\nexec nginx -e stderr -g 'daemon off;'" | \
    install -D /dev/stdin /etc/service/nginx/run
RUN echo -e "#!/bin/sh\nexec php-fpm7 -F" | install -D /dev/stdin /etc/service/php-fpm/run
RUN chmod a+x /etc/service/php-fpm/run /etc/service/nginx/run

# Let runit start nginx & php-fpm
ENTRYPOINT runsvdir -P /etc/service

WORKDIR /run/code

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
#RUN chown -R nobody.nobody /etc/service /run /var/log/nginx
# https://gitlab.alpinelinux.org/alpine/aports/-/issues/12669
#RUN chown -R :www-data /var/lib/nginx && chmod -R 777 /var/lib/nginx/tmp

# Switch to use a non-root user from here on
#USER nobody

# Add application
#COPY --chown=nobody:www-data . .

# Run composer install to install the dependencies
#RUN composer install --optimize-autoloader --no-interaction --no-progress

# Symlink secret file to .env
RUN test -f .env || ln -s /etc/secrets/env .env

# Expose the port nginx is reachable on
EXPOSE 8080
