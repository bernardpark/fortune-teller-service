# Fortune Teller MicroServices - Fortune Service

## Overview
This repository is a microservice of the larger [Fortune Teller Application](https://github.com/msathe-tech/fortune-teller) guided as a workshop. This is a single Java/Spring application, with a REST API layer and consuming MySQL backend through the CredHub Service Broker.

## Spring Data JPA
This application is almost the same compared to the master branch. The only difference is that this application will consume an external backend database as opposed to binding to a Pivotal Cloud Foundry service. This means that Spring datasource properties that would have been otherwise injected by the platform will now need to be specified.

## Spring Profiles
We will add a new Spring profile to differentiate deployments to different environments. We will add a `cloud` profile to specify external database credentials, secured and injected by Credhub. Any other deployments will default to the existing default profile.

### Exercise 1 - Acquire an External Database
Provision an external MySQL database that is accessible by your Pivotal Cloud Foundry platform. Make sure you have a database URL, a user with read/write privileges, its password, and a database to use.

### Coding Exercise 2 - Add a Spring Profile
Let's take a look at `/src/main/resources/application.yml`. We will add a new profile with the name `cloud`, which Pivotal Cloud Foundry will activate when it is deteced. Start by appending a new yml file syntax at the end of the file with three dash lines `---`. Underneath, add the properties **IN YML FORMAT** `spring.profiles=cloud`, `spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL57Dialect`, `spring.datasource.url=jdbc:mysql://${vcap.services.$CREDHUB_BROKER_NAME.credentials.url}:3306/$DB_NAME`, `spring.datasource.username=${vcap.services.$CREDHUB_BROKER_NAME.credentials.username}`, `spring.datasource.password=${vcap.services.$CREDHUB_BROKER_NAME.credentials.password}`.

The `vcap.services` properties are environment variable naming standards on a Cloud Foundry platform. Replace the `$DB_NAME` variable above with the property you prepared in Exercise 1, and come up with a unique name for your Credhub Broker. **Take note of this broker name, as we will create a Credhub Broker Service Instance with the same name when we deploy this application.**

**application.yml**

```
...
---
spring:
  profiles: cloud
  jpa:
    properties:
     hibernate:
        dialect: org.hibernate.dialect.MySQL57Dialect
  datasource:
    url: jdbc:mysql://${vcap.services.$YOUR_CREDHUB_BROKER_NAME.credentials.url}:3306/$DB_NAME
    username: ${vcap.services.$YOUR_CREDHUB_BROKER_NAME.credentials.username}
    password: ${vcap.services.$YOUR_CREDHUB_BROKER_NAME.credentials.password}
```

Save your file.


## Deploying the Application
1. Build your applications with Maven

```
mvn clean package
```

1. Create the necessary services on Pivotal Cloud Foundry. For this application, we will need a Credhub Service Broker. If you don't already have a Service Registry, create that too.

One thing to note is that the Credhub Broker needs to be created with parameters to store and secure credentials. You can do so by adding a JSON text with the `-c` flag. Make sure you replace the example command below with properties you prepared in Exercise 1.

```
# Repeat for all required services

# View available services
cf marketplace
# View service details
cf marketplace -s $SERVICE_NAME
# Create the service (config server)
cf create-service $SERVICE_NAME $SERVICE_PLAN $YOUR_SERVICE_NAME -c '{ "url": "$DB_URL", "username": "$DB_USERNAME", "password": "$DB_PASSWORD" }'
# Create the service (all others)
cf create-service $SERVICE_NAME $SERVICE_PLAN $YOUR_SERVICE_NAME
```
1. Draft your `manifest.yml` in the root directory. Note that the variables, enclosed in double parentheses (()), will contain the key of each variable. We will create the variable file shortly.

```
---
applications:
- name: ((app_name))
  memory: 1024M
  path: ./target/fortune-teller-service-0.0.2-SNAPSHOT.jar
  instances: 1
  services:
  - ((credhub))
  - ((service_registry))
  env:
    TRUST_CERTS: ((cf_trust_certs))
```

1. Draft your `vars.yml` file in the root directory. Notice that the keys to all variables are referenced in the `manifest.yml` file we just created. You will also need to know your PCF API endpoint. You can find this by visiting Apps Manager -> Tools -> `Login to the CLI` box, or by running the command `cf api | head -1 | cut -c 25-`.

```
app_name: $YOUR_APP_NAME
credhub: $YOUR_CREDHUB_BROKER_NAME
service_registry: $YOUR_SERVICE_REGISTRY_NAME
cf_trust_certs: $YOUR_PCF_API_ENDPOINT
```

1. Push your application.

```
cf push
```

Examine the manifest.yml file to review the application deployment configurations and service bindings.

## Test the application

### Test the service
1. Visit `https://$YOUR_SERVICE_ENDPOINT/random`.
1. Notice a random fortune returned.

## Return to Workshop Respository
[Fortune Teller Workshop](https://github.com/msathe-tech/fortune-teller)

## Authors
* **Bernard Park** - [Github](https://github.com/bernardpark)
* **Madhav Sathe** - [Github](https://github.com/msathe-tech)
