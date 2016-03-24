#!/bin/bash

BACKUPGITLOG=/usr/local/nginx/logs/nstat.log

date >> ${BACKUPGITLOG}
echo "stop: ${1}">> ${BACKUPGITLOG}

curl "http://127.0.0.1/control/redirect/subscriber?app=in&addr=127.0.0.1&newname=live"

