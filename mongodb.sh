script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh


print_head "create mongo repo"
cp mongo.repo /etc/yum.repos.d/mongo.repo

print_head "install mongodb"
dnf install mongodb-org -y

print_head "change listen port"
sed -i -e "s|127.0.0.1|0.0.0.0|" /etc/mongod.conf


print_head "start mongodb"
systemctl enable mongod
systemctl start mongod
systemctl restart mongod

