#!/bin/bash -xe

export JENKINS_HOME=/var/lib/jenkins
. $JENKINS_HOME/ci_openrc
. $FUNCTION_PATH/functions.sh
ssh-keygen -R $controller_ip
ssh $host_ip -l $host_username 'sshpass -p $controller_password scp -o StrictHostKeyChecking=no -r mitaka $controller_username@$controller_ip:'
upload_images $controller_ip $controller_username $controller_password
