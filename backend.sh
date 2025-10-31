#!/bin/bash
# Install Backend Dependencies
ID=$(id -u)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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