#! /bin/bash

if ssh $1 true; then
  (ssh -tt $1 sudo bash -c '"systemctl stop docker >> /dev/null && sleep 5 && rm -f /tmp/devoxx-udd.tgz && tar -C / -czf /tmp/devoxx-udd.tgz opt/docker-data && gsutil cp /tmp/devoxx-udd.tgz gs://devoxx-udd/"')
fi

# ring a bell
echo -e "\a"
