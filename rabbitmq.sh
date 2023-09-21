script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

if [ -z "$rabbitmq_pass" ]; then
  echo rabbitmq_pass missing
  exit
fi

print_head "configure erlang & rabbitmq yum repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$log_file
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$log_file

print_head "install rabbitmq server"
dnf install rabbitmq-server -y &>>$log_file

print_head "start service"
systemctl enable rabbitmq-server &>>$log_file
systemctl restart rabbitmq-server &>>$log_file

print_head "add username & pass"
rabbitmqctl add_user roboshop ${rabbitmq_pass} &>>$log_file
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$log_file

