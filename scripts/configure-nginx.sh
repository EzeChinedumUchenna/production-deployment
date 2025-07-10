#!/bin/bash


sudo rm /etc/nginx/sites-enabled/default
# modify the Prometheus, grafana and alertmanager service to ensure it's using NodePort:
kubectl patch svc -n monitoring prometheus-stack-grafana -p '{"spec":{"type":"NodePort","ports":[{"name":"http","port":80,"targetPort":3000,"nodePort":30091}]}}'
kubectl patch svc -n monitoring prometheus-stack-kube-prom-alertmanager -p '{"spec":{"type":"NodePort","ports":[{"name":"web","port":9093,"targetPort":9093,"nodePort":30092}]}}'
kubectl patch svc -n monitoring prometheus-stack-kube-prom-prometheus -p '{"spec":{"type":"NodePort","ports":[{"name":"web","port":9090,"targetPort":9090,"nodePort":30090}]}}'
# Overwrite NGINX config with your desired reverse proxy setup
sudo tee /etc/nginx/sites-available/prometheus > /dev/null <<EOF
server {
    listen 9001 default_server;
    server_name _;

    location / {
        proxy_pass http://192.168.49.2:30090;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}

EOF

sudo tee /etc/nginx/sites-available/grafana > /dev/null <<EOF
server {
    listen 9002 default_server;
    server_name _;

    location / {
        proxy_pass http://192.168.49.2:30091;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}

EOF


sudo tee /etc/nginx/sites-available/alertmanager > /dev/null <<EOF
server {
    listen 9003 default_server;
    server_name _;

    location / {
        proxy_pass http://192.168.49.2:30092;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}

EOF

sudo ln -s /etc/nginx/sites-available/prometheus /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/grafana /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/alertmanager /etc/nginx/sites-enabled/

# Test and reload NGINX
echo "Testing NGINX configuration..."
if sudo nginx -t; then
    echo "Configuration is valid. Reloading NGINX..."
    sudo systemctl reload nginx
    echo "NGINX reloaded successfully!"
    sudo systemctl restart nginx
    echo "NGINX restarted successfully!"
else
    echo "NGINX configuration test failed!"
    exit 1
fi
