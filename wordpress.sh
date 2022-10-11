#!/bin/bash

###   Update your System Package 
yum update -y

###   Make path for EFS Volume
mkdir -p /var/www/html/

###   Mount the Volume with Instance
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0xxxxxxxxxxxxx7.efs.us-east-1.amazonaws.com:/ /var/www/html/

###   Mounting your Amazon EFS file system automatically whenever you reboot your instance.
echo "fs-0xxxxxxxxxxe.efs.us-east-1.amazonaws.com:/ /var/www/html/ nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0"  >> /etc/fstab

###   Install some package of PHP for run wordpress and insalling the Apache
yum install -y amazon-efs-utils
yum install -y httpd
systemctl start httpd
systemctl enable httpd
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
cd /var/www/html/
rm -rf index.html

###   Restart the Apache
sudo systemctl restart httpd

###   Add the public key of other engineer who can ssh in instace after adding this pulic key. if he have its private key.
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1WIsgAWS23riR/jxxxxxxxxxxxxxxxxxxxxxxxxxxxxxvm1ih8rG0bS3ZxcjMrxxxxxxxxxxxxxxxxxxxxxxxxycScEwsFnbPlw3rDPREVMTWQSExxxxxxxxxxxxxxxxxxNNRKXb+M4fg2bPremqQzY2Qu3SCALzSTTGGks6GHfF72hpW+4pfDvXdGXq39O8QGoZd8aDAvKabYaZ3v0sk/8xJa+e/KeMjOSO2KtJrpTMenYqwYj9bdganm4vld9r7lvM25OP6IFZgNPcM03eOQ9+ebONsvCW6wrvE9R9BcjPOhqZtRtuQ0OH6FIriWZbF5ACHCEOJiI6VMoIDNGqd8CSOqyYllPTVWRCt7XnRjyXjzDb+k9hNogJdDPfqymp5K39iEYR4d3hEjhZVPmu5xqNO/vaCFvy2r23y1J5hU= amit@inspiron" >> /home/ec2-user/.ssh/authorized_keys

###   Installing the DataDog agent in instance for Monitorng all data in instance(cpu, memory, logs, etc...)
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=6xxxxxxxxxxxxx41ba DD_SITE="us5.datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
#################### If first is not word then you have to use this second command. which is commented.###############################
#DD_AGENT_MAJOR_VERSION=7 DD_UPGRADE=true DD_SITE="us5.datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
aws s3 cp s3://wordpress-document/datadog.yaml /etc/datadog-agent/datadog.yaml

###   Start the datadog-agent and enable it. Enable for whenever you reboot your machine then it automatically start. If you did enable it
systemctl start datadog-agent
systemctl enable datadog-agent

###   Change the permissin of httpd logs file. This is for Datadog monitor all logs of apache. 
cd /var/log/ ; chmod 655 -R httpd


aws s3 cp s3://wordpress-document/datadog.yaml /etc/datadog-agent/
aws s3 cp s3://wordpress-document/httpd.conf /etc/httpd/conf/
aws s3 cp s3://wordpress-document/conf.yaml /etc/datadog-agent/conf.d/apache.d/
sudo systemctl restart httpd
systemctl restart datadog-agent
