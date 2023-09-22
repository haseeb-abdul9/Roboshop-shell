app_user=roboshop
mysql_root_pass=$1
rabbitmq_pass=$1
log_file=/tmp/roboshop.log

func_print_head() {
  echo -e "\e[35m>>>>>>>> $1 <<<<<<<<\e[0m"
  echo -e "\e[35m>>>>>>>> $1 <<<<<<<<\e[0m" &>>$log_file
}
func_stat_check() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[32mSuccess\e[0m"
  else
    echo -e "\e[31mFailure\e[0m"
    echo -e "Refer /tmp/roboshop.log for more information"
    exit 1
  fi
}

func_schema_setup() {
  if [ "$schema_setup" == "mongo" ]; then
    func_print_head "create mongo repo"
    cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
    func_stat_check $?

    func_print_head "load schema"
    dnf install mongodb-org-shell -y &>>$log_file
    func_stat_check $?
    mongo --host mongodb-dev.haseebdevops.online </app/schema/${component}.js &>>$log_file
    func_stat_check $?
  fi
  if [ "$schema_setup" == "mysql" ]; then
    func_print_head "load schema"
    dnf install mysql -y &>>$log_file
    func_stat_check $?

    func_print_head "Change MySQl default password"
    mysql -h mysql-dev.haseebdevops.online -uroot -p${mysql_root_pass} < /app/schema/shipping.sql &>>$log_file
    func_stat_check $?
  fi
}


func_app_prereq() {
  func_print_head "add app user & directory"
    id ${app_user} &>>$log_file
    if [ $? -ne 0 ]; then
      useradd ${app_user} &>>$log_file
    fi
    func_stat_check $?
    rm -rf /app &>>$log_file
    func_stat_check $?
    mkdir /app &>>$log_file
    func_stat_check $?

    func_print_head "download & unzip app content"
    curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>$log_file
    func_stat_check $?
    cd /app &>>$log_file
    func_stat_check $?
    unzip /tmp/${component}.zip &>>$log_file
    func_stat_check $?
}

func_systemd_setup() {
   func_print_head "create ${component} service file"
    cp ${script_path}/${component}.service /etc/systemd/system/${component}.service &>>$log_file
    func_stat_check $?

    func_print_head "start ${component}"
    systemctl daemon-reload &>>$log_file
    systemctl enable ${component} &>>$log_file
    systemctl restart ${component} &>>$log_file
    func_stat_check $?
}

func_nodejs() {
  func_print_head "download nodejs"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$log_file
  func_stat_check $?

  func_print_head "install nodejs"
  dnf install nodejs -y &>>$log_file
  func_stat_check $?

  func_app_prereq

  func_print_head "install NPM"
  npm install &>>$log_file
  func_stat_check $?

  func_systemd_setup
  func_schema_setup
}

func_python() {
  func_print_head "install python"
  dnf install python36 gcc python3-devel -y &>>$log_file
  func_stat_check $?

  func_app_prereq

  func_print_head "download dependencies"
  pip3.6 install -r requirements.txt &>>$log_file
  func_stat_check $?

  func_systemd_setup
}

func_java() {
  func_print_head "install java"
  dnf install maven -y &>>$log_file
  func_stat_check $?

  func_app_prereq

  func_print_head "download dependencies"
  mvn clean package &>>$log_file
  func_stat_check $?
  mv target/shipping-1.0.jar shipping.jar &>>$log_file
  func_stat_check $?

  func_schema_setup
  func_systemd_setup
}