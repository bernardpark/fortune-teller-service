#!/bin/bash

# Set variables
echo -n "App prefix ['random']> "
read APPPREFIX
if [ -z "$APPPREFIX" ]; then
    APPPREFIX="random"
fi

echo -n "Database name ['$APPPREFIX-fortunes-db']> "
read DATABASE
if [ -z "$DATABASE" ]; then
    DATABASE="$APPPREFIX-fortunes-db"
else
    DATABASE="$APPPREFIX-$DATABASE"
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
cf delete-service $DATABASE -f
cf delete-service $SERVICEREGISTRY -f

# delete orgphaned routes
cf delete-orphaned-routes -f
