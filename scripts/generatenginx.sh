#!/bin/bash
template="/etc/blog-config/blogs.template"
output_dir="/etc/nginx/sites-available"
for user in $(getent group g_author | cut -d: -f4 | tr ',' ' '); do
    if [ -n "$user" ]; then
        conf="${output_dir}/${user}"
        sed "s/USERNAME/${user}/g" "$template" > "$conf"
        ln -s "$conf" /etc/nginx/sites-enabled/"${user}"
        echo "127.0.0.1 ${user}.blog.in" >> /etc/hosts
    fi
done
