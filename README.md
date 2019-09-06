# Fortune Teller MicroServices - Fortune Service

## Overview
This repository is a microservice of the larger [Fortune Teller Application](https://github.com/msathe-tech/fortune-teller) guided as a workshop. This is a single Java/Spring application, with a REST API layer and consuming MySQL backend.

## Spring Data JPA
Notice the differences in the `application.yml` compared to the master branch. You should notice a new `cloud` profile defined at the end of the file. This application assumes that it will be pushed to Cloud Foundry, which recognizes and activates the `cloud` profile when deployed. The variables follow the `${vcap.services.SERVICE_NAME.credentials.VARIABLE_NAME}` naming convention to call the environment variables that are injected with a service broker. In this repository, the `deploy.sh` script will populate custom variable names according to your deployment use case.

## Service Registry
There are no changes to the service registry part of this branch.

## Deploying the Application
<a href="https://push-to.cfapps.io?repo=https%3A%2F%2Fgithub.com%2Fmsathe-tech%2Ffortune-teller.git">
        <img src="https://push-to.cfapps.io/ui/assets/images/Push-to-Pivotal-Light.svg" width="200" alt="Push">
</a>

### Or

Build and deploy application on current 'cf target'

```
./deploy.sh
```

When prompted for the App Suffix, give a unique identifier. This is to ensure that there is no overlap in cf application names whe
n pushing.

This deploy script does the following.
1. Build your applications with Maven
1. Create the necessary services on Pivotal Cloud Foundry
1. Push your applications

Examine the manifest.yml file to review the application deployment configurations and service bindings.

## Test the application

### Test the service
1. Visit `https://$YOUR_SERVICE_ENDPOINT/random`.
1. Notice a random fortune returned.

## Clean up

You can choose to clean up your environment, or keep it for the next lab.

```
./scripts/undeploy.sh
```

## Return to Workshop Respository
[Fortune Teller Workshop](https://github.com/msathe-tech/fortune-teller)

## Authors
* **Bernard Park** - [Github](https://github.com/bernardpark)
* **Madhav Sathe** - [Github](https://github.com/msathe-tech)
