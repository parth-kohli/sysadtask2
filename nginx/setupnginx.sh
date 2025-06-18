#!/bin/bash
NGINX_CONF_DIR="/etc/nginx/sites-available"
NGINX_ENABLED_DIR="/etc/nginx/sites-enabled"
AUTHORS_DIR="/home/authors"
SSL_DIR="/etc/ssl/private"
mkdir -p "$SSL_DIR"
if [[ ! -f "$SSL_DIR/selfsigned.crt" || ! -f "$SSL_DIR/selfsigned.key" ]]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$SSL_DIR/selfsigned.key" \
    -out "$SSL_DIR/selfsigned.crt" \
    -subj "/C=IN/ST=Delhi/L=NewDelhi/O=BlogServer/CN=localhost"
fi
for user_dir in "$AUTHORS_DIR"/*; do
    [ -d "$user_dir/public" ] || continue
    username=$(basename "$user_dir")
    conf_file="$NGINX_CONF_DIR/$username.blog.in"

    cat > "$conf_file" <<EOF
server {
    listen 80;
    server_name $username.blog.in;
    return 301 https://\$host\$request_uri;
}
server {
    listen 443 ssl;
    server_name $username.blog.in;

    ssl_certificate $SSL_DIR/selfsigned.crt;
    ssl_certificate_key $SSL_DIR/selfsigned.key;

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
apt-get update
apt-get install -y openssh-server
mkdir -p /var/run/sshd
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "AllowGroups g_user g_author g_admin" >> /etc/ssh/sshd_config
mkdir -p /root/.ssh
cat > /root/.ssh/config <<EOF
Host users-container
    HostName users-container-hostname-or-ip
    User your_user
    ProxyJump localhost
EOF
chmod 600 /root/.ssh/config
nginx -t
