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

echo -n "CredHub Broker name ['$APPPREFIX-fortunes-credhub']> "
read CREDHUB
if [ -z "$CREDHUB" ]; then
    CREDHUB="$APPPREFIX-fortunes-credhub"
else
    CREDHUB="$APPPREFIX-$CREDHUB"
fi

echo -n "External DB URL ['']> "
read DBURL
if [ -z "$DBURL" ]; then
    echo "[ERROR] cannot have an empty url"
    exit 1
fi

echo -n "External DB Name ['']> "
read DBNAME
if [ -z "$DBNAME" ]; then
    echo "[ERROR] cannot have an empty password"
    return 1
fi

echo -n "External DB Username ['root']> "
read DBUSER
if [ -z "$DBUSER" ]; then
    DBUSER="root"
fi

echo -n "External DB Password ['']> "
read DBPASSWORD
if [ -z "$DBPASSWORD" ]; then
    echo "[ERROR] cannot have an empty password"
    return 1
fi

echo -n "Service Registry name ['$APPPREFIX-fortunes-service-registry']> "
read SERVICEREGISTRY
if [ -z "$SERVICEREGISTRY" ]; then
    SERVICEREGISTRY="$APPPREFIX-fortunes-service-registry"
else
    SERVICEREGISTRY="$APPPREFIX-$SERVICEREGISTRY"
fi

CF_API=`cf api | head -1 | cut -c 25-`

# Deploy services
if [[ $CF_API == *"api.run.pivotal.io"* ]]; then
# Uncomment the following section if you'd like to use PCF managed DB.
    cf create-service credhub default $CREDHUB -c "{ \"url\": \"$DBURL\", \"username\": \"$DBUSER\", \"password\": \"$DBPASSWORD\" }"
    cf create-service p-service-registry trial $SERVICEREGISTRY
else
    cf cs credhub default $CREDHUB -c "{ \"url\": \"$DBURL\", \"username\": \"$DBUSER\", \"password\": \"$DBPASSWORD\" }"
    cf cs p-service-registry standard $SERVICEREGISTRY
fi

# Prepare config file to set TRUST_CERTS value
echo "app_prefix: $APPPREFIX" > vars.yml
echo "credhub: $CREDHUB" >> vars.yml
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

sed "s/CHANGEMECREDHUB/$CREDHUB/g" src/main/resources/application.yml.template > src/main/resources/application.yml1
sed "s/CHANGEMEDBNAME/$DBNAME/g" src/main/resources/application.yml1 > src/main/resources/application.yml
rm src/main/resources/application.yml1

./mvnw clean package -DskipTests

yes yes | cf d $APPPREFIX-fortune-service

# Push apps
cf push --vars-file vars.yml

