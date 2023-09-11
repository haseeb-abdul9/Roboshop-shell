script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

component=frontend

print_head "install nginx"
dnf install nginx -y

print_head "remove nginx content"
rm -rf /usr/share/nginx/html/*

print_head "frontend content"
curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip

print_head "unzip frontend content"
cd /usr/share/nginx/html
unzip /tmp/${component}.zip

print_head "configure nginx reverse proxy"
cp ${script_path}/roboshop.conf /etc/nginx/default.d/roboshop.conf

print_head "start nginx"
systemctl enable nginx
systemctl start nginx
systemctl restart nginx 