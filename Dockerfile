FROM alpine:3.11.6

# install dependencies
RUN set -eux; \
	apk update; \
	apk --no-cache add \
		nginx \
		pgbouncer \
		git \
		php7-fpm \
		lua5.1 \
		memcached \
		composer \
		php7-session \
		php7-mcrypt \
		php7-tokenizer \
		php7-xmlwriter \
		php7-simplexml \
		php7-soap \
		php7-memcached \
		php7-openssl \
		php7-gmp \
		php7-pdo_odbc \
		php7-json \
		php7-dom \
		php7-pdo \
		php7-zip \
		php7-mysqli \
		php7-sqlite3 \
		php7-pgsql \
		php7-pcntl \
		php7-pdo_pgsql \
		php7-bcmath \
		php7-gd \
		php7-odbc \
		php7-pdo_mysql \
		php7-pdo_sqlite \
		php7-gettext \
		php7-xmlreader \
		php7-xmlrpc \
		php7-bz2 \
		php7-iconv \
		php7-pdo_dblib \
		php7-curl \
		php7-ctype \
		php7-cli \
		php7-gd \
		php7-mbstring \
		php7-xml \
		php7-fileinfo \
		imagemagick \
		supervisor \
		curl \
	;

# enable Azure SSHd
RUN apk add openssh \
		openssh-keygen \
     && echo "root:Docker!" | chpasswd \
	 && ssh-keygen -A 

COPY config/sshd_config /etc/ssh

# create a general config directory, web root, and a nginx FastCGI cache location
RUN mkdir -p /dockerfiles/; \
	mkdir -p /var/www/html; \
	mkdir -p /etc/ssh; \
	mkdir -p /etc/nginx-cache \
	mkdir -p /elasticsearch \
	;

# Download elasticsearch
RUN cd /elasticsearch; \
	wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.7.0-linux-x86_64.tar.gz; \
	tar -xzf elasticsearch-7.7.0-linux-x86_64.tar.gz \
	;

# Remove nginx default server definition
RUN rm /etc/nginx/conf.d/default.conf

# switch working directory
WORKDIR /var/www/html

# download xenforo

# change ownership to nginx
RUN chown -R nginx:nginx /var/www/ && \
	chown -R nginx:nginx /run && \
	chown -R nginx:nginx /var/lib/nginx && \
	chown -R nginx:nginx /var/log/nginx && \
	chown -R nginx:nginx /etc/nginx-cache

# COPY src/cache_test.php /var/www/html/cache_test.php

# COPY src/info.php /var/www/html/info.php
# Copy entrypoint and config files
COPY docker-entrypoint.sh /dockerfiles/docker-entrypoint.sh
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/custom.ini
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config/userlist.txt /etc/pgbouncer/userlist.txt
COPY config/custom_pgbouncer.ini /etc/pgbouncer/custom_pgbouncer.ini

# expose web port and ssh port
EXPOSE 8080 2222

ENTRYPOINT [ "/dockerfiles/docker-entrypoint.sh" ]