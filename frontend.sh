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

dnf module list nginx &>>$LOGS_FILE
VALIDATE $? "listing of NodeJS "

dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "Disabling the NodeJS"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATE $? " Enabling NodeJS 1.24"

dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "installing NodeJS"

systemctl enable nginx -y &>>$LOGS_FILE
systemctl start nginx 

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing existing code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloading front code"

cd /usr/share/nginx/html 
VALIDATE $? "Moving to app directory"

unzip /tmp/frontend.zip
VALIDATE $? "Uzip catalogue code"

cp $SCRIPT_DIR/nginx.config /etc/nginx/nginx.config
VALIDATE $? "Created Nginx reverse proxy"

systemctl restart nginx
VALIDATE $? "Restarting catalogue"
