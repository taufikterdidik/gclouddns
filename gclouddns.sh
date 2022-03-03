#!/bin/bash

### VERSION 1.0
### Author : <Taufik Fahrudin> taufik@terdidik.com

ACCOUNT=example@terdidik.com
PROJECT=example
DNS_ZONE=terdidik-com
DNS_RECORD=terdidik.com

DIR=$(dirname "$0")
if [ -f "$DIR/.env" ]
then
  export $(cat "$DIR/.env" | xargs)
fi

if [ -f "/etc/gclouddns.conf" ]; then
  export $(cat "/etc/gclouddns.conf" | xargs)
fi

while getopts c: flag
do
  case "${flag}" in
    c) CONFIG=${OPTARG};;
  esac
done

if [ "$CONFIG" != "" ]; then
  export $(cat "/etc/gclouddns/${CONFIG}.conf" | xargs)
fi

RECORDS=$(gcloud dns record-sets list --account=$ACCOUNT --project=$PROJECT --zone=$DNS_ZONE --name=$DNS_RECORD. --type=A)

NEW_IP=$(curl -s http://ifconfig.me | sed 's/ *$//g')
if [[ ! "$NEW_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]];then
  NEW_IP=$(curl -s http://ifconfig.co | sed 's/ *$//g')
fi

if [[ "$RECORDS" != *"$NEW_IP"* && "$NEW_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]];then
  logger "Changing type A $DNS_RECORD to $NEW_IP"
  ATTL="${TTL:=300}"
  gcloud dns record-sets update $DNS_RECORD --rrdatas=$NEW_IP --type=A --ttl=$ATTL --account=$ACCOUNT --project=$PROJECT --zone=$DNS_ZONE
fi