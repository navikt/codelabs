author: Team Aura
id: k8s-nais-tutorial
summary: This tutorial walks you through Kubernetes basics and introduces you to how to deploy on NAIS.
status: draft
feedback link:

# Kubernetes and NAIS tutorial


## About this tutorial
This tutorial walks you through Kubernetes basics and will introduce you to the features the [NAIS](https://nais.io) platform provides you.

### About Kubernetes
[Kubernetes](https://kubernetes.io) is a system for deploying and managing containerized applications. Not familiar with containers? Don't worry, you will learn about it in this tutorial as well.

### About NAIS
NAIS is [NAV](https://nav.no)'s application infrastructure platform built to increase development speed by providing our developers at NAV with the best possible tools to develop and run their applications. The platform based on Kubernetes and provides additional tools and components that our developers might need.

## Prerequisites
Duration: 3:00

- You must install the [gcloud-sdk](https://cloud.google.com/sdk/docs/downloads-interactive) locally on your machine
- Access to a Kubernetes cluster on Google Cloud Platform

## Set up gcloud
Duration: 2:00


Set up the Google Cloud SDK tool:

```
gcloud init
```

When asked about whether to create a new project, say no.


## Docker
Duration: 2:00

Docker is a container technology that we can use to wrap an application into an image. masse info her <3 We will use an existing image called `echoserver`. Image url: `gcr.io/google-containers/echoserver:1.10`




## Kubernetes
Duration: 4:00

Now that we have made our Docker image available on the web, the time has come to take a look at Kubernetes. Out of the box, Kubernetes will manage your Docker containers, keep track of whether they are healthy or not and how to reach them. In this section, we will deploy our container on a Kubernetes cluster.

### Kubectl

We need to install the Kubernetes command line tool `kubectl`. If you have installed it, skip this step.

You can install `kubectl` using the instructions on the [Kubernetes documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl) or install through the `gcloud` tool you installed in the first section: 

```
gcloud components install kubectl
```


### Access

To deploy to the Kubernetes cluster, you need access:

```
gcloud container clusters get-credentials CLUSTER_NAME --zone europe/north1-a --project PROJECT_NAME --account YOUR_EMAIL
```

This command will authenticate you against the Kubernetes cluster CLUSTER_NAME.
Check that you're authenticated by listing services in the cluster:

```
kubectl get pods
```

It might not output anything, but as long as it doesn't give an error, you are all good.

The command writes to a config file, default `$HOME/.kube/config`, you can take a look at it if you're curious.

### Run your container


You can run your container with this command:

```
kubectl run YOUR_NAME-demoapp --image=YOUR_USERNAME/nais-demoapp:1.0
```

This will create your container in a Kubernetes resource that we call pod. Lets take a look at it:

```
kubectl get pods
```

Pods are Kubernetes resources that mainly contain one or more containers, along with an internal IP and specifications on how to run the container(s). The pod we now created only contain one container. If your application is using a proxy, you might want to specify several containers in one pod.

## Kubernetes deployment
Duration: 5:00

In the previous section, we managed to run our application on Kubernetes, and while thats good and all, we need a more robust way to deploy an application.

Pods are the basic component in Kubernetes, but they are not reliable. In fact, they are mortal. Kubernetes will not guarantee that a running pod is running ...
So to deal with this, we introduce the concept of deployments.

Normally we let Kubernetes manage the pods for us, so instead we will create the resource Deployment. This resource will manage our application pods. The resource contains information about what Docker image to spin up in a container, environment variables and all the information Kubernetes needs to create a pod for your app. The deployment also holds information of the desired number of pods you want running.

### Create a deployment
Lets create a deployment. Open the file `deployment.yaml` in the repository you cloned.

In this yaml file, we will describe the desired state for our application. For example, you can see that the field `replicas` is set to `3`. This means that we want 3 pods for this application running. 

We need to add more information, so lets go ahead and add our Docker image.

```
    spec:
      containers:
      - name: app-container
        image: INSERT_IMAGE_HERE
```

Set the field `spec.template.spec.containers.image` to `YOUR_DOCKERHUB_USERNAME/nais-demoapp:1.0`, which tells Kubernetes to pull the image nais-demoapp version 1.0 from your Docker Hub account.


We also need to set some metadata and labels:

- Set `metadata.name` to a what ever you want to name your app
  This is the name for the Kubernetes resources created when you apply this file in a cluster.
- Set `metadata.labels.app` to for example `yourname-app`.
  This label will
- Set the same app label to the fields`spec.selector.matchLabels.app` and `spec.template.metadata.labels`

On the last line in the file, you see that we have set the `containerPort` to `80`, which will open that port on the Pod so that we can send traffic to the container.

// helsesjekk, 1 replica = ikke nedefri deployment, neste 3 replicas. Videre til services, så vi veit hvilken ip vi skal gå mot


## Kubernetes service

## Ingress

## Inspect your app

## NAIS
Duration: 5:00

## Logging and metrics

## Clean-up
Duration 1:00

## Further reading

Check out the NAIS documentation at [https://nais.io/doc](https://nais.io/doc) and the Kubernetes documentation over at [https://kubernetes.io/docs/](https://kubernetes.io/docs/).

We can also recommend [the illustrated childrens guide to Kubernetes](https://www.youtube.com/watch?v=4ht22ReBjno).
