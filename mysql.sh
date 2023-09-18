script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

if [ -z "$mysql_root_pass" ]; then
  echo mysql_root_pass missing
  exit
fi

func_print_head "disable default mysql"
dnf module disable mysql -y

func_print_head "setup mysql 5.7 repo"
cp ${script_path}/mysql.repo /etc/yum.repos.d/mysql.repo

func_print_head "install mysql server"
dnf install mysql-community-server -y

func_print_head "start service"
systemctl enable mysqld
systemctl start mysqld

func_print_head "set mysql_root_password"
mysql_secure_installation --set-root-pass ${mysql_root_pass}