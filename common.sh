app_user=roboshop
mysql_root_pass=$1

print_head() {
  echo -e "\e[35m>>>>>>>> $1 <<<<<<<<\e[0m"
}

setup_schema() {
  if [ "$schema_setup" == "mongo" ]; then
    print_head "create mongo repo"
    cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo

    print_head "load schema"
    dnf install mongodb-org-shell -y
    mongo --host mongodb-dev.haseebdevops.online </app/schema/${component}.js
  fi
}


func_nodejs() {
  print_head "download nodejs"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash
  
  print_head "install nodejs"
  dnf install nodejs -y
  
  print_head "add app user & directory"
  useradd ${app_user}
  rm -rf /app
  mkdir /app
  
  print_head "download & unzip app content"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip
  cd /app
  unzip /tmp/${component}.zip
  
  print_head "install NPM"
  npm install
  
  print_head "create ${component} service file"
  cp ${script_path}/${component}.service /etc/systemd/system/${component}.service
  
  print_head "start ${component}"
  systemctl daemon-reload
  systemctl enable ${component}
  systemctl start ${component}
  systemctl restart ${component}
  setup_schema
}