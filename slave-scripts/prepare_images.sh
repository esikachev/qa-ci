#!/bin/bash -xe

. /home/jenkins/ci_openrc
. $FUNCTION_PATH/functions.sh
ssh-keygen -R $controller_ip
ssh $host_ip -l qa 'sshpass -p $host_ssh_password scp -o StrictHostKeyChecking=no -r mitaka $host_ssh_user@$controller_ip:'
upload_images $controller_ip $host_ssh_user $host_ssh_password
