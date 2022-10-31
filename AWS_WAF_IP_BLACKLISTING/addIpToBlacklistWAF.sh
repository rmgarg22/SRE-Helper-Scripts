#!/bin/bash
set +ex;

ipSetName="<<IPSETNAME>>"
ipSetId="IPSETID"
awsRegion="<<AWSREGION>>"
IP=$1

# Get IP set
aws wafv2 get-ip-set --name=$ipSetName --scope REGIONAL --id=$ipSetId --region $awsRegion > IP_SET_OUTPUT.txt

# Get token from the JSON
LOCK_TOKEN=$(jq -r '.LockToken' IP_SET_OUTPUT.txt)

# Get IP list from the JSON
arr=( $(jq -r '.IPSet.Addresses[]' IP_SET_OUTPUT.txt) )

# Add our ip to the list
arr+=( "${IP}" )

# Update IP set
aws wafv2 update-ip-set --name=$ipSetName --scope=REGIONAL --id=$ipSetId --addresses "${arr[@]}" --lock-token=$LOCK_TOKEN --region=$awsRegion

# Get latest IP set
aws wafv2 get-ip-set --name=$ipSetName --scope REGIONAL --id=$ipSetId --region $awsRegion > IP_SET_UPDATED_OUTPUT.txt

set -ex;