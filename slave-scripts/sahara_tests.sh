#!/bin/bash -xe

. $FUNCTION_PATH/functions.sh

. /var/lib/jenkins/credentials
. /var/lib/jenkins/openrc
export SAHARA_TESTS_PATH=$WORKSPACE/sahara-tests
get_dependency "$SAHARA_TESTS_PATH" "openstack/sahara-tests" "master"
template_vars_file=$WORKSPACE/sahara-tests/template_vars.ini


plugin=$(echo $JOB_NAME | awk -F '-' '{ print $3 }')

case $plugin in
    ambari_2.3)
       template_image_prefix="ambari_2_1"
       nic_net=$(sshpass -p $controller_password ssh $controller_username@$controller_ip ". openrc && neutron net-list | grep 'admin_internal_net' | awk '{print\$2}'")
       sshpass -p $controller_password ssh $controller_username@$controller_ip ". openrc && nova boot --image mirror --flavor m1.small --security-groups default --nic net-id=$nic_net mirror"
       ip=$(sshpass -p $controller_password ssh $controller_username@$controller_ip ". openrc && nova show mirror | grep 'admin_internal_net network' | awk '{print\$5}'")
       port=$(sshpass -p $controller_password ssh $controller_username@$controller_ip ". openrc && neutron port-list | grep $ip | awk '{print\$2}'")
       sshpass -p $controller_password ssh $controller_username@$controller_ip ". openrc && neutron floatingip-create --port-id $port admin_floating_net"
       new_ip=$(sshpass -p $controller_password ssh $controller_username@$controller_ip ". openrc && neutron floatingip-list | grep '$ip' | awk '{print\$6}'")
       hdp=http://$new_ip/hdp/centos6/2.x/updates/2.3.4.7/
       hdp_utils=http://$new_ip/hdp-utils/repos/centos6/
       sed -i "/cluster_configs:/a \ \ \ \ \ \ \ \ \general:\n \ \ \ \ \ \ \ \ \ HDP repo URL: $hdp\n \ \ \ \ \ \ \ \ \ \HDP-UTILS repo URL: $hdp_utils" $SAHARA_TESTS_PATH/sahara_tests/scenario/defaults/ambari-2.3.yaml.mako
       ;;
    vanilla_2.7.1)
       template_image_prefix="vanilla_two_seven_one"
       ;;
    transient)
       plugin=vanilla_2.7.1
       template_image_prefix="vanilla_two_seven_one"
       ;;
    cdh_5.5.0)
       template_image_prefix="cdh_5_5_0"
       ;;
    spark_1.6.0)
       template_image_prefix="spark_1_6"
       ;;
    mapr_5.1.0.mrv2)
       template_image_prefix="mapr_510mrv2"
       ;;
esac

params=$(echo $plugin | sed 's/_/ -v /g')

write_tests_conf "test" "$template_image_prefix" "$plugin"
run_tests "$template_vars_file"  "$plugin"
if [ "$plugin" = "ambari_2.3" ]
then
  sshpass -p $controller_password ssh $controller_username@$controller_ip ". openrc && nova delete mirror"
fi
