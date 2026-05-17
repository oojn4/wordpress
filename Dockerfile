FROM wordpress:latest

# 1. Install ekstensi PHP PostgreSQL yang dibutuhkan
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pgsql pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Unduh plugin jembatan PG4WP agar WordPress paham PostgreSQL
# Serta konfigurasi otomatis schema kustom via Environment Variable
RUN curl -L https://github.com -o pg4wp.tar.gz \
    && tar -xzf pg4wp.tar.gz \
    && mkdir -p /var/www/html/wp-content \
    && mv pg4wp-master/pg4wp /var/www/html/wp-content/pg4wp \
    && cp /var/www/html/wp-content/pg4wp/db.php /var/www/html/wp-content/db.php \
    && rm -rf pg4wp.tar.gz pg4wp-master

# 3. Setup port untuk Zeabur
ENV PORT=80
EXPOSE 80
