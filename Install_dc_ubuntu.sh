wget http://kaya-16339/linux_falcon-sensor_6.45.0-14203_amd64.deb ./
sudo dpkg -i linux_falcon-sensor_6.45.0-14203_amd64.deb
sudo /opt/CrowdStrike/falconctl -s --cid=F4BF9189CB9C4CA48982E367D2F819CC-D8
sudo systemctl restart falcon-sensor
sleep 5;
sudo systemctl status falcon-sensor
