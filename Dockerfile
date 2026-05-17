FROM wordpress:latest
# 1. Install ekstensi PHP PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pgsql pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
# 2. Unduh plugin PG4WP versi stabil terbaru (v3.3.1)
RUN curl -L https://github.com/PostgreSQL-For-Wordpress/postgresql-for-wordpress/archive/refs/tags/v3.3.1.tar.gz -o pg4wp.tar.gz \
    && tar -xzf pg4wp.tar.gz \
    && mkdir -p /var/www/html/wp-content \
    && mv postgresql-for-wordpress-3.3.1/pg4wp /var/www/html/wp-content/pg4wp \
    && cp /var/www/html/wp-content/pg4wp/db.php /var/www/html/wp-content/db.php \
    && rm -rf pg4wp.tar.gz postgresql-for-wordpress-3.3.1
# 3. Konfigurasi Apache untuk mendengarkan di port 8080 (statis, bukan variabel)
RUN sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:8080>/g' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:8080>/g' /etc/apache2/sites-available/default-ssl.conf 2>/dev/null || true
# 4. Ekspos port 8080 untuk Zeabur
EXPOSE 8080