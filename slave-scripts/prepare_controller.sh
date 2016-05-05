controller_ip=`sshpass -p r00tme ssh 10.20.0.2 -l root 'fuel node | grep controller' | awk '{print $9}'`

sshpass -p r00tme ssh 10.20.0.2 -l root "ssh $controller_ip 'iptables -A INPUT -p tcp -m multiport --ports 22 -j ACCEPT'"
pass_auth_command="sed -i 's/PasswordAuthentication[[:space:]]no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config"
sshpass -p r00tme ssh 10.20.0.2 -l root ssh $controller_ip "$pass_auth_command"
sshpass -p r00tme ssh 10.20.0.2 -l root ssh $controller_ip "service ssh restart"
