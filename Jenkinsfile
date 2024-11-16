<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to Bangladesh</title>
</head>
<body>
    <h1>Welcome to Bangladesh!</h1>
    <p>This page is being served by Nginx.</p>
</body>
</html>

sudo nano /etc/nginx/nginx.conf
server {
    listen 80;
    server_name localhost;

    location / {
        root /var/www/html;
        index index.html;
    }
}
sudo nginx -t
sudo systemctl restart nginx
