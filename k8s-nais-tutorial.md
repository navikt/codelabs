author: Team Aura
id: k8s-nais-tutorial
summary: This tutorial walks you through Kubernetes basics and introduces you to how to deploy on NAIS.
status: draft
feedback link:

# Kubernetes and NAIS tutorial


## About this tutorial
This tutorial walks you through Kubernetes basics and will introduce you to the features that the NAIS platform provides
you.

### Kubernetes
[Kubernetes](https://kubernetes.io) is a system for deploying and managing containerized applications.

### NAIS
[NAIS](https://nais.io) is [NAV](https://nav.no)'s application infrastructure platform built to increase development speed by providing our developers at NAV with the best possible tools to develop and run their applications. The platform is  based on Kubernetes and provides additional tools and components that our developers might need.

## Prerequisites
Duration: 3:00

- You must install the [gcloud-sdk](https://cloud.google.com/sdk/docs/downloads-interactive) locally on your machine
- Access to a NAIS cluster on Google Cloud Platform

## Setup
Duration: 15:00

### Google Cloud SDK
Set up the Google Cloud SDK tool:
```
gcloud init
```

When asked about whether to create a new project, say no.
Make sure you answer yes when prompted to let the installer modify your profile to update your `PATH` in order to get gcloud binary directory added to your path.  Remember to log in with your @nav adress.

### Kubectl
We need to install the Kubernetes command line tool `kubectl`. If you have installed it, skip this step.
Install through the `gcloud` tool you installed in the first section: 
```
gcloud components install kubectl
```
Verify gcloud kubectl is properly installed by issuing `kubectl version`. Output should be something like:
```
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"13", GitVersion:"v1.13.0", GitCommit:"ddf47ac13c1a9483ea035a79cd7c10005ff21a6d", GitTreeState:"clean", BuildDate:"2018-12-03T21:04:45Z", GoVersion:"go1.11.2", Compiler:"gc", Platform:"darwin/amd64"}
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```
Don't worry about the second line, it just means that we've not connected to a cluster yet.
You can also install `kubectl` using the instructions on the [Kubernetes documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl).

#### (Optional) Shell autocompletion
If you want to enable shell autocompletion, you need to run the steps described [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion). 

### Access
You also need access to the Kubernetes cluster:
```
gcloud container clusters get-credentials CLUSTER_NAME --zone europe/north1-a --project PROJECT_NAME --account YOUR_EMAIL
```

This command will authenticate you against the Kubernetes cluster CLUSTER_NAME.
Verify that you have gained access by running:
```
kubectl get pods
```

It might not output anything, but as long as it doesn't give an error, you are all good.

The command writes to a config file, default `$HOME/.kube/config`, you can take a look at it if you're curious.

## Docker
Duration: 2:00

Docker is a technology that allows us to package an application with it's requirements and basic operating system into a container. Read
more [here](https://www.docker.com/resources/what-container).  As this tutorials primary focus is kubernetes (which orchestrates
containers), we will not dive deeper into Docker, but rather use an already existing docker image called echoserver. Echoserver is a simple
web app that responds with some metadata about it's host and a few key request headers.
Echoserver image url: `gcr.io/google-containers/echoserver`

## Kubernetes
Duration: 2:00

Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications.  It groups containers that make up an application into logical units for easy management and discovery. Kubernetes builds upon 15 years of experience of running production workloads at Google, combined with best-of-breed ideas and practices from the community.

## Run your first application
Duration: 10:00

In this section we will make a pod. We will use an existing application that's already Dockerized for us.

A [pod](https://kubernetes.io/docs/tutorials/kubernetes-basics/explore/explore-intro/#kubernetes-pods) is a Kubernetes abstraction that
represents a group of one or more application containers, and some shared resources for those containers. Those resources include:
- Shared storage, as Volumes
- Networking, as a unique cluster IP address
- Information about how to run each container, such as the container image version or specific ports to use

### Creating your first pod
As we will create multiple files in the tutorial we suggest making a directory `$HOME/workshop` where you can store your files as you work
on them.

Create a file `pod.yaml` with the following contents:
```
apiVersion: v1
kind: Pod
metadata:
  name: <YOUR_NAME>-echoserver
spec:
  containers:
  - name: echoserver
    image: gcr.io/google-containers/echoserver:1.9
    ports:
    - containerPort: 8080
      protocol: TCP
```
And run `kubectl apply -f pod.yaml`

### Checking the status of our new pod
```
kubectl get pod <YOUR_NAME>-echoserver
```
You can see the status of your pod, ready containers, restarts and the age of the pod.

Lets take a closer look at the pod we created:
```
kubectl describe pod <YOUR_NAME>-echoserver
```
This will list more detailed information about this pod like its labels and the state of the container.

## Upgrading your application
There is a newer version of echoserver available, so lets run the new image:

Edit the `pod.yaml` file we created earlier, setting the `image` field to `gcr.io/google-containers/echoserver:1.10` resulting in the
following contents:
```
apiVersion: v1
kind: Pod
metadata:
  name: <YOUR_NAME>-echoserver
spec:
  containers:
  - name: echoserver
    image: gcr.io/google-containers/echoserver:1.10
    ports:
    - containerPort: 8080
      protocol: TCP
```
Then run `kubectl apply -f pod.yaml`

Lets verify that it is updated:
```
kubectl describe pod <YOUR_NAME>-echoserver
```
and look for the `Image` field and verify it's value is now `gcr.io/google-containers/echoserver:1.10`

## Summary
In this chapter we've created, looked at, and updated a pod. The downside with using pods like we've just done is that a pod is bound to a specific server in the cluster and also won't be able to scale horizontally. In the next chapter, we'll take a close look at *Deployments*, which solves these issues.

# Deployment
What we could do is to delete the deployment. But our original intention was not to delete the app, it was to update it.
Deleting the deployment will result in down time for our users. So lets look at alternatives.

First of all, open a new terminal window and run this command to watch your pod:
```
kubectl get pods --watch | grep YOUR_NAME
```

Keep this terminal window open, and preferably visible next to the other terminal window.


It is possible to edit the Deployment. In the first terminal window, run:

```
kubectl edit deploy tutorial-YOUR_NAME

```

This will open your default editor, describing the deployment in the YAML format. Navigate to the field `spec.template.spec.containers.image` and insert the image name `gcr.io/google-containers/echoserver:1.10`.

In terminal window watching the pods, you will see that old pod is terminating at once, while the new ones are initializing. This means that we did not achieve update without the application being down. Keep this window open.

## Rolling update
Duration: 5:00

In the previous section, we managed to run our application on Kubernetes, and while thats good and all, we need a more robust way to deploy an application.

TODO: Deployment infos

Lets first take a look at the Deployment:

``` 
kubectl describe deployment tutorial-YOUR_NAME
```
 

Deployment is the most common way of running X copies (Pods) of your application. And it supports rolling updates to your container images.
The resource contains information about what Docker image to spin up in a container, environment variables and all the information Kubernetes needs to create a pod for your app.


### Write the configuration file

The first time we deployed the application on Kubernetes, we used the `kubectl run` command. This time we will write a configuration file which we will apply in the cluster.

Create a file with the name `deployment.yaml`.

In this yaml file, we will describe the desired state for our application. 

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: NAME
spec:
  replicas: NUMBER_OF_COPIES
  selector:
    matchLabels:
      app: MATCH_LABEL
  template:
    metadata:
      labels:
        app: MATCH_LABEL
    spec:
      containers:
      - name: CONTAINER_NAME
        image: DOCKER_IMAGE
        ports:
        - containerPort: CONTAINER_PORT
```

We need to add more information, so lets go ahead and add our Docker image.
Set the field `spec.template.spec.containers.image` to `gcr.io/google-containers/echoserver:1.10`.

Replicas: 3

We also need to set some metadata and labels:

- Set `metadata.name` to a what ever you want to name your app
  This is the name for the Kubernetes resources created when you apply this file in a cluster.
- Set `metadata.labels.app` to for example `yourname-app`.
  This label will
- Set the same app label to the fields`spec.selector.matchLabels.app` and `spec.template.metadata.labels`

On the last line in the file, you see that we have set the `containerPort` to `80`, which will open that port on the Pod so that we can send traffic to the container.

Apply the file:

```
kubectl apply -f deployment.yaml
```

And watch the update of the Pods in the other terminal window.


Notice that the new Pods have names with different IDs.

// Inspect the replicasets to see that that the deployment created a new one



### Health checks

// helsesjekk, 1 replica = ikke nedefri deployment, neste 3 replicas. Videre til services, så vi veit hvilken ip vi skal gå mot



## Kubernetes service
Duration: 3:00

Run the command to list pods, but this time add the flag `-o wide` in order to get more information:

```
kubectl get pods -o wide | grep YOUR_NAME
```

Notice that the Pods have an internal IP and hopefully the status `Running`.

One of the features of a Pod, is that it is mortal, which also means that we cannot rely on the IP address.


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
