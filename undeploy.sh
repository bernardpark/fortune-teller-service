#!/bin/bash

# Set variables
echo -n "App prefix ['random']> "
read APPPREFIX
if [ -z "$APPPREFIX" ]; then
    APPPREFIX="random"
fi

echo -n "CredHub Broker name ['$APPPREFIX-fortunes-credhub']> "
read CREDHUB
if [ -z "$CREDHUB" ]; then
    CREDHUB="$APPPREFIX-fortunes-credhub"
else
    CREDHUB="$APPPREFIX-$CREDHUB"
fi

echo -n "Service Registry name ['$APPPREFIX-fortunes-service-registry']> "
read SERVICEREGISTRY
if [ -z "$SERVICEREGISTRY" ]; then
    SERVICEREGISTRY="$APPPREFIX-fortunes-service-registry"
else
    SERVICEREGISTRY="$APPPREFIX-$SERVICEREGISTRY"
fi

# delete apps
cf delete $APPPREFIX-fortune-service -f

# delete services
cf delete-service $CREDHUB -f
cf delete-service $SERVICEREGISTRY -f

# delete orgphaned routes
cf delete-orphaned-routes -f
