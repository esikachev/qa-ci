#!/bin/bash

. $FUNCTION_PATH/functions.sh

ssh 172.18.79.150 -l qa 'sshpass -p r00tme scp -o StrictHostKeyChecking=no -r mitaka root@172.18.79.154:'
upload_images 172.18.79.154 root r00tme
