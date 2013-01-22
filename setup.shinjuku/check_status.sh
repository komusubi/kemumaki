#!/bin/bash

dcmgr_services="
admin
auth
proxy
collector
webui
dcmgr
metadata
"
#nwmongw
#nsa
#sta

hva_services=(hva hva-worker)

error=

function check(){
  local name=$1
  local ip=$2

  echo --------------------
  echo ${name} services
  echo --------------------

  echo -n connect to ${ip}...
  ssh -q root@${ip} -C ":"
  if [ $? -ne 0 ]; then
    echo failure
    return 1
  fi
  echo success

  for service in `eval echo \$\{${name}_services[@]\}`
  do
    echo -ne "vdc-${service}\t"
    status=`ssh root@${ip} -C "initctl status vdc-${service}" 2>/dev/null`
    status=`echo ${status} | awk '{print $2}' | sed -e 's/,//'`
    echo ${status}
    if [[ -z `echo $status | grep -o 'start/running'` ]]; then
      error=y
    fi
  done
  echo 
}


check dcmgr 10.0.2.15
check hva 10.0.2.16

if [[ "${error}" = "y" ]]; then
  exit 1
fi

