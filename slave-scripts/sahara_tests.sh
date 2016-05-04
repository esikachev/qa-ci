. $FUNCTION_PATH/functions.sh

SAHARA_TESTS_PATH=${1:-$WORKSPACE}
get_dependency "$SAHARA_TESTS_PATH" "openstack/sahara-tests" "master"

plugin=$(echo $JOB_NAME | awk -F '-' '{ print $3 }')

case $plugin in
    ambari_2.3)
       template_image_prefix="ambari_2_1"
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


write_tests_conf "$cluster_name" "$template_image_prefix" "$plugin" "-p $params"