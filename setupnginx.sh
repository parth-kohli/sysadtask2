#!/bin/bash
NGINX_CONF_DIR="/etc/nginx/sites-available"
NGINX_ENABLED_DIR="/etc/nginx/sites-enabled"
AUTHORS_DIR="/home/authors"
chmod o+x /home /home/authors
find "$AUTHORS_DIR" -type d -exec chmod o+x {} \;
find "$AUTHORS_DIR" -type f -exec chmod o+r {} \;
for user_dir in "$AUTHORS_DIR"/*; do
    [ -d "$user_dir/public" ] || continue
    username=$(basename "$user_dir")
    conf_file="$NGINX_CONF_DIR/$username.blog.in"

    cat > "$conf_file" <<EOF
server {
    listen 80;
    server_name $username.blog.in;
    root $user_dir/public;
    location / {
        autoindex on;
    	autoindex_exact_size off;
    	autoindex_localtime on;
        try_files \$uri \$uri/ =404;
    }
}
EOF

    ln -sf "$conf_file" "$NGINX_ENABLED_DIR/$username.blog.in"
done
for user_dir in "$AUTHORS_DIR"/*; do
    [ -d "$user_dir" ] || continue
    username=$(basename "$user_dir")
    domain="$username.blog.in"

    if ! grep -q "$domain" /etc/hosts; then
        echo "127.0.0.1 $domain" >> /etc/hosts
    fi
done
nginx -t && systemctl reload nginx

