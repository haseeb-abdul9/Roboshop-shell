script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

if [ -z "$rabbitmq_pass" ]; then
  echo rabbitmq_pass missing
  exit
fi

print_head "configure rabbitmq yum repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash

print_head "install rabbitmq server"
dnf install rabbitmq-server -y

print_head "add username & pass"
rabbitmqctl add_user roboshop ${rabbitmq_pass}
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

print_head "start service"
systemctl enable rabbitmq-server
systemctl start rabbitmq-server
systemctl restart rabbitmq-server