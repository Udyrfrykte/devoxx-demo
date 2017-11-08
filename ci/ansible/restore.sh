#! /bin/bash

if ssh $1 true; then
  (ssh -tt $1 sudo bash -c '"gsutil cp gs://devoxx-udd/devoxx-udd.tgz /tmp && tar -C / -xf /tmp/devoxx-udd.tgz"')
fi

# ring a bell
echo -e "\a"
