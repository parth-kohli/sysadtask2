FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y sudo netcat-openbsd cron python3 python3-pip openssh-client vim wget acl nginx && \
    apt-get clean
RUN wget https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh && \
    ln -s /scripts/* /usr/local/bin/
COPY config/ /etc/blog-config/
RUN /scripts/users.sh
COPY cron/admin_crontab /etc/blog-config/admin_crontab
COPY cron/user_crontab /etc/blog-config/user_crontab
RUN for user in $(getent group g_admin | cut -d: -f4 | tr ',' ' '); do \
        [ -n "$user" ] && crontab -u "$user" /etc/blog-config/admin_crontab || true; \
    done && \
    for user in $(getent group g_user | cut -d: -f4 | tr ',' ' '); do \
        [ -n "$user" ] && crontab -u "$user" /etc/blog-config/user_crontab || true; \
    done
RUN chmod +x /home /home/authors && \
    find /home/authors -type d -exec chmod +x {} \;
EXPOSE 80
CMD service cron start  && /bin/bash
