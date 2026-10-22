#!/bin/bash
set -euo pipefail

# This script is intended to be run on a fresh Ubuntu 24.04 installation.
find /etc/apt/sources.list.d -type f -delete -print

# Remove any existing sources.list file 
cat <<EOF > /etc/apt/sources.list
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] http://archive.ubuntu.com/ubuntu/ stonking main restricted universe multiverse
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] http://archive.ubuntu.com/ubuntu/ stonking-updates main restricted universe multiverse
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] http://archive.ubuntu.com/ubuntu/ stonking-backports main restricted universe multiverse
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] http://security.ubuntu.com/ubuntu/ stonking-security main restricted universe multiverse
EOF

# Update package lists and upgrade existing packages
mkdir -p ~/src/php-build
# Update package lists and upgrade existing packages
cd ~/src/php-build

# Install required dependencies for building PHP
TARGET_PKG=php-8.5.12.tar.xz
# Download the PHP source code
curl --fail --location --proto '=https' "https://www.php.net/distributions/${TARGET_PKG}" \
  --output ${TARGET_PKG}
# Verify the integrity of the downloaded package 
sha256sum ${TARGET_PKG}
# Extract the downloaded package
tar -xf ${TARGET_PKG}
# Change to the extracted directory
cd php-8.5.12
# Configure the build options for PHP
./configure \
  --prefix=/opt/php/8.5.12 \
  --with-config-file-path=/opt/php/8.5.12/etc \
  --with-config-file-scan-dir=/opt/php/8.5.12/etc/conf.d \
  --with-openssl \
  --with-curl \
  --with-zlib \
  --with-zip \
  --with-readline \
  --enable-mbstring \
  --with-mysqli=mysqlnd \
  --with-pdo-mysql=mysqlnd

# Build and install PHP
make -j"$(nproc)"
# Run tests to ensure PHP was built correctly
make test
# Install PHP to the specified prefix
sudo make install
# Create necessary directories and copy the production php.ini file
sudo install -d /opt/php/8.5.12/etc/conf.d
# Copy the production php.ini file to the configuration directory
sudo install -m 0644 php.ini-production /opt/php/8.5.12/etc/php.ini
# Verify the installed PHP version
/opt/php/8.5.12/bin/php -v
# Create a systemd service file for PHP-FPM
sudo tee /opt/php/8.5.12/etc/php-fpm.conf >/dev/null <<'EOF'
[global]
error_log = /var/log/php-8.5.12-fpm.log
daemonize = no

[www]
user = www-data
group = www-data

listen = /run/php-8.5.12-custom-fpm/php.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

pm = ondemand
pm.max_children = 8
pm.process_idle_timeout = 10s
pm.max_requests = 500

clear_env = yes
security.limit_extensions = .php
catch_workers_output = yes
EOF
# Create a directory for the PHP-FPM socket
./config.status --config
# Create a directory for the PHP-FPM socket
./configure --enable-fpm \
--with-fpm-user=www-data \
--with-fpm-group=www-data \
--with-fpm-systemd
# Build and install PHP-FPM
make -j2 && sudo make install
# Run tests to ensure PHP-FPM was built correctly
make test
# Create a systemd service file for PHP-FPM
php --version
