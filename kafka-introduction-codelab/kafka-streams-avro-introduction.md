author: Geir André Lund
summary: Kafka-clients introduction codelab.
id: kafka-streams-avro-intro
categories: kafka,java,event-driven
environments: Java
status: draft
feedback link:
analytics account: 0

# Kafka streams introduction

## Overview of the tutorial

This tutorial shows you how to create a Kafka-consumer and -producer using [kafka-streams](http://kafka.apache.org/documentation/#streamsapi) java library.

What you'll learn
* How to use Schema registry and Avro to define a strictly format for Kafka messages
* How to create a Kafka-Streams that reads- , transform and produce data to/from a Kafka-broker

Positive
: This tutorial requires that you are familiar with Java programming language.

### Prerequisites
Duration: 10:00

* Internet connectivity
* Java SKD installed (version > 1.8.x) - see [https://www.oracle.com/technetwork/java/javase/downloads/index.html](https://www.oracle.com/technetwork/java/javase/downloads/index.html) for instructions.
* Docker - see [https://www.docker.com/get-started](https://www.docker.com/get-started) for instructions. NB! Docker on Windows VDI requires virtualization, see [Docker on Windows VDI requires virtualization](#Docker-on-Windows-VDI-requires-virtualization)
* IntelliJ IDEA installed. Choose the Community version from the download link [IntelliJ Idea](https://www.jetbrains.com/idea/download)
* Optional: Git installed - see [https://git-scm.com/](https://git-scm.com/) for instructions.


#### Docker on Windows VDI requires virtualization 
* To be able to run the Docker daemon that comes with Docker Desktop (formerly known as Docker For Windows) in Nav's Windows virtual machine images we need to enable virtualization (Hyper-V) in the image.
* You can ask to have virtualization enabled in the Slack channel #tech_virtualisering. You need to provide the name of the virtual machine, which you will find from within the image > Windows > Kontrollpanel > System og sikkerhet > System. Enabling virtualization requires reboot of the image.
* Verify by opening Windows > Aktiver eller deaktiver Windows-funksjoner, find "Hyper-V" and see that all it's checkboxes are enabled.
 
## Set up
Duration: 10:00

### Java and project setup

* [Download project](https://github.com/navikt/kafka-streams-avro-codelab/archive/master.zip)
* Extract the project to a directory. 

### Gradle


In project root, run gradle:

```@bash
$ cd kafka-streams-avro-codelab
$ ./gradlew --offline build
```

or in Windows:

``` bash
$ cd kafka-streams-avro-codelab    
$ gradlew.bat --offline build
```

If everything is set up you should see

``` bash
BUILD SUCCESSFUL in Xs
```

#### Gradle "connection refused" 

On NAV developer image: If you get an `Connection refused` error when executing gradle, add a file named `gradle.properties` in an folder named `.gradle` in your home directory with the following content:

```@bash
systemProp.proxySet=true
systemProp.http.proxyHost=webproxy-utvikler.nav.no
systemProp.http.proxyPort=8088
systemProp.https.proxyHost=webproxy-utvikler.nav.no
systemProp.https.proxyPort=8088
```

Windows: `C:\Users\<username>\.gradle\gradle.properties`
Linux and Mac: `~/.gradle/gradle.properties`


### Docker

In the project directory, there is a `docker-compose.yml` file, navigate to the file and run docker-compose from the command line:

```@bash
$ docker-compose up
```

This should start Zookeeper and a Kafka instances locally.

### IntelliJ 

* Open the project in IntelliJ by choosing: `File -> New -> Project from Existing sources...` navigate to project folder and press OK
* Choose `Gradle` in next window - Next
* Underneath `Global Gradle settings` - choose `Offline work` and hit `Finish`


##  NAV Visitor Analysis
Duration: 3:00

NavVisitorLocation is a topic produced to Kafka each time a visitor visits the nav.no front page. Each message is structured in an AVRO object with postal- and  municipality information, example:

```@json
{"postnummer":"2005","stedsnavn":"RÆLINGEN","kommune":"0228"}
```


1. Create a Kafka stream consumes `NavVisitorLocation` topic (See NavVisitorProducer.java in the project).
2. And count visits per area (stedsnavn) 
3. Produce the result to an topic named `NavVisitorAreaCounter`

## The NavVisitorLocation topic producer
Duration: 7:00

* Provided in the project there is a Java class named `NavVisitorProducer.java`. This class should produce random postal location on a topic named `NavVisitorLocation`.  To get started we need to create Topics. 

### Create topics 

1. Create NavVisitorLocation topic: `docker run --net host confluentinc/cp-kafka kafka-topics --create  --zookeeper localhost:2181 -topic NavVisitorLocation --replication-factor 1 --partitions 1` will create the topic
2. To verify that the topic as been created, we can run: `docker run --net host confluentinc/cp-kafka kafka-topics --describe  --zookeeper localhost:2181 -topic NavVisitorLocation`
3. Create NavVisitorAreaCounter topic: `docker run --net host confluentinc/cp-kafka kafka-topics --create  --zookeeper localhost:2181 -topic NavVisitorAreaCounter --replication-factor 1 --partitions 1` will create the topic
4. To verify that the topic as been created, we can run: `docker run --net host confluentinc/cp-kafka kafka-topics --describe  --zookeeper localhost:2181 -topic NavVisitorAreaCounter`


## Create an kafka-stream app 
Duration: 10:00

1. In IntelliJ - Create a new Java file, give it a name (e.g. `NavVisitorAreaCounterStream.java`)
2. Next we need to create kafka stream configuration by copy & paste the code underneath 

```@java


public class NavVisitorAreaCounterStream {

    private static final String SCHEMA_REGISTER_URL = "http://localhost:8081/";
    private static final String BOOTSTRAP_SERVERS = "localhost:29092";

    public static void main(String[] args) {
        final Properties streamsConfiguration = new Properties();
        // Give the Streams application a unique name.  The name must be unique in the Kafka cluster
        // against which the application is run (consumer group id).
        streamsConfiguration.put(StreamsConfig.APPLICATION_ID_CONFIG, "nav-visitor-area-consumer");
 
       // Where to find kafka brokers
        streamsConfiguration.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, BOOTSTRAP_SERVERS);
        // Where to find schema-registry 
        streamsConfiguration.put(AbstractKafkaAvroSerDeConfig.SCHEMA_REGISTRY_URL_CONFIG, SCHEMA_REGISTER_URL);
       
        // Default (de)serializers for record keys and for record values.
        streamsConfiguration.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
        streamsConfiguration.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, SpecificAvroSerde.class);
         
    }
}    
```

* Next step is to create the kafka-stream that consumes `NavVisitorAreaCounter` topic. 

1. Define a StreamsBuilder `final StreamsBuilder builder = new StreamsBuilder();`
2. Next, create a KStream instance that consumes `NavVisitorAreaCounter`. 

```@java
final StreamsBuilder builder = new StreamsBuilder();
final KStream<String, Poststed> poststedKStream = builder.stream("NavVisitorLocation");
```
We should now be able to consume records from Kafka. 

Try it out by first start the consumer we just created (Run the main method in IntelliJ) and then start the producer, `NavVisitorProducer` (Run the main method in IntelliJ). 
If all looks good, go ahead to the next section.


## Track visits per area (stedsnavn) 
Duration: 20:00

Back to the task, for each record, we like to increase a counter for that area. 

Kafka Streams DSL provides a high-level API for common data transformation operations such as map, filter, join, and aggregations out of the box.  
For this tutorial we are going to use an KTable. A [KTable](https://docs.confluent.io/current/streams/concepts.html#ktable) is an abstraction of a changelog stream< from a primary-keyed table.


* Define the KTable by grouping by area name (stedsnavn) and count the occurrences of areas

```@java
   final KTable<String, Long> areaCounts = poststedKStream
            .groupBy(new KeyValueMapper<String, Poststed, String>() {
                @Override
                public String apply(String key, Poststed poststed) {
                    return poststed.getStedsnavn(); // Group by stedsnavn
                }
            })
            .count(); // Update the table with a count (stedsnavn is primary keyed)
```

In order to have a peek inside the ktable result we cant add a `peek` method to `areaCounts`

```@java

 areaCounts.toStream().peek(
            (navn, teller) -> System.out.println("stedsnavn = [" + navn + "], teller = [" + teller + "]")
        );
```

Try it out by starting the consumer (Run the main method in IntelliJ) and then start the producer.  We should now be able to see area counts in the log message. 


## Produce visits count back to Kafka 
Duration: 20:00

* Next task is to produce the result to an Kafka stream. First we need to map the count result into our "Resultat" Avro object.

 
```@java

        areaCounts.toStream().peek(
            (navn, teller) -> System.out.println("stedsnavn = [" + navn + "], teller = [" + teller + "]")
        ).mapValues(new ValueMapperWithKey<String, Long, Resultat>() {
            @Override
            public Resultat apply(String poststed, Long teller) {
                return new Resultat(poststed, teller); // map to result object
            }
        }).to("NavVisitorAreaCounter"); // produce the result back to Kafka as an stream
        
        // and finally configure and start the stream
       final KafkaStreams streams = new KafkaStreams(builder.build(), streamsConfiguration);

        streams.cleanUp();
        streams.start();

        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
```

* (Re-)Start the consumer
* We can verify that the result is produced to Kafka by starting a console Avro consumer. 

```@bash
docker run --net=host -it confluentinc/cp-schema-registry:latest kafka-avro-console-consumer --bootstrap-server localhost:29092 --property schema.registry.url=http://localhost:8081 --topic NavVisitorAreaCounter
``` 

This concludes this tutorial - but feel free to play around with the Kafka Streams API.
