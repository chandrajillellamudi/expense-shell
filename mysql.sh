#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$( echo $0 | cut -d'.' -f1)
LOG_FILE=/tmp/${SCRIPT_NAME}_${TIMESTAMP}.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
# echo "Please enter your MySQL root password:"
# read -s MYSQL_ROOT_PASSWORD
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

dnf install mysql-server -y &>> $LOG_FILE
validate $? "MySQL installation"

systemctl start mysqld &>> $LOG_FILE
validate $? "Starting MySQL service"    

systemctl enable mysqld &>> $LOG_FILE
validate $? "Enabling MySQL service at boot"    

mysql_secure_installation --set-root-pass ExpenseApp@1 &>> $LOG_FILE
validate $? "Securing MySQL installation"

mysql -uroot -pExpenseApp@1 < /home/ec2-user/expense-shell/backend.sql &>> $LOG_FILE
validate $? "Importing Database Schema"


# mysql -h dbchandradevops.online -uroot -p$MYSQL_ROOT_PASSWORD -e "show databases;" &>> $LOG_FILE
# if [ $? -ne 0 ];
# then
# mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>> $LOG_FILE
# validate $? "root password setup"
# else
#   echo -e "MySQL is already secured..${Y}SKIPPING${N}"
# fi


