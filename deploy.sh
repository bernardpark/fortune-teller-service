#!/usr/bin/env bash
#******************************************************************************
#    Deploy Fortune-Service
#******************************************************************************
#
# DESCRIPTION
#    Deploys the fortune-service app and necessary services
#
#
#==============================================================================
#
#==============================================================================

echo "*********************************************************************************************************"
echo "**************************************** Deploy fortune-service *****************************************"
echo "**************************************** REQUIRES cf cli AND jq *****************************************"
echo ""

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

./mvnw clean package -DskipTests

CF_API=`cf api | head -1 | cut -c 25-`

# Deploy services
if [[ $CF_API == *"api.run.pivotal.io"* ]]; then
# Uncomment the following section if you'd like to use PCF managed DB.
    cf create-service cleardb spark $DATABASE
    cf create-service p-service-registry trial $SERVICEREGISTRY
else
    cf cs p.mysql db-small $DATABASE
    cf cs p-service-registry standard $SERVICEREGISTRY
fi

# Prepare config file to set TRUST_CERTS value
echo "app_prefix: $APPPREFIX" > vars.yml
echo "database: $DATABASE" >> vars.yml
echo "service_registry: $SERVICEREGISTRY" >> vars.yml
echo "cf_trust_certs: $CF_API" >> vars.yml

# Wait until services are ready
while cf services | grep 'create in progress'
do
  sleep 20
  echo "Waiting for services to initialize..."
done

# Check to see if any services failed to create
if cf services | grep 'create failed'; then
  echo "Service initialization - failed. Exiting."
  return 1
fi
echo "Service initialization - successful"

# Push apps
cf push --vars-file vars.yml
