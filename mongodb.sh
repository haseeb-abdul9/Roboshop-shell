script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh


func_print_head "create mongo repo"
cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo

func_print_head "install mongodb"
dnf install mongodb-org -y

func_print_head "change listen port"
sed -i -e "s|127.0.0.1|0.0.0.0|" /etc/mongod.conf


func_print_head "start mongodb"
systemctl enable mongod
systemctl restart mongod

