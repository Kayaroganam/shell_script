#!/bin/bash
#
# Author: Kayaroganam
# Target: Deploying BillingApp
#

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

db_user="kayar" #Enter username for database
db_pass="kayar" #Enter password for database
db_name="bill" #Enter database name to create
email="kayarogan2003@gmail.com" #Enter your gamail id | note: Onlye gamil
app_pass="rxynvahxkluzqykg" #create app password on your google account and put here


flag="null"

for i in $(cat /etc/os-release)
do
    if [ $i == 'ID=ubuntu' ]
    then
        flag="Ubuntu"
    elif [ $i == 'ID="centos"' ]
    then
        flag="Centos"
    fi
done

echo $flag

#----------------------------------------------------------
if [ $flag == "Centos" ]
then
    sudo dnf update -y 
    check "system-update"

    sudo dnf install python3 -y 
    check "python-installation"

    sudo dnf install python3-pip -y 
    check "python3-pip-installation"

    sudo pip3 install flask mysql-connector-python 
    check "python-modules-installation"


    sudo dnf install mysql-server -y
    check "mysql-server-installation" 

    sudo systemctl enable --now mysqld.service
    check "mysqld.service-start"

    sudo systemctl enable --now mysqld.service
    check "mysqld.service-start"

    sudo firewall-cmd --permanent --add-port=3306/tcp
    sudo firewall-cmd --permanent --add-port=5000/tcp
    sudo firewall-cmd --reload

    sudo mysql -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'localhost';"
    sudo mysql -e "FLUSH PRIVILEGES;"
    check "database-configuration"

    sudo dnf install git 
    check "git-installation"

elif [ $flag == "Ubuntu" ]
then
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
fi
#---------------------------------------------------------------------------------


sudo git clone https://github.com/Kayaroganam/BillingApp.git /opt/BillingApp 
check "repository-download"

sudo chmod -R 777 /opt/BillingApp
check "permission-setting "

sudo cat > /opt/BillingApp/database_structure.sql <<-EOF
CREATE DATABASE $db_name;
USE $db_name;
CREATE TABLE item_list(id INT NOT NULL AUTO_INCREMENT, item_name VARCHAR(255) NOT NULL, item_price FLOAT NOT NULL, PRIMARY KEY(id));
CREATE TABLE selected_items(id INT NOT NULL AUTO_INCREMENT, item_id INT NOT NULL, qty FLOAT NOT NULL, price FLOAT NOT NULL, PRIMARY KEY(id));
ALTER TABLE selected_items ADD selected_item_name VARCHAR(255) NOT NULL AFTER item_id;
CREATE TABLE logs(id INT NOT NULL AUTO_INCREMENT, selected_item_id INT NOT NULL, selected_qty FLOAT NOT NULL,price FLOAT,date_time DATETIME, PRIMARY KEY(id));
INSERT INTO item_list(item_name,item_price) VALUES('item1',100);
INSERT INTO item_list(item_name,item_price) VALUES('item2',20);
INSERT INTO item_list(item_name,item_price) VALUES('item3',200);
INSERT INTO item_list(item_name,item_price) VALUES('item4',184);
INSERT INTO item_list(item_name, item_price ) VALUES('test1',10);
EOF

mysql -u $db_user -p$db_pass < /opt/BillingApp/database_structure.sql

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
