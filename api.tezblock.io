map $http_apikey $valid_apikey {
    default 0;
    "C0r6cY6NjOW4DSlHKqaJy3xc9VaoeO6W" 1;
    # Add more valid API keys here
}


server {
    listen 80;
    server_name api.tezblock.io;

    location / {
            return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name api.tezblock.io;

    ssl_certificate /etc/letsencrypt/live/api.tezblock.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.tezblock.io/privkey.pem;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers EECDH:+AES256:-3DES:RSA+AES:RSA+3DES:!NULL:!RC4;
    ssl_prefer_server_ciphers on;

    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 30m;
    ssl_session_tickets off;

    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4;

    add_header Access-Control-Allow-Headers "User-Agent";

    set $apikey_present 0;
    if ($http_apikey) {
        set $apikey_present 1;
    }

    location / {
        if ($apikey_present = 0) {
            proxy_pass https://kong.tezblock.io;
        }
        proxy_hide_header Access-Control-Allow-Origin;
        add_header Access-Control-Allow-Origin * always;
        proxy_pass http://127.0.0.1:8000;
	#proxy_pass https://api-dev.celenium.io;
    }

    location /v1/ws {
       # if ($apikey_present = 0) {
       #     return 403; # Forbidden
       # }
        if ($valid_apikey = 0) {
            return 403; # Forbidden
        }
        proxy_hide_header Access-Control-Allow-Origin;
        add_header Access-Control-Allow-Origin * always;
        proxy_pass http://127.0.0.1:8000;
    }

    location /v1/blob {
        if ($apikey_present = 0) {
            return 403; # Forbidden
        }
        if ($valid_apikey = 0) {
            return 403; # Forbidden
	} 
        proxy_hide_header Access-Control-Allow-Origin;
        add_header Access-Control-Allow-Origin * always;
        proxy_pass http://127.0.0.1:8000;
    }

    location /v1/stats {
        if ($apikey_present = 0) {
            return 403; # Forbidden
        }  
        proxy_hide_header Access-Control-Allow-Origin;
        add_header Access-Control-Allow-Origin * always;
        proxy_pass http://127.0.0.1:8000;
    }

    location /v1/rollup {
        if ($apikey_present = 0) {
            return 403; # Forbidden
        }  
        proxy_hide_header Access-Control-Allow-Origin;
        add_header Access-Control-Allow-Origin * always;
        proxy_pass http://127.0.0.1:8000;
    }
}
