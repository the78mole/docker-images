FROM wordpress:6.8.2-apache

# Install msmtp, ca-certificates and PHP MySQL extension
RUN apt-get update && \
    apt-get install -y msmtp ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql

# Create msmtp config template
COPY msmtp_entrypoint.sh /usr/local/bin/msmtp_entrypoint.sh
RUN chmod +x /usr/local/bin/msmtp_entrypoint.sh

# Hook into WordPress entrypoint
ENTRYPOINT ["/usr/local/bin/msmtp_entrypoint.sh"]
CMD ["docker-entrypoint.sh", "apache2-foreground"]