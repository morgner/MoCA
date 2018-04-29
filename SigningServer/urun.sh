#! /usr/bin/env bash

if [ ! -d /run/moca ]
  then
  echo " >> have to enable nginx to use the socket:"
  set -x
  sudo mkdir /run/moca
  sudo chmod 0777 /run/moca
  set +x
  fi

uwsgi moca/moca.ini 
