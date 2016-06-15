. /var/lib/jenkins/credentials

local_controller_ip=`sshpass -p $host_ssh_password ssh $host_username@$host_ip "sshpass -p $controller_password ssh $controller_username@$master_ip 'fuel node | grep controller' | awk '{print $10}'"`
compute_ip=`sshpass -p $host_ssh_password ssh $host_username@$host_ip "sshpass -p $controller_password ssh $controller_username@$master_ip 'fuel node | grep compute' | awk '{print $10}'"`

sshpass -p $host_ssh_password ssh $host_username@$host_ip "sshpass -p $controller_password ssh $controller_username@$master_ip "ssh $local_controller_ip 'iptables -A INPUT -p tcp -m multiport --ports 22 -j ACCEPT'""
sshpass -p $host_ssh_password ssh $host_username@$host_ip "pass_auth_command="sed -i 's/PasswordAuthentication[[:space:]]no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config""
sshpass -p $host_ssh_password ssh $host_username@$host_ip "sshpass -p $controller_password ssh $controller_username@$master_ip ssh $local_controller_ip "$pass_auth_command""
sshpass -p $host_ssh_password ssh $host_username@$host_ip "sshpass -p $controller_password ssh $controller_username@$master_ip ssh $local_controller_ip "service ssh restart""

sshpass -p $host_ssh_password ssh $host_username@$host_ip "sshpass -p $controller_password ssh $controller_username@$master_ip ssh $compute_ip "mount -o remount,rw,nobarrier /dev/mapper/vm-nova /var/lib/nova""
sshpass -p $host_ssh_password ssh $host_username@$host_ip "pass_auth_command="sed -i 's/\/var\/lib\/nova[[:space:]]xfs[[:space:]]defaults/\/var\/lib\/nova\ xfs\ defaults,nobarrier/g' /etc/fstab""
sshpass -p $host_ssh_password ssh $host_username@$host_ip "sshpass -p $controller_password ssh $controller_username@$master_ip ssh $compute_ip "$pass_auth_command""
