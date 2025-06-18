FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y sudo netcat-openbsd cron python3 python3-pip openssh-client vim wget acl mysql-client && \
    apt-get clean
RUN wget https://github.com/mikefarah/yq/releases/download/v4.40.5/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq
COPY users/scripts/ /scripts/
COPY users/config/ /etc/blog-config/
COPY users/cron/admin_crontab /etc/blog-config/admin_crontab
COPY users/cron/user_crontab /etc/blog-config/user_crontab
RUN chmod +x /scripts/*.sh && ln -s /scripts/* /usr/local/bin/
RUN chmod +x /scripts/entrypoint.sh
CMD ["/bin/bash", "/scripts/entrypoint.sh"]
EXPOSE 80
RUN apt-get update && apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'AllowGroups g_user g_author g_admin' >> /etc/ssh/sshd_config
EXPOSE 22
CMD service ssh start && service cron start && tail -f /dev/null

