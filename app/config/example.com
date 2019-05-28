server {
        listen 80;
        listen [::]:80;

        root /usr/src/bms/api/html;
        index index.html index.htm index.nginx-debian.html;

        server_name example.com www.example.com;

        location /bms/api/ {
                proxy_pass      http://localhost:8888/;
                include         /etc/nginx/proxy.conf;
        }

        location / {
                try_files $uri $uri/ =404;
        }
}
