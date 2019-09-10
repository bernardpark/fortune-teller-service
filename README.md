# Fortune Teller MicroServices - Fortune Service

## Overview
This repository is a microservice of the larger [Fortune Teller Application](https://github.com/msathe-tech/fortune-teller) guided as a workshop. This is a single Java/Spring application, with a REST API layer and consuming MySQL backend.

## Spring MVC / Spring Data JPA
Take a look at the project structure. The spring-boot-starter-web dependency will provide Spring MVC to build out your API layer, and the spring-boot-starter-data-jpa will provide the boilerplate configuration for JPA/Hibernate.

### Coding Exercise 0 - Basic Structure 
In addition to providing a full `pom.xml`, this application has some basic constructs already in place. The `Fortune.java` class, acting as an Entity mapping to a RDBMS table, allows Java to map class variables to Table entries. The `FortuneRepository.java` extends the Spring `CrudRepository.java` class, which is automatically configured to consume the defined datasource. In the next coding exercise, we will begin by defining some datasource properties.

### Coding Exercise 1 - Add your JPA and Hibernate Properties
In src/main/resources/application.yml, you can notice jpa specific properties that have been commented out. Rewrite the variables, while understanding that we are specifying the SQL dialect we want Hibernate to use. Also notice the `spring.jpa.hibernate.ddl-auto` property. By setting this value to `create-drop`, Hibernate will automatically create and drop tables upon start and stop of the application. In our application, we will only have one table to be created, `Fortune`. Hibernate knows that the `Fortune.java` class maps to a table through the `@Entity` annotation. In addition, the `data.sql` file found under `src/main/resources` will execute during application start.

**application.yml**

```
spring:
...
  jpa:
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL57Dialect
    hibernate:
      ddl-auto: create-drop
...
```

Save your file.

### Coding Exercise 2 - Add a Repository Method
The `FortuneRepository.java` class already extends a few basic CRUD operations such as add() or findAll(). Now we need to create a custom method that executes a specific query. In our application, we want to add a new method and apply a query for Hibernate to execute by using the `@Query` annotation. Comment out the code found in `FortuneRepository.java`.

**FortuneRepository.java**

```
    @Query("select fortune from Fortune fortune order by RAND()")
    public List<Fortune> randomFortunes(Pageable pageable);
```

Save your file.

### Coding Exercise 3 - Enable JPA Repositories
Your application now needs to understand that it should configure and instantiate the proper JPA Repository beans. We can do so by adding the `@EnableJpaRepositories` annotation to your `Application.java` class.

**Application.java**

```
@SpringBootApplication
@EnableJpaRepositories
public class Application {
...
```

Save your file.

### Coding Exercise 4 - Add a REST Endpoint
Now that we have a repository method, we need a way for an application user to execute the method. Open your `FortuneController.java` class and view its annotations. The `@RestController` annotation tells Spring that this class will define our REST endpoints. We also `@Autowired` the FortuneRepository bean so that it can be referenced in this class.

The first method, `fortunes()`, is a method that uses the CrudRepository's basic operation method to find all entries in the Fortune table. We now need to create another Rest endpoint that will fetch a random fortune. Do so by creating another method with the same `@RequestMapping` annotation as above, specifying the endpoint to map to `/random`.

**FortuneController.java**

```
    @RequestMapping("/random")
    public Fortune randomFortune() {
        List<Fortune> randomFortunes = repository.randomFortunes(new PageRequest(0, 1));
        return randomFortunes.get(0);
    }
```

Save your file.

### Coding Exercise 5 - Register your Application
We are now done with our Spring MVC and JPA exercies. For future labs, we now need to register our application to a Service Registry.

By including spring-cloud-services-starter-service-registry in the `pom.xml`, your application will now be registered in your Service Registry service instance in Pivotal Cloud Foundry.

Take a look at `src/main/resources/bootstrap.yml`. This properties file, to be read before your `application.yml` file, defines the name of this application when it is registered in your Service Registry. In the future, you may build out your microservices to reference each service by its registered name. For this exercise, add the `spring.application.name` property in yml fashion and give it the name `fortune-service`.

**bootstrap.yml**

```
spring:
  application:
    name: fortune-service
```

Save your file.

## Deploying the Application
Build and deploy application on current 'cf target'

1. Build your applications with Maven

```
mvn clean package
```

1. Create the necessary services on Pivotal Cloud Foundry. For this application, we will need a MySQL instance and a Service Registry.

```
# Repeat for MySQL and Service Registry

# View available services
cf marketplace
# View service details
cf marketplace -s $SERVICE_NAME
# Create the service
cf create-service $SERVICE_NAME $SERVICE_PLAN $YOUR_SERVICE_NAME
```
1. Draft your `manifest.yml` in the root directory. Note that the variables, enclosed in double parentheses (()), will contain the key of each variable. We will create the variable file shortly.

```
---
applications:
- name: ((app_name))
  memory: 1024M
  path: ./target/fortune-teller-service-0.0.1-SNAPSHOT.jar
  instances: 1
  services:
  - ((database))
  - ((service_registry))
  env:
    TRUST_CERTS: ((cf_trust_certs))
```

1. Draft your `vars.yml` file in the root directory. Notice that the keys to all variables are referenced in the `manifest.yml` file we just created. You will also need to know your PCF API endpoint. You can find this by visiting Apps Manager -> Tools -> `Login to the CLI` box, or by running the command `cf api | head -1 | cut -c 25-`.

```
app_name: $YOUR_APP_NAME
database: $YOUR_SERVICE_NAME
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
1. Visit `https://$YOUR_SERVICE_ENDPOINT/fortunes`.
1. Notice all fortunes returned.

1. Visit `https://$YOUR_SERVICE_ENDPOINT/random`.
1. Notice a random fortune returned.

## Return to Workshop Respository
[Fortune Teller Workshop](https://github.com/msathe-tech/fortune-teller#lab1-create-a-service)

## Authors
* **Bernard Park** - [Github](https://github.com/bernardpark)
* **Madhav Sathe** - [Github](https://github.com/msathe-tech)
