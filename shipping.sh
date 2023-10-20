script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh


if [ -z "$mysql_root_pass" ]; then
  echo mysql_root_pass missing
  exit 1
fi

component=shipping
schema_setup=mysql
func_java