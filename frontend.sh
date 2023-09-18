script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

component=frontend

func_print_head "install nginx"
dnf install nginx -y

func_print_head "remove nginx content"
rm -rf /usr/share/nginx/html/*

func_print_head "frontend content"
curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip

func_print_head "unzip frontend content"
cd /usr/share/nginx/html
unzip /tmp/${component}.zip

func_print_head "configure nginx reverse proxy"
cp ${script_path}/roboshop.conf /etc/nginx/default.d/roboshop.conf

func_print_head "start nginx"
systemctl enable nginx
systemctl restart nginx 