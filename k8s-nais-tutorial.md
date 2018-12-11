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
- Access to a NAIS cluster on Google Cloud Platform

## Setup
Duration: 2:00

### Google Cloud SDK
Set up the Google Cloud SDK tool:

```
gcloud init
```

When asked about whether to create a new project, say no.
Make sure you answer yes when prompted to let the installer modify your profile to update your `PATH` in order to get gcloud binary directory added to your path.
Remember to log in with your @nav adress.


### Kubectl

We need to install the Kubernetes command line tool `kubectl`. If you have installed it, skip this step.

Install through the `gcloud` tool you installed in the first section: 

```
gcloud components install kubectl
```

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

## Run an example app
Duration: 4:00

In this section we will make a first deployment of a small application. We will use an existing application already wrapped in a Docker image for us.

### Docker
Kubernetes is a system for deploying, running and managing containerized applications.
Docker is a container technology that we can use to wrap an application into an image. You can read more about Docker [here](https://docker.io...)

Since Kubernetes supports running applications in containers, we need a containereized application for continuing this tutorial.
The Docker image we will use is called `echoserver`. Image url: `gcr.io/google-containers/echoserver:1.10`

Out of the box, Kubernetes will manage your Docker containers, keep track of whether they are healthy or not and how to reach them.



### Run your container


You can run your container with this command:

```
kubectl run tutorial-YOUR_NAME --image=gcr.io/google-containers/echoserver:1.9
```

This will create your container in a Kubernetes resource that we call pod. 
Pods are the basic unit for all of the workloads you run on Kubernetes. They usually contain one or more containers, along with an internal IP and specifications on how to run the container(s).
Lets take a look at it: 

```
kubectl get pods | grep YOUR_NAME
```

You can see the status of your pod, ready containers, restarts and the age of the pod.
The pod also has a name, which is the name you specified in the `run` command above, but in addition it is postfixed by some numbers and letters, which makes sure the pod has an unique name.

Lets take a closer look at the pod we created:

```
kubectl describe pods INSERT_POD_NAME
```

This will list the labels assigned to the pod, the IP, information about the Docker container and image, the state of the container, the status of the Pod and much more information.

## Update the application

There is a newer version of our echoserver available, so lets run the new image:

```
kubectl run tutorial-YOUR_NAME --image=gcr.io/google-containers/echoserver:1.10
```

Hmm, error... The deployment already exists. To solve this we could go ahead and delete the Pod:

```
kubectl delete pod INSERT_POD_NAME
```

That worked out nicely. Lets verify that it is deleted:

```
kubectl get pods | grep YOUR_NAME
```

Does the output list two Pods? One with the status Terminating (expected, since we deleted it), but also one that is in a state of `Init`, `PodInitializing` or `Running`?
This brings us to another Kubernetes resource type, called RecplicaSet. The ReplicaSet holds our desired state of the application and its job is to make sure we have Pods running according to that state.
So when we delete a Pod, it will create a new one according to the same specification. Take a look at the ReplicaSet:

```
kubectl get replicaset | grep YOUR_NAME
```

It outputs along with its age, how many desired, current and ready Pods it has. Take a closer look at its name. The letters and numbers after the name you chose is the same as the first one in the Pod name.

Perhaps we could delete the ReplicaSet, then, before creating the new container? That will not work either.
Remember the output from run command in the beginning of this section, `deployment "echoserver-YOUR_NAME" created`? The ReplicaSet is controlled by a third Kubernetes resource called Deployment.

```
kubectl get deployment | grep YOUR_NAME
```


The Deployment will recreate the ReplicaSet if we delete it. What we could do is to delete the deployment. But our original intention was not to delete the app, it was to update it.
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


The Pod is the resource where our containerized application is running. It receives traffic and we can inspect its runtime status and health, along other things. It is managed and controlled by its ReplicaSet.

The ReplicaSet contains the desired state for the application and is (usually) managed and owned by a Deployment. First, take a look at the Deployment:

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
  labels:
    app: APP_LABEL
spec:
  replicas: NUMBER_OF_COPIES
  selector:
    matchLabels:
      app: MATCH_LABEL
  template:
    metadata:
      labels:
        app: APP_LABEL
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
