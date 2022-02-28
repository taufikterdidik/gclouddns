#!/bin/bash

ACCOUNT=example@terdidik.com
PROJECT=example
DNS_ZONE=terdidik-com
DNS_RECORD=terdidik.com

DIR=$(dirname "$0")
if [ -f "$DIR/.env" ]
then
  export $(cat "$DIR/.env" | xargs)
fi

RECORDS=$(gcloud dns record-sets list --account=$ACCOUNT --project=$PROJECT --zone=$DNS_ZONE --name=$DNS_RECORD. --type=A)
NEW_IP=$(curl -s https://ifconfig.me)


if [[ "$RECORDS" != *"$NEW_IP"* && "$NEW_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]];then
  echo "Changing A to $NEW_IP"
  gcloud dns record-sets update $DNS_RECORD --rrdatas=$NEW_IP --type=A --ttl=300 --account=$ACCOUNT --project=$PROJECT --zone=$DNS_ZONE
fi