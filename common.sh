app_user=roboshop
mysql_root_pass=$1
rabbitmq_pass=$1

func_print_head() {
  echo -e "\e[35m>>>>>>>> $1 <<<<<<<<\e[0m"
}

func_schema_setup() {
  if [ "$schema_setup" == "mongo" ]; then
    func_print_head "create mongo repo"
    cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo

    func_print_head "load schema"
    dnf install mongodb-org-shell -y
    mongo --host mongodb-dev.haseebdevops.online </app/schema/${component}.js
  fi
  if [ "$schema_setup" == "mysql"]; then
    func_print_head "load schema"
      dnf install mysql -y

      func_print_head "Change MySQl default password"
      mysql -h mysql-dev.haseebdevops.online -uroot -p${mysql_root_pass} < /app/schema/shipping.sql
  fi
}


func_app_prereq() {
  func_print_head "add app user & directory"
    useradd ${app_user}
    rm -rf /app
    mkdir /app

    func_print_head "download & unzip app content"
    curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip
    cd /app
    unzip /tmp/${component}.zip
}

func_systemd_setup() {
   func_print_head "create ${component} service file"
    cp ${script_path}/${component}.service /etc/systemd/system/${component}.service

    func_print_head "start ${component}"
    systemctl daemon-reload
    systemctl enable ${component}
    systemctl restart ${component}
}

func_nodejs() {
  func_print_head "download nodejs"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash

  func_print_head "install nodejs"
  dnf install nodejs -y

  func_app_prereq

  func_print_head "install NPM"
  npm install

  func_systemd_setup
  func_schema_setup
}

func_python() {
  func_print_head "install python"
  dnf install python36 gcc python3-devel -y

  func_app_prereq

  func_print_head "download dependencies"
  pip3.6 install -r requirements.txt

  func_systemd_setup
}

func_java() {
  func_print_head "install java"
  dnf install maven -y

  func_app_prereq

  func_print_head "download dependencies"
  mvn clean package
  mv target/shipping-1.0.jar shipping.jar

  func_schema_setup
  func_systemd_setup
}