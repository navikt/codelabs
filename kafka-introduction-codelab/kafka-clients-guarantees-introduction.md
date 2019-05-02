author: Geir André Lund
summary: Kafka-clients introduction codelab.
id: kafka-clients-guarantees-intro
categories: kafka,java,event-driven
environments: Java
status: draft
feedback link:
analytics account: 0

# Kafka-clients introduction

## Overview of the tutorial

This tutorial shows you how to create a Kafka-consumer and -producer using [kafka-clients](http://kafka.apache.org/documentation/#api) java library.

What you'll learn
* How to create a Kafka "safe" producer that produce data from a Kafka-broker
* How to create a Kafka "safe" consumer that reads data from a Kafka-broker

Positive
: This tutorial requires that you are familiar with Java programming language.

### Prerequisites
Duration: 10:00

* Internet connectivity
* Java SKD installed - see [https://www.oracle.com/technetwork/java/javase/downloads/index.html](https://www.oracle.com/technetwork/java/javase/downloads/index.html) for instructions.
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

* [Download project](https://github.com/navikt/kafka-clients-guarantees-codelab/archive/master.zip)
* Extract the project to a directory. 


As an alternative, use git to clone the project:
```@bash
git clone https://github.com/navikt/kafka-clients-guarantees-codelab.git
```
(On NAV developer image you will need add proxy by running `git config --global http.proxy http://webproxy-utvikler.nav.no:8088` first)

### Gradle


In project root, run gradle:

```@bash
$ cd codelab-kafka-clients  
$ ./gradlew --offline build
```

or on Windows:

``` bash
$ cd codelab-kafka-clients
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

NavVisitorLocation is a topic produced to Kafka each time a visitor visits the nav.no webpage. Each message is structured as JSON with postal- and  municipality information, example:

```@json
{"postnummer":"2005","stedsnavn":"RÆLINGEN","kommune":"0228"}
```

1. Create a consumer that consumes `NavVisitorLocation` topic (See NavBesøkProducer.java in the project).
2. Track visits per area (stedsnavn) 
2. Based on area visits, print information of the top three areas that have the highest count. 


## The NavVisitorLocation topic producer
Duration: 10:00

* Provided in the project there is a Java class named `NavVisitorProducer.java`. This class should produce random postal location on a topic named `NavVisitorLocation` but first we have to create the topic. 

1. Running the command from the command line: `docker run --net host confluentinc/cp-kafka kafka-topics --create  --zookeeper localhost:2181 -topic NavVisitorLocation --replication-factor 2 --partitions 4` will create the topic
2. To verify that the topic as been created, we can run: `docker run --net host confluentinc/cp-kafka kafka-topics --describe  --zookeeper localhost:2181 -topic NavVisitorLocation`


## Create an NavVisitorLocation topic consumer

Duration: 10:00

* In IntelliJ - Create a new Java file, give it a name (e.g. `NavVisitorConsumer.java`)
* We need to declare a `KafkaConsumer` and instantiate it;


```@java
public class NavVisitorConsumer {

    private final static String TOPIC = "NavVisitorLocation";
    private final static String BOOTSTRAP_SERVERS = "localhost:9092";
    private final static Logger LOG = LogManager.getLogger();
    
    public static void main(String[] args) {
        final Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, BOOTSTRAP_SERVERS);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "visitor-consumer");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());

        KafkaConsumer<String, String> navBesøkConsumer = new KafkaConsumer<>(props);
        navBesøkConsumer.subscribe(Collections.singleton(TOPIC));

     
        while (true) {
            ConsumerRecords<String, String> records = navBesøkConsumer.poll(Duration.ofMillis(100));
            for (ConsumerRecord<String, String> record : records) {
                LOG.info("Consumed " + record);
            }
        }
    }
}
```


* We should now be able to consume records from Kafka. Try it out by first start the consumer we just created (Run the main method in IntelliJ) and then start the producer, `NavVisitorProducer` (Run the main method in IntelliJ). If all looks good, go ahead to the next section.


## Track visits per area (stedsnavn) 
Duration: 20:00

For each record, we increase a counter for that area. `PoststedCounter.java` have a method `count` which take a `Poststed` as an argument and increase a counter by 1 each time a unique `Poststed` is added. 

1. First we need to take the record value (JSON) and convert it to an `Poststed` object:` Poststed poststed = new Gson().newBuilder().create().fromJson(record.value(), Poststed.class);`
2. Create an instance of the `PoststedCounter`: `PoststedCounter counter = new PoststedCounter()` (outside the while loop)
3. Add the parsed `Poststed` object to the counter: `counter.count(poststed);`
4. Print result


something like:

```@java
        ..... 
        
        PoststedCounter counter = new PoststedCounter()
        while (true) {
            ConsumerRecords<String, String> records = navBesøkConsumer.poll(Duration.ofMillis(100));
            for (ConsumerRecord<String, String> record : records) {
                LOG.info("Consumed " + record);
                Poststed poststed = new Gson().newBuilder().create().fromJson(record.value(), Poststed.class);
                counter.count(poststed);
            }
            if(!records.isEmpty()){
                LOG.info("Top three -> {}", counter.getTopThreeCount());
            }
        }
```

## Handle Exceptions and safe consumer
Duration: 10:00

`PoststedCounter` is not safe and will throw an exception in certain circumstances. Our consumer is currently configured to autocommit offsets after topic reads. We need to take control over when we do commit in order to not "loose" messages. 

1. Disable `autocommit`: `props.setProperty(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false"); // disable auto commit of offsets`  
2. Read earliest messages `props.setProperty(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest"); // disable auto commit of offsets`
2. Create an "record consumed counter": `Integer consumedCounter = 0;` outside the while loop
3. Add `navBesøkConsumer.commitSync()` after the `for(Consu...` loop, and inside an if statement checking `consumedCounter` against `records.count()`

Something like:

````@java
        int consumedCounter = 0;
        while (true) {
            ConsumerRecords<String, String> records = navBesøkConsumer.poll(Duration.ofMillis(100));
            for (ConsumerRecord<String, String> record : records) {
                Poststed poststed = new Gson().newBuilder().create().fromJson(record.value(), Poststed.class);
                counter.count(poststed);
                consumedCounter++;
            }
            if(consumedCounter == records.count()){ 
                if (!records.isEmpty()) {
                    navBesøkConsumer.commitSync();
                    LOG.info("Top three -> {}", counter.getTopThreeCount());
                    consumedCounter = 0;
                }
            }

        }
````

### Optional: Produce top three areas to a new topic

Create an producer that produces "top three areas" to an topic. 








