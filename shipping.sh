script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

component=shipping

if [ -z "$mysql_root_pass" ]; then
  echo mysql_root_pass missing
  exit
fi

print_head "install java"
dnf install maven -y

print_head "create app user & directory"
useradd ${app_user}
rm -rf /app
mkdir /app

print_head "download & unzip app content"
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip
cd /app
unzip /tmp/shipping.zip

print_head "download dependencies"
mvn clean package
mv target/shipping-1.0.jar shipping.jar

print_head "create service file"
cp ${script_path}/${component}.service /etc/systemd/system/${component}.service

print_head "load service"
systemctl daemon-reload

print_head "start ${component}"
systemctl enable ${component}
systemctl start ${component}

print_head "load schema"
dnf install mysql -y

print_head "Change MySQl default password"
mysql -h mysql-dev.haseebdevops.online -uroot -p${mysql_root_pass} < /app/schema/shipping.sql

print_head "restart ${component}"
systemctl restart ${component}