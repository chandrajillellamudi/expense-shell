#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$( echo $0 | cut -d'.' -f1)
LOG_FILE=/tmp/${SCRIPT_NAME}_${TIMESTAMP}.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $ID -ne 0 ]; then
    echo -e "${R}Please run as root user${N}"
    exit 1
else
    echo -e "${G}Running as root user${N}"
fi
validate(){
    if [ $1 -ne 0 ]; then
        echo -e "${R}$2.. failed${N}"
        exit 1
    else
        echo -e "${G}$2.. successful${N}"
    fi
}           

dnf install nginx -y &>> $LOG_FILE
validate $? "Nginx installation"

systemctl start nginx &>> $LOG_FILE
validate $? "Starting Nginx service"
systemctl enable nginx &>> $LOG_FILE
validate $? "Enabling Nginx service at boot"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE
validate $? "Cleaning default Nginx HTML content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> $LOG_FILE
validate $? "Downloading frontend code"

cd /usr/share/nginx/html &>> $LOG_FILE
validate $? "Changing to Nginx HTML directory"

unzip /tmp/frontend.zip &>> $LOG_FILE
validate $? "Extracting frontend code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>> $LOG_FILE
validate $? "Copying Nginx configuration file"

systemctl restart nginx &>> $LOG_FILE
validate $? "Restarting Nginx to apply new configuration"