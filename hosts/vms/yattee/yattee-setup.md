sudo vi /var/lib/yattee-server/secrets.env

ADMIN_PASSWORD=whatever

chmod 600 /var/lib/yattee-server/secrets.env

systemctl restart docker-yattee-server.service

https://192.168.1.54:8080
