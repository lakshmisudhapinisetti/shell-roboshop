#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.luckyy.shop

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? " Disabling the redis "

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "enabling the redis-7"

dnf install redis -y &>>$LOGS_FILE
VALIDATE $? " Installing the redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"

sudo sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
VALIDATE $? "Changing the mode"

systemctl enable redis &>>$LOGS_FILE
systemctl start redis 
VALIDATE $? "Enabling & starting the redis"

