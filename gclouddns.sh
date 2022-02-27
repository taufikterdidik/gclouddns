#!/bin/bash

ACCOUNT=example@terdidik.com
PROJECT=example
DNS_ZONE=terdidik-com
DNS_RECORD=terdidik.com

if [ -f .env ]
then
  export $(cat .env | xargs)
fi

RECORDS=$(gcloud dns record-sets list --account=$ACCOUNT --project=$PROJECT --zone=$DNS_ZONE --name=$DNS_RECORD. --type=A)

NEW_IP=$(curl -s https://ifconfig.me)

echo $RECORDS
echo $NEW_IP

if [[ "$RECORDS" != *"$NEW_IP"* ]];then
  echo "Changing A to $NEW_IP"
  #gcloud dns record-sets transaction start --account=$ACCOUNT --project=$PROJECT --zone=$DNS_ZONE
  gcloud dns record-sets update $DNS_RECORD --rrdatas=$NEW_IP --type=A --ttl=300 --account=$ACCOUNT --project=$PROJECT --zone=$DNS_ZONE
  #gcloud dns record-sets transaction execute --account=$ACCOUNT --project=$PROJECT --zone=$DNS_ZONE
fi

#NEW_IP=$(curl -s https://ifconfig.me)
