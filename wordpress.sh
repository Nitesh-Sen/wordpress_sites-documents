#!/bin/bash


yum update -y
mkdir -p /var/www/html/
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-04902cdce2e2dd4a7.efs.us-east-1.amazonaws.com:/ /var/www/html/
echo "fs-04902cdce2e2dd4a7.efs.us-east-1.amazonaws.com:/ /var/www/html/ efs defaults,_netdev 0 0"  >> /etc/fstab
yum install -y amazon-efs-utils
yum install -y httpd
systemctl start httpd
systemctl enable httpd
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
cd /var/www/html/
rm -rf index.html
sudo systemctl restart httpd
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1WIsgAWS23riR/jgoZKSP1TwnCr8WzsAeUrgCcR+pYCTCHckae2e/9fSE0+htSGZeAtB7WBOB7LHkvTmC3P+RqbvuK2bg5wvm1ih8rG0bS3ZxcjMr/q9WIM51YVhkdOHso+QCPgUdZXy8L5F9DwZWOMxrtGk2pvycScEwsFnbPlw3rDPREVMTWQSE5jJQRv8PgBMx7txjq0BZRydY54VPkBSNNRKXb+M4fg2bPremqQzY2Qu3SCALzSTTGGks6GHfF72hpW+4pfDvXdGXq39O8QGoZd8aDAvKabYaZ3v0sk/8xJa+e/KeMjOSO2KtJrpTMenYqwYj9bdganm4vld9r7lvM25OP6IFZgNPcM03eOQ9+ebONsvCW6wrvE9R9BcjPOhqZtRtuQ0OH6FIriWZbF5ACHCEOJiI6VMoIDNGqd8CSOqyYllPTVWRCt7XnRjyXjzDb+k9hNogJdDPfqymp5K39iEYR4d3hEjhZVPmu5xqNO/vaCFvy2r23y1J5hU= amit@inspiron" >> /home/ec2-user/.ssh/authorized_keys
DD_AGENT_MAJOR_VERSION=7 DD_UPGRADE=true DD_SITE="us5.datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
aws s3 cp s3://wordpress-document/datadog.yaml /etc/datadog-agent/datadog.yaml
systemctl start datadog-agent
systemctl enable datadog-agent
aws s3 cp s3://wordpress-document/datadog.yaml /etc/datadog-agent/
aws s3 cp s3://wordpress-document/httpd.conf /etc/httpd/conf/
aws s3 cp s3://wordpress-document/conf.yaml /etc/datadog-agent/conf.d/apache.d/
sudo systemctl restart httpd
systemctl restart datadog-agent

