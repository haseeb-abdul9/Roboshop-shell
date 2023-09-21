script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh


func_print_head "create mongo repo"
cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
func_stat_check $?

func_print_head "install mongodb"
dnf install mongodb-org -y&>>$log_file
func_stat_check $?

func_print_head "change listen port"
sed -i -e "s|127.0.0.1|0.0.0.0|" /etc/mongod.conf &>>$log_file
func_stat_check $?


func_print_head "start mongodb"
systemctl enable mongod &>>$log_file
func_stat_check $?
systemctl restart mongod &>>$log_file
func_stat_check $?

