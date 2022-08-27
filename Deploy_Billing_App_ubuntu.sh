#!/bin/bash

function print_color(){
        RED='\e[0;31m'
        GREEN='\e[0;32m'
        NC='\e[0m' # No Color

        if [ $1 == 'red' ]
        then
                echo -e "$RED $2 [FAILD] $NC"
        elif [ $1 == 'green' ]
        then
                echo -e "$GREEN $2 [SUCCESS] $NC"
        else
                echo ""
        fi
}

function check(){
        if [ $? -eq 0 ]
        then
                print_color green $1
        else
                print_color red $1
        fi
}

db_user="kayar"
db_pass="kayar"
email="kayarogan2003@gmail.com"
app_pass="rxynvahxkluzqykg"
db_name="bill"

sudo apt update -y 
check "system-update"

sudo apt install python3 -y 
check "python-installation"

sudo apt install python3-pip -y 
check "python3-pip-installation"

sudo pip3 install flask mysql-connector-python 
check "python-modules-installation"


sudo apt install mysql-server -y
check "mysql-server-installation" 

sudo systemctl enable --now mysqld.service
check "mysqld.service-start"

sudo ufw allow 3306/tcp
sudo ufw allow 5000/tcp
sudo ufw reload

sudo mysql -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
check "database-configuration"


sudo apt install git 
check "git-installation"

sudo git clone https://github.com/Kayaroganam/BillingApp.git /opt/BillingApp 
check "repository-download"

sudo chmod -R 777 /opt/BillingApp
check "permission-setting "

sudo cat > /opt/BillingApp/variables.py <<-EOF
class var:

    #database
    Mysql_User = '$db_user'   # Change value to your myqsl username
    Mysql_Password = '$db_pass' # Change value to your mysql password
    Mysql_Database = '$db_name' # Enter Database name
    Mysql_Host = 'localhost'

    #email
    My_Email = '$email'   # Change value to your gmail id
    My_Email_Password = '$app_pass' # Create password in app password on your google account and enter here

    #Company name
    Company = 'Stationery Store' # Enter your title name
EOF
check "variable.py-configuration"


sudo python3 /opt/BillingApp/run.py
