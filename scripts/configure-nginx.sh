#!/bin/bash

# Overwrite NGINX config with your desired reverse proxy setup
sudo tee /etc/nginx/sites-available/default > /dev/null <<EOF
server {
    listen 80 default_server;
    server_name _;

    location / {
        proxy_pass http://192.168.49.2:30991;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Test and reload NGINX
echo "Testing NGINX configuration..."
if sudo nginx -t; then
    echo "Configuration is valid. Reloading NGINX..."
    sudo systemctl reload nginx
    echo "🚀 NGINX reloaded successfully!"
else
    echo "❌ NGINX configuration test failed!"
    exit 1
fi
