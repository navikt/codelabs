author: Stefan Andreas Egnelien and Einar Bjerve
id: basic-spring-kurs-for-TA
summary: This tutorial is an introduction to Spring and Spring Boot, primarily aimed at TAs that are starting to work actively with development in Java
status: draft
feedback link:

# Spring and Spring Boot


## About this tutorial
Duration: 1:00
This tutorial is an introduction to Spring and Spring Boot.
By: Stefan Andreas Engelien and Einar Bjerve

### Intended audience
This tutorial is designed for developers that hasn't been developing in the last few year, e.g. TAs

## Prerequisites
Duration: 4:00

You need to know basic Java.

* Internet connectivity
* Java SKD installed - see [https://www.oracle.com/technetwork/java/javase/downloads/index.html](https://www.oracle.com/technetwork/java/javase/downloads/index.html) for instructions. 
* Optional: Maven installed - see [https://maven.apache.org/](https://git-scm.com/) for instructions.
* Docker - see [https://www.docker.com/get-started](https://www.docker.com/get-started) for instructions.
* And IDE installed - recommend [IntelliJ Idea](https://www.jetbrains.com/idea/download) for this codelab
* Git installed - see [https://git-scm.com/](https://git-scm.com/) for instructions.

* Check out code used in the project - [https://github.com/navikt/springkurs](https://github.com/navikt/springkurs) 


## Spring
Duration: 3:00

### Spring framework
Spring framework provides infrastructure, tooling and support for developing application. We'll look
closer into

* Inversion of Control/Dependency Injection
* Beans and their initialisation
* Springs application context

### Spring boot
Spring Boot is an extension to the Spring framework which provides a simple way to configure as run
applications, without to much boilerplate code. We'll guide you through som common scenarios

* Creating a Spring Boot application
* Configuration in application.yaml
* Exposing REST services 
* Using a database
* Applying security
* Log stuff

### Testing with Spring

* Mocking with and without Spring
* Using spring to set up in memory database
* Component testing with Spring Boot

## Inversion of Control (IoC)/Dependency Injection (DI)

### Introduction
Normal flow when creating objects is to instantiate with the `new` operator, e.g. 

```$java
class MyClass() {
  
    private final Dependency dependency;
  
    MyClass() {
        dependency = new Dependency();
    }
}
``` 

With Dependency Injection the dependency is provided by something else
```$java
class MyClass() {

    private final Dependency dependency;
    
    MyClass(Dependency dependency) {
        this.dependency = dependency;
    }
}
```

This has an implication, you need something else need to instantiate the the dependency each 
time you use the class, and manage how it is injected. This makes it much easier to replace
the dependency.

This "something else" could be Spring when you initialize your application, or your unit test when
you write tests

### Code assignment

<!-- TODO STEFAN -->

### Flavours of dependency injection

Constructor injection 

```$java
class MyClass() {

    private final Dependency dependency;
    
    MyClass(Dependency dependency) {
        this.dependency = dependency;
    }
}
```

Field injection fields annotated with [@Inject](https://javaee.github.io/javaee-spec/javadocs/javax/inject/Inject.html),
[@Autowired](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/beans/factory/annotation/Autowired.html)
(or working on old code you might run into [@Resource](https://docs.oracle.com/javase/8/docs/api/javax/annotation/Resource.html))
```$java
class MyClass() {

    @Inject
    private final Dependency dependency;
    
    MyClass(Dependency dependency) {
        this.dependency = dependency;
    }
}
```


## Beans
Objects managed by Spring is called beans

You need some way to tell spring that there are beans present, and which objecs that should be 
managed by spring. As with injection of beans, spring allows for multiple flavors of instantiation
of beans, and you might run into any of them or any combination of them. We'll handle them 
separatly here


### Xml configuration of beans
This is something you will run into in the wild. Especially if you're working on older code bases

There are very few (if any) developers that prefer this
```$xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE beans PUBLIC "-//SPRING//DTD BEAN 2.0//EN"
    "http://www.springframework.org/dtd/spring-beans-2.0.dtd">

<beans>

    <bean id="myDependency" class="no.nav.MyDependency"></bean>
    
    <bean id="myClass" class="no.nav.MyClass">
        <property name="dependency" value="myDependency">
    </bean>

</beans>
``` 


### Annotation Configuration

Annotation moves your spring configuration from xml to code. Annotation configration is usually 
the least verbose, but will leak spring dependencies into your domain classes

Annotate classes that spring should manage with @Component, @Service, @Repository or @Controller,
and when you initialize your application context (next chapter), you tell it where to look for 
classes annotated with this annotations.

You also annotate the fields or constructors you want dependencies injected into with @Inject or 
@Autowired as mentioned earlier 

```$java
@Component
class Dependency {
}

@Service
class MyClass {

    private final Dependency dependency;
    
    @Inject
    MyClass(Dependency dependency) {
        this.dependency = dependency;
    }
}


@Configuration
@ComponentScan("no.nav")
public class MyConfiguration {
}
```

### Java based configuration

Java based configuration of beans also moves configuration from xml to code. It is usually slightly
more verbose than annotation configuration, but keeps your domain classes pure and free of spring 

In your configuration classes (annotated with @Configuration) you define the beans you want spring 
to manage in methods annotated with @Bean.

```$java
class Dependency {
}

class MyClass {

    private final Dependency dependency;
    
    MyClass(Dependency dependency) {
        this.dependency = dependency;
    }
}


@Configuration
public class MyConfiguration {
    
    @Bean
    public Dependency dependency() {
        return new Dependency();
    }
    
    @Bean 
    public MyClass myClass(Dependency dependency) {
        return new MyClass(dependency);
    }
}
    // ...
```

## The application context