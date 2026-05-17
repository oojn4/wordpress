FROM wordpress:latest

# 1. Konfigurasi Apache port 8080
RUN sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:8080>/g' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:8080>/g' /etc/apache2/sites-available/default-ssl.conf 2>/dev/null || true

# 2. Ekspos port 8080
EXPOSE 8080