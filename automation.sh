#!/bin/bash

# Task 2
#variables
name="mohammad"
s3_bucket="upgrad-mohammad"

#Perform an update of the package details and the package list at the start of the script.
apt update -y

#Install the apache2 package if it is not already installed. (The dpkg and apt commands are used to check the installation of the packages.)
if [[ apache2 != $(dpkg --get-selections apache2 | awk '{print $1}') ]]
then

	apt install apache2 -y
fi

#Ensure that the apache2 service is running.
running=$(systemctl status apache2 | grep active | awk '{print $3}' | tr -d '()')
if [[ running != ${running} ]]; then
	systemctl start apache2
fi

#Ensure that the apache2 service is enabled.
enabled=$(systemctl is-enabled apache2 | grep "enabled")
if [[ enabled != ${enabled} ]]; then
	systemctl enable apache2
fi

#Create a tar archive of apache2 access logs and error logs that are present in the /var/log/apache2/ directory

timestamp=$(date '+%d%m%Y-%H%M%S')


cd /var/log/apache2
tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log



#The script should run the AWS CLI command and copy the archive to the s3 bucket.
if [[ -f /tmp/${name}-httpd-logs-${timestamp}.tar ]]; then
	aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar
fi

# Task 3

sudo apt update
sudo apt install awscli
#Make the script executible
chmod  +x  /root/Automation_Projects/automation.sh
#switch to root user with sudo su
sudo  su
./root/Automation_Project/automation.sh

# or run with sudo privileges
sudo ./root/Automation_Projects/automation.sh
docroot="/var/www/html"

#Bookkeeping -- check if the file exists
if [[ ! -f ${docroot}/inventory.html ]]; then
	echo -e 'Log Type\t-\tTime Created\t-\tType\t-\tSize' > ${docroot}/inventory.html
fi

#insert logs to file
if [[ -f ${docroot}/inventory.html ]]; then
	size=$(du -h /tmp/${name}-httpd-logs-${timestamp}.tar | awk '{print $1}')
	echo -e "httpd-logs\t-\t${timestamp}\t-\ttar\t-\t${size}" >> ${docroot}/inventory.html
fi

# Cron Job
if [[ ! -f /etc/cron.d/automation ]]; then
	echo "* * * * * root /root/devops/automation.sh" >> /etc/cron.d/automation
fi
