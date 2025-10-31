#!/bin/bash
# Install MySQL
ID=$(id -u)
TIME_STAMP=$(date '+%Y-%m-%d %H:%M:%S')
SCRIPT_NAME=$(echo $0 | cut -d'.' -f1)
LOGFILE=/tmp/${SCRIPT_NAME}-${TIME_STAMP}.log
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
NO="\e[0m"
if [ $ID -ne 0 ]; then
  echo -e "${RED}Please run as root user${NO}"
    exit 1
else
  echo -e "${GREEN}Running as root user${NO}"
fi
validate(){
  if [ $1 -ne 0 ]; then
    echo -e "${RED}$2.. failed${NO}" &>> $LOGFILE
    exit 1
  else
    echo -e "${GREEN}$2.. successful${NO}" &>> $LOGFILE
  fi
}
dnf install mysql-server -y &>> $LOGFILE
validate $? "MySQL installation"
#systemctl enable mysqld &>> $LOGFILE
#validate $? "Enable MySQL service"  
#systemctl start mysqld &>> $LOGFILE
#validate $? "Start MySQL service"
#mysql_secure_installation --set-root-pass ExpenseApp@123 &>> $LOGFILE
#validate $? "Secure MySQL installation"
