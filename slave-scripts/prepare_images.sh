#!/bin/bash

. $FUNCTION_PATH/functions.sh

ssh 172.18.79.150 -l qa 'scp -r mitaka root@172.18.79.154:'
upload_images 172.18.79.154 root r00tme
