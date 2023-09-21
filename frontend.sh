script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

component=frontend

func_print_head "install nginx"
dnf install nginx -y &>>$log_file

func_print_head "remove nginx content"
rm -rf /usr/share/nginx/html/* &>>$log_file

func_print_head "frontend content"
curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>$log_file

func_print_head "unzip frontend content"
cd /usr/share/nginx/html &>>$log_file
unzip /tmp/${component}.zip &>>$log_file

func_print_head "configure nginx reverse proxy"
cp ${script_path}/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$log_file

func_print_head "start nginx"
systemctl enable nginx &>>$log_file
systemctl restart nginx &>>$log_file