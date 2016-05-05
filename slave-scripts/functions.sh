#!/bin/bash -xe

write_tests_conf() {
  local cluster_name=$1
  local image_prefix=$2
  local image_name=$3
  OS_USERNAME="admin"
  OS_PASSWORD="admin"
  OS_TENANT_NAME="admin"
  protocol="http"
  if [ "$SSL" == "true" ]; then
      protocol="https"
  fi
  OS_AUTH_URL="$protocol://172.18.79.153:5000/v2.0"
  NETWORK="neutron"
echo "[DEFAULT]
OS_USERNAME: $OS_USERNAME
OS_PASSWORD: $OS_PASSWORD
OS_TENANT_NAME: $OS_TENANT_NAME
OS_AUTH_URL: $OS_AUTH_URL
network_type: $NETWORK
network_public_name: admin_floating_net
network_private_name: admin_internal_net
${image_prefix}_image: $image_name
cluster_name: $cluster_name
ci_flavor_id: m1.small
medium_flavor_id: m1.medium
large_flavor_id: m1.large
" | tee ${template_vars_file}
}

get_dependency() {
  local project_dir=$1
  local project_name=$2
  local branch=$3
  git clone https://review.openstack.org/"$project_name" "$project_dir" -b "$branch"
}

run_tests() {
  local scenario_config=$1
  local plugin=$2
  params=$(echo $plugin | sed 's/_/ -v /g')
  echo "Integration tests are started"
  export PYTHONUNBUFFERED=1
  
  pushd $SAHARA_TESTS_PATH
  
  tox -e venv -- sahara-scenario --verbose -V $template_vars_file -p $params | tee tox.log
  STATUS=$(grep "\ -\ Failed" tox.log | awk '{print $3}')
  if [ "$STATUS" != "0" ]; then failure "Integration tests have failed"; fi
  popd
}

failure() {
  local reason=$1
  echo "$reason"
  exit 1
}

upload_images() {
host=$1
user=$2
pass=$3

sshpass -p $pass ssh $host -l $user ". openrc && openstack image create vanilla_2.7.1 --file mitaka/sahara-mitaka-vanilla-hadoop-2.7.1-ubuntu.qcow2 --disk-format qcow2 --container-format bare --property '_sahara_tag_2.7.1'='True' --property '_sahara_tag_vanilla'='True' --property '_sahara_username'='ubuntu'"
sshpass -p $pass ssh $host -l $user ". openrc && openstack image create ambari_2.3 --file mitaka/sahara-mitaka-ambari-2.2-centos-6.7.qcow2 --disk-format qcow2 --container-format bare --property '_sahara_tag_2.3'='True' --property '_sahara_tag_ambari'='True' --property '_sahara_username'='cloud-user'"
sshpass -p $pass ssh $host -l $user ". openrc && openstack image create cdh_5.5.0 --file mitaka/sahara-mitaka-cloudera-5.5.0-ubuntu.qcow2 --disk-format qcow2 --container-format bare --property '_sahara_tag_5.5.0'='True' --property '_sahara_tag_cdh'='True' --property '_sahara_username'='ubuntu'"
sshpass -p $pass ssh $host -l $user ". openrc && openstack image create spark_1.6.0 --file mitaka/sahara-mitaka-spark-1.6.0-ubuntu.qcow2 --disk-format qcow2 --container-format bare --property '_sahara_tag_spark'='True' --property '_sahara_tag_1.6.0'='True'  --property '_sahara_username'='ubuntu'"
sshpass -p $pass ssh $host -l $user ". openrc && openstack image create mapr_5.1.0.mrv2 --file mitaka/sahara-mitaka-mapr-5.1.0-ubuntu.qcow2 --disk-format qcow2 --container-format bare --property '_sahara_tag_mapr'='True' --property '_sahara_tag_5.1.0.mrv2'='True'  --property '_sahara_username'='ubuntu'"
}
