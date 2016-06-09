#!/bin/bash -xe

. /home/jenkins/ci_openrc
. $FUNCTION_PATH/functions.sh
ssh-keygen -R $controller_ip
ssh $host_ip -l $host_username 'sshpass -p $host_ssh_password scp -o StrictHostKeyChecking=no -r mitaka $controller_user@$controller_ip:'
upload_images $controller_ip $controller_user $controller_password
