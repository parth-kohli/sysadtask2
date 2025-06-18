#!/bin/bash
set -e
DB_HOST="db"
DB_USER="root"
DB_PASS="parthsarth9541"
DB_NAME="blogdb"
until mysqladmin ping -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" --silent; do
  echo "Waiting for MySQL..."
  sleep 2
done
/scripts/user1.sh
/scripts/users.sh
for user in $(getent group g_admin | cut -d: -f4 | tr ',' ' '); do
    [ -n "$user" ] && crontab -u "$user" /etc/blog-config/admin_crontab || true
done
for user in $(getent group g_user | cut -d: -f4 | tr ',' ' '); do
    [ -n "$user" ] && crontab -u "$user" /etc/blog-config/user_crontab || true
done
chmod o+x /home /home/authors
find /home/authors -type d -exec chmod o+x {} \;
service ssh start
service cron start
tail -f /dev/null

