#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$( echo $0 | cut -d'.' -f1)
LOG_FILE=/tmp/${SCRIPT_NAME}_${TIMESTAMP}.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter your MySQL root password:"
read -s MYSQL_ROOT_PASSWORD

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
dnf module disable nodejs -y &>> $LOG_FILE
validate $? "Disabling NodeJS module"
dnf module enable nodejs:20 -y &>> $LOG_FILE
validate $? "Enabling NodeJS 20 module"
dnf install nodejs -y &>> $LOG_FILE
validate $? "NodeJS installation"

id expense 
if [ $? -ne 0 ]; then
 
    useradd expense &>> $LOG_FILE
    validate $? "Creating expense user"
else
    echo -e "${Y}User expense already exists..${N}SKIPPING"
fi

mkdir -p /app &>> $LOG_FILE
validate $? "Creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOG_FILE
validate $? "Downloading backend code"

cd /app &>> $LOG_FILE
validate $? "Changing to /app directory"
rm -rf /app/* &>> $LOG_FILE
validate $? "Cleaning /app directory"

unzip /tmp/backend.zip -d /app/ &>> $LOG_FILE
validate $? "Unzipping backend code"

npm install &>> $LOG_FILE
validate $? "Installing backend dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>> $LOG_FILE
validate $? "Copying backend systemd service file"

systemctl daemon-reload &>> $LOG_FILE
validate $? "Reloading systemd daemon"

systemctl start backend &>> $LOG_FILE
validate $? "Starting backend service"

systemctl enable backend &>> $LOG_FILE
validate $? "Enabling backend service at boot"

dnf install mysql -y &>> $LOG_FILE
validate $? "MySQL client installation"

mysql -h db.chandradevops.online -uroot -p$MYSQL_ROOT_PASSWORD < /app/schema/backend.sql
validate $? "Importing backend database schema"

systemctl restart backend &>> $LOG_FILE
validate $? "Restarting backend service"