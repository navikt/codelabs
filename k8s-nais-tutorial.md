author: Team Aura
id: k8s-nais-tutorial
summary: This tutorial walks you through Kubernetes basics and introduces you to how to deploy on NAIS.
status: draft
feedback link:

# Kubernetes and NAIS tutorial


## About this tutorial
This tutorial walks you through Kubernetes basics and will introduce you to the features the [NAIS](https://nais.io) platform provides you.

### About Kubernetes
[Kubernetes](https://kubernetes.io) is a system for deploying and managing conterinized applications. Not familiar with containers? Don't worry, you will learn about it in this tutorial as well.

### About NAIS
NAIS is [NAV](https://nav.no)'s application infrastructure platform built to increase development speed by providing our developers at NAV with the best possible tools to develop and run their applications. The platform based on Kubernetes and provides additional tools and components that our developers might need.

## Prerequisites
Duration: 3:00

- You must install the [gcloud-sdk](https://cloud.google.com/sdk/docs/downloads-interactive) locally on your machine
- Docker - see https://www.docker.com/get-started for instructions.
- An account on a Docker registry, e.g. https://dockerhub.com
- Clone the [nais-tutorial](https://github.com/nais/nais-tutorial) repository

## Set up gcloud
Duration: 2:00


Set up the Google Cloud SDK tool:

```
gcloud init
```

When asked about whether to create a new project, say no.


## Docker
Duration: 10:00

We will in this section create a Docker image for our application, but first, lets take a look at Docker.

### About Docker
Docker is a container technology that we can use to wrap an application into an image. 

Take a look at the repository `nais-tutorial`. This contains source code for a small example application. As you can see, it also contains a file `Dockerfile`. This file contains instructions on how to create a Docker image for the application.

More info........	


### About the Dockerfile

### Create a Docker image

In the folder `nais-tutorial` run this command to build a Docker image, remember to insert your username:

```
docker build -t YOUR_USERNAME/nais-demoapp .
```

This will create an image of the application. To list your local images:

```
docker images
```

You can test the image locally by running:

```
docker run -d -p 8080 YOUR_USERNAME/nais-demoapp
```

This will spin up a container based on your image.
To view the application in your browser, you need to find out which port it is mapped to:

```
docker ps
```

Note the port mapping (`0.0.0.0:12345(random port) -> 8080`) and visit `localhost:INSERT_RANDOM_PORT` in your most loved browser. You should see the text "Hello, world!"

### Push to Docker registry

#### Log into Dockerhub
....

We need the docker image to be available on the internet in order to deploy it to Kubernetes. Push it to your Docker registry:

```
docker push YOUR_USERNAME/nais-demoapp
```

You can see that it pushes your image in layers. (INSERT INFO ON LAYERS)


## Access the Kubernetes cluster

## Kubernetes deployment

## Kubernetes service
