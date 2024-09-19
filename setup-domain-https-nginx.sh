#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Variables
DOMAIN="Your-Domain-Name"  # Replace with your actual domain
EMAIL="Email-For-Certbot"  # Replace with your email address for Certbot
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
WEBROOT="/var/www/$DOMAIN/html"

# Step 1: Install Nginx
echo "Installing Nginx..."
apt update
apt install -y nginx

# Step 2: Install Certbot and Nginx plugin for Certbot
echo "Installing Certbot and Nginx plugin..."
apt install -y certbot python3-certbot-nginx

# Step 3: Configure Nginx for your domain
echo "Configuring Nginx for your domain..."
mkdir -p $WEBROOT
chown -R www-data:www-data $WEBROOT
chmod -R 755 /var/www

# Create a sample index.html
echo "<html><head><title>Welcome to $DOMAIN</title></head><body><h1>Success! $DOMAIN is working!</h1></body></html>" > $WEBROOT/index.html

# Create the Nginx configuration file
cat > $NGINX_CONF <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    root $WEBROOT;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Enable the Nginx site configuration
ln -s $NGINX_CONF /etc/nginx/sites-enabled/

# Test Nginx configuration and reload
nginx -t && systemctl reload nginx
# Step 4: Obtain SSL certificate using Certbot
echo "Obtaining SSL certificate..."
certbot --nginx -d $DOMAIN -d $DOMAIN --non-interactive --agree-tos --email $EMAIL

# Step 5: Reload Nginx to apply the SSL certificate
echo "Reloading Nginx..."
systemctl reload nginx

echo "Domain setup with HTTPS is complete! Visit https://$DOMAIN to check."
