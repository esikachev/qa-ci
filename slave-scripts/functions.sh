#!/bin/bash -xe

write_tests_conf() {
  local cluster_name=$1
  local image_prefix=$2
  local image_name=$3
  OS_USERNAME="admin"
  OS_PASSWORD="admin"
  OS_TENANT_NAME="admin"
  OS_AUTH_URL="http://172.18.79.153:5000/v2.0"
  NETWORK="neutron"
echo "[DEFAULT]
OS_USERNAME: $OS_USERNAME
OS_PASSWORD: $OS_PASSWORD
OS_TENANT_NAME: $OS_TENANT_NAME
OS_AUTH_URL: $OS_AUTH_URL
network_type: $NETWORK
network_public_name: admin_internal_net
network_private_name: admin_floating_net
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
