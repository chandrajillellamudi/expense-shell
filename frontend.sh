#!/bin/bash
set -e
set -o pipefail

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(basename "$0" | cut -d'.' -f1)
LOG_FILE=/tmp/${SCRIPT_NAME}_${TIMESTAMP}.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Root check
if [ $ID -ne 0 ]; then
    echo -e "${R}Please run as root user${N}"
    exit 1
else
    echo -e "${G}Running as root user${N}"
fi

validate() {
    if [ $1 -ne 0 ]; then
        echo -e "$2..${R} failed${N}"
        exit 1
    else
        echo -e "$2..${G}successful${N}"
    fi
}

echo -e "${Y}Starting frontend deployment...${N}"

# Install Nginx and unzip
dnf install -y nginx unzip &>> $LOG_FILE
validate $? "Nginx and unzip installation"

# Enable Nginx at boot
systemctl enable nginx &>> $LOG_FILE
validate $? "Enabling Nginx service at boot"

# Start Nginx (temporary minimal start)
systemctl start nginx &>> $LOG_FILE || echo -e "${Y}Starting Nginx temporarily to test${N}"

# Clean default HTML files
rm -rf /usr/share/nginx/html/* &>> $LOG_FILE
validate $? "Cleaning default Nginx HTML files"

# Download frontend code
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> $LOG_FILE
validate $? "Downloading frontend code"

# Ensure HTML directory exists
mkdir -p /usr/share/nginx/html
cd /usr/share/nginx/html
validate $? "Changing to Nginx HTML directory"

# Unzip frontend
unzip -o /tmp/frontend.zip -d /usr/share/nginx/html/ &>> $LOG_FILE
validate $? "Unzipping frontend code"

# Clean all old Nginx conf files to avoid syntax errors
rm -f /etc/nginx/conf.d/* &>> $LOG_FILE
validate $? "Cleaning old Nginx conf files"

# Create correct Nginx config
cat << 'EOF' > /etc/nginx/conf.d/expense.conf
server {
    listen 80 default_server;
    server_name db.chandradevops.online;

    proxy_http_version 1.1;

    location /api/ {
        proxy_pass http://backend.chandradevops.online:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /health {
        stub_status on;
        access_log off;
    }

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
EOF
validate $? "Creating correct Nginx config"

# Set proper permissions
chown -R nginx:nginx /usr/share/nginx/html
chmod -R 755 /usr/share/nginx/html

# Test Nginx config
nginx -t &>> $LOG_FILE
validate $? "Testing Nginx config"

# Restart Nginx
systemctl restart nginx &>> $LOG_FILE
validate $? "Restarting Nginx service"

echo -e "${G}Frontend deployment completed successfully!${N}"
