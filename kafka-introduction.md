author: Geir André Lund
summary: Kafka-clients introduction codelab. 
id: kafka-clients-intro-v1
categories: kafka,java,event-driven
environments: Java
status: draft
feedback link: 
analytics account: 0

# Kafka-clients introduction 

## Overview of the tutorial
Duration: 5:00~10:00

This tutorial shows you how to create a Kafka consumer and -producer using kafka-clients java library

Prerequisites: 

* Java SKD installed - see [https://www.oracle.com/technetwork/java/javase/downloads/index.html](https://www.oracle.com/technetwork/java/javase/downloads/index.html) for instructions. 
* Docker - see [https://www.docker.com/get-started](https://www.docker.com/get-started) for instructions.
* And IDE installed - recommend [IntelliJ Idea](https://www.jetbrains.com/idea/download) for this codelab
* Optional: Git installed - see [https://git-scm.com/](https://git-scm.com/) for instructions.

Positive
: We recommend you to have Git, Java SE SDK, IDE and Docker already installed on your machine.

## Set up
Duration: 2:00

### Java and project setup

[Download project](https://github.com/navikt/codelab-kafka-clients/archive/master.zip)

Extract the project to an directory. Alternative, use git to clone the project. 
``` bash
git clone https://github.com/navikt/codelab-kafka-clients.git
```

Navigate to the kafka-clients directory underneath project root, run gradle: 

``` bash
$ cd cd <project_root>/kafka-clients
$ ./gradlew build
``` 

If everything is set up you should see 

``` bash
BUILD SUCCESSFUL in Xs
```

### Docker

In the kafka-clients directory, there is a `docker-compose.yml` file navigate to the file and run docker-compose:

``` bash
$  cd <project_root>/kafka-clients
$ docker-compose up
```

This should start a kafka and zookeeper instance locally. 


## consumer 



## Producer



