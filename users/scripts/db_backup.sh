#!/bin/bash
BACKUP_DIR="/backups"
DB_NAME="blogdb"
DB_USER="root"
DB_PASS="yourpassword"
DATE=$(date +"%Y-%m-%d")
mkdir -p "$BACKUP_DIR"
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_DIR/${DB_NAME}_$DATE.sql"
