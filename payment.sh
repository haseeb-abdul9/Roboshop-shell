script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

if [ -z "$rabbitmq_pass" ]; then
  echo rabbitmq_pass missing
  exit
fi


print_head "install python"
dnf install python36 gcc python3-devel -y

print_head "create app user & directory"
useradd roboshop
rm -rf /app
mkdir /app

print_head "download & unzip app content"
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment.zip
cd /app
unzip /tmp/payment.zip

print_head "download dependencies"
pip3.6 install -r requirements.txt

print_head "create service file"
sed -i -e "s|rabbitmq_pass|${rabbitmq_pass}" ${script_path}/payment.service
cp ${script_path}/payment.service /etc/systemd/system/payment.service

print_head "start service"
systemctl daemon-reload
systemctl enable payment
systemctl start payment
systemctl restart payment