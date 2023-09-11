script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

print_head "download redis & enable 6.2 version"
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
dnf module enable redis:remi-6.2 -y

print_head "install redis"
dnf install redis -y

print_head "change listen port"
sed -i -e "s|127.0.0.1|0.0.0.0|" /etc/redis.conf /etc/redis/redis.conf

print_head "start redis"
systemctl enable redis
systemctl start redis
systemctl restart redis