#!/bin/bash
# Install MySQL
ID=$(id -u)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "Please enter MySQL root password:"
read -s MYSQL_ROOT_PASSWORD

if [ $ID -ne 0 ]; then
  echo -e "$R Please run as root user $N"
    exit 1
else
  echo -e "$G Running as root user $N"
fi

Validate(){
  if [ $1 -ne 0 ]; then
    echo -e "$2..$R failed $N"
    exit 1
  else
    echo -e "$2..$G successful $N"
  fi
}

dnf install mysql-server -y &>>$LOGFILE
Validate $? "MySQL installation"

systemctl enable mysqld &>> $LOGFILE
Validate $? "Enabling MySQL service"

systemctl start mysqld &>> $LOGFILE
Validate $? "Starting MySQL service"

#mysql_secure_installation --set-root-pass ExpenseApp@123 &>> $LOGFILE
#Validate $? "Setting up root password"
mysql -h localhost -uroot -p$MYSQL_ROOT_PASSWORD -e 'show databases;' &>> $LOGFILE
if [ $? -ne 0 ]; then
  mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>> $LOGFILE
  Validate $? "Setting up root password"
else
  echo -e "MySQL root password is correct..$Y Skipping $N"
fi
