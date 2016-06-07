controller_ip=`sshpass -p r00tme ssh 10.20.0.2 -l root 'fuel node | grep controller' | awk '{print $10}'`
compute_ip=`sshpass -p r00tme ssh 10.20.0.2 -l root 'fuel node | grep compute' | awk '{print $10}'`

sshpass -p r00tme ssh 10.20.0.2 -l root "ssh $controller_ip 'iptables -A INPUT -p tcp -m multiport --ports 22 -j ACCEPT'"
pass_auth_command="sed -i 's/PasswordAuthentication[[:space:]]no/PasswordAuthentication\ yes/g' /etc/ssh/sshd_config"
sshpass -p r00tme ssh 10.20.0.2 -l root ssh $controller_ip "$pass_auth_command"
sshpass -p r00tme ssh 10.20.0.2 -l root ssh $controller_ip "service ssh restart"

sshpass -p r00tme ssh 10.20.0.2 -l root ssh $compute_ip "mount -o remount,rw,nobarrier /dev/mapper/vm-nova /var/lib/nova"
pass_auth_command="sed -i 's/\/var\/lib\/nova[[:space:]]xfs[[:space:]]defaults/\/var\/lib\/nova\ xfs\ defaults,nobarrier/g' /etc/fstab"
sshpass -p r00tme ssh 10.20.0.2 -l root ssh $controller_ip "$pass_auth_command"
