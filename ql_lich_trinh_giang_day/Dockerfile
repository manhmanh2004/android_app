# Sử dụng image PHP chính thức có sẵn Composer
FROM php:8.2-fpm

# Cài các thư viện cần thiết cho Laravel
RUN apt-get update && apt-get install -y \
    git unzip libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev zip curl && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Cài Composer toàn cục
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Tạo thư mục làm việc
WORKDIR /var/www

# Copy toàn bộ mã nguồn Laravel vào container
COPY . .

# Cài đặt các dependency của Laravel
RUN composer install --no-dev --optimize-autoloader

# Phân quyền cho storage & bootstrap/cache
RUN chown -R www-data:www-data storage bootstrap/cache

# Expose cổng (nếu dùng PHP built-in)
EXPOSE 8000

# Lệnh chạy mặc định
CMD php artisan serve --host=0.0.0.0 --port=8000
