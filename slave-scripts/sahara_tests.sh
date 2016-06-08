#!/bin/bash -xe

. $FUNCTION_PATH/functions.sh

export SAHARA_TESTS_PATH=$WORKSPACE/sahara-tests
get_dependency "$SAHARA_TESTS_PATH" "openstack/sahara-tests" "master"
template_vars_file=$WORKSPACE/sahara-tests/template_vars.ini


plugin=$(echo $JOB_NAME | awk -F '-' '{ print $3 }')

case $plugin in
    ambari_2.3)
       template_image_prefix="ambari_2_1"
       nova boot --image mirror --flavor m1.small --security-groups default mirror
       floating_ip=$(nova floating-ip-create | awk '{ print $4 }')
       nova floating-ip-associate mirror floating_ip
       hdp=http://$floating_ip/hdp/centos6/2.x/updates/2.3.4.7/
       hdp_utils=http://$floating_ip/hdp-utils/repos/centos6/
       sed -i '/cluster_configs:/a \ \ \ \ \ \ \ \ \general:\n \ \ \ \ \ \ \ \ \ \HDP: $hdp\n \ \ \ \ \ \ \ \ \ \HDP-UTILS: $hdp_utils' $SAHARA_TESTS_PATH/sahara_tests/scenario/defaults/ambari-2.3.yaml.mako
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
