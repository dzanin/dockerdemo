server {
        listen 80;
        listen [::]:80;

        root /usr/src/swisstopo/html;
        index index.html index.htm index.nginx-debian.html;

        server_name swisstopo.ch www.swisstopo.ch;

        location /bms/html/ {
                proxy_pass      http://localhost:8888/;
                include         /etc/nginx/proxy.conf;
        }

        location / {
                try_files $uri $uri/ =404;
        }
}
