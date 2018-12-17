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
  name: <YOUR_NAME>
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
kubectl get pod <YOUR_NAME>
```
You can see the status of your pod, ready containers, restarts and the age of the pod.

Lets take a closer look at the pod we created:
```
kubectl describe pod <YOUR_NAME>
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
  name: <YOUR_NAME>
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
kubectl describe pod <YOUR_NAME>
```
and look for the `Image` field and verify it's value is now `gcr.io/google-containers/echoserver:1.10`

## Summary
In this chapter we've created, looked at, and updated a pod. The downside with using pods like we've just done is that a pod is bound to a specific server in the cluster and also won't be able to scale horizontally. In the next chapter, we'll take a close look at *Deployments*, which solves these issues.

# Deployment
Deployments are one of the most central parts in kubernetes.
## Clean up pod
Delete your old pod:
```
kubectl delete pod <YOUR_NAME>
```

## Create deployment
Deployment is the most common way of running X copies (Pods) of your application. And it supports rolling updates to your container images.
The resource contains information about what Docker image to spin up in a container, environment variables and all the information Kubernetes needs to create a pod for your app.

Create a deployment like this `deployment.yaml`:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <YOUR_NAME>
spec:
  replicas: 1
  selector:
    matchLabels:
      app: <YOUR_NAME>
  template:
    metadata:
      labels:
        app: <YOUR_NAME>
    spec:
      containers:
      - name: nais-testapp
        image: gcr.io/google-containers/echoserver:1.10
        ports:
        - containerPort: 8080
          protocol: TCP
```

Let's go through some of the fields in this resource.
|field|description|
---
|spec.template|this is the same as the previous pod spec|
|spec.replcas|number of pods to run|
|spec.selector|which pods this deployment manages|

You might also have noticed that the `spec.template.metadata` does not contain a `.name` field any more, but instead a `metadata.labels.app: <YOUR_NAME`. The reason for this is that the pods this Deployment creates will have unique names, and therefore we need some other mechanism to keep track of this deployments pods.

Let's apply it and see what happend:
```
kubectl apply -f deployment.yaml
kubectl get pod -l app=<YOUR_NAME> # Uses label selector to get the pods labeled with app=<YOUR_NAME>
```

There are a lot of features not covered in this tutorial, but you should check out the [Deployment documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

# Connectivity
The echoserver is an application meant to respond to HTTP requests. Our application is not currently configured for reliable or redundant communication. While it is possible to communicate with it using the POD's IP address and the containers port (in some network configurations) this is not the recommended way because:
- a pods IP is not not static
- you won't be able to load balance
- you get a new pod IP change every time a new POD is created

The way kubernetes solves this is by using [services](https://kubernetes.io/docs/concepts/services-networking/service/)

## Service
A Kubernetes Service is an abstraction which defines a logical set of Pods and a policy by which to access them - sometimes called a micro-service. The set of Pods targeted by a Service is (usually) determined by a Label Selector.

### Creating a Service
To make our echoserver availble inside the cluster we would create a `service.yaml` file like this:
```
apiVersion: v1
kind: Service
metadata:
  name: <YOUR_NAME>
spec:
  type: ClusterIP
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: <YOUR_NAME>
```
This makes it possible for other apps in the cluster to communicate with our app using `http://<YOUR_NAME/`.

### Service discovery
Every service in kubernetes can be addressed using the service name (`<YOUR_NAME>`), using the service + namespace (`service.namespace`), or by using the fully qualified cluster dns (usually `service.namespace.svc.cluster.local`) 

## Ingress
The [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) resource manages external access to the services in a cluster, typically HTTP.

### Create ingress
Create a file `ingress.yaml` with the following contents:
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
  name: <YOUR_NAME>
spec:
  rules:
  - host: <YOUR_NAME>.demo.dev-gke.nais.io
    http:
      paths:
      - backend:
          serviceName: <YOUR_NAME>
          servicePort: 80
        path: /
```
Notice that we target a service by name here, not labels.

apply it `kubectl apply -f ingress.yaml`

This should enable you to access your echoserver using the following address: `https://<YOUR_NAME>.demo.dev-gke.nais.io`, try it out:
```
curl https://<YOUR_NAME>.demo.dev-gke.nais.io
```

## Rolling update
Let's say we wanted to set an environment variable in our pods, but don't want to interrupt the availability of our app.
// Update
In terminal window watching the pods, you will see that old pod is terminating at once, while the new ones are initializing. This means that we did not achieve update without the application being down. Keep this window open.

Duration: 5:00

In the previous section, we managed to run our application on Kubernetes, and while thats good and all, we need a more robust way to deploy an application.
```
kubectl describe deployment tutorial-YOUR_NAME
```

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
