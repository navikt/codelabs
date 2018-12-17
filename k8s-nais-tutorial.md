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

### Setup
Duration: 15:00

#### Google Cloud SDK
Get sa.json file from Vegar or Line.

Set up the Google Cloud SDK tool:
```bash
gcloud auth activate-service-account --key-file=sa.json
gcloud config set compute/region europe-north1
gcloud config set compute/zone europe-north1-a
gcloud config set core/project nais-dev-gke
```

#### Kubectl
We need to install the Kubernetes command line tool `kubectl`. If you have installed it, skip this step.
Install through the `gcloud` tool you installed in the first section:
```bash
gcloud components install kubectl
```
Verify gcloud kubectl is properly installed by issuing `kubectl version`. Output should be something like:
```bash
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"13", GitVersion:"v1.13.0", GitCommit:"ddf47ac13c1a9483ea035a79cd7c10005ff21a6d", GitTreeState:"clean", BuildDate:"2018-12-03T21:04:45Z", GoVersion:"go1.11.2", Compiler:"gc", Platform:"darwin/amd64"}
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```
Don't worry about the second line, it just means that we've not connected to a cluster yet.
You can also install `kubectl` using the instructions on the [Kubernetes documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl).

#### (Optional) Shell autocompletion
If you want to enable shell autocompletion, you need to run the steps described [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion).

#### Access
You also need access to the Kubernetes cluster:
```bash
gcloud container clusters get-credentials dev-gke
```

This command will authenticate you against the Kubernetes cluster `nais-dev`.
Verify that you have gained access by running:
```bash
kubectl get pods
```

It might not output anything, but as long as it doesn't give an error, you are all good.

The command writes to a config file, default `$HOME/.kube/config`, you can take a look at it if you're curious.

## Technologies
### Docker
Duration: 2:00

Docker is a technology that allows us to package an application with it's requirements and basic operating system into a container. Read
more [here](https://www.docker.com/resources/what-container).  As this tutorials primary focus is kubernetes (which orchestrates
containers), we will not dive deeper into Docker, but rather use an already existing docker image called echoserver. Echoserver is a simple
web app that responds with some metadata about it's host and a few key request headers.
Echoserver image url: `gcr.io/google-containers/echoserver`

### Kubernetes
Duration: 2:00

Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications.  It groups containers that make up an application into logical units for easy management and discovery. Kubernetes builds upon 15 years of experience of running production workloads at Google, combined with best-of-breed ideas and practices from the community.

## Pod
Duration: 10:00

In this section we will make a Pod. We will use an existing application that's already Dockerized for us.

A [Pod](https://kubernetes.io/docs/tutorials/kubernetes-basics/explore/explore-intro/#kubernetes-pods) is a Kubernetes abstraction that
represents a group of one or more application containers, and some shared resources for those containers. Those resources include:
- Shared storage, as Volumes
- Networking, as a unique cluster IP address
- Information about how to run each container, such as the container image version or specific ports to use

### Creating your first Pod
As we will create multiple files in the tutorial we suggest making a directory `$HOME/workshop` where you can store your files as you work
on them.

Create a file `pod.yaml` with the following contents:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: <YOUR_APP>
spec:
  containers:
  - name: echoserver
    image: gcr.io/google-containers/echoserver:1.9
    ports:
    - containerPort: 8080
      protocol: TCP
```
And run `kubectl apply -f pod.yaml`

### Checking the status of our new Pod
```bash
kubectl get pod <YOUR_APP>
```
You can see the status of your Pod, ready containers, restarts and the age of the Pod.

Lets take a closer look at the Pod we created:
```
kubectl describe pod <YOUR_APP>
```
This will list more detailed information about this Pod like its labels and the state of the container.

### Upgrading your application
There is a newer version of echoserver available, so lets run the new image:

Edit the `pod.yaml` file we created earlier, setting the `image` field to `gcr.io/google-containers/echoserver:1.10` resulting in the
following contents:
```
apiVersion: v1
kind: Pod
metadata:
  name: <YOUR_APP>
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
kubectl describe pod <YOUR_APP>
```
and look for the `Image` field and verify it's value is now `gcr.io/google-containers/echoserver:1.10`

### Summary
In this chapter we've created, looked at, and updated a Pod. The downside with using pods like we've just done is that a Pod is bound to a specific server in the cluster,  won't be able to scale horizontally, and the fact that Pods are _mortal_, meaning they can die. In the next chapter, we'll take a close look at *Deployments*, which solves all of these issues.

## Deployment
Duration: 10:00

Deployments are the most common way of running Pods of your application. And it supports features like rolling updates, scaling and more.
The resource contains information about what Docker image to spin up in a container, environment variables and all the information Kubernetes needs to create a Pod for your app.

### Delete old Pod
Delete your old Pod:
```
kubectl delete pod <YOUR_APP>
```

### Create deployment
Create a deployment like this `deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <YOUR_APP>
spec:
  replicas: 1
  selector:
    matchLabels:
      app: <YOUR_APP>
  template:
    metadata:
      labels:
        app: <YOUR_APP>
    spec:
      containers:
      - name: nais-testapp
        image: gcr.io/google-containers/echoserver:1.10
        ports:
        - containerPort: 8080
          protocol: TCP
```

Let's go through some of the fields in this resource.
`spec.template` this is almost the same as the pod we wrote in the previous chapter.
`spec.replicas` number of pods to run
`spec.selector` which pods this deployment manages

You might also have noticed that the `spec.template.metadata` does not contain a `.name` field any more, but instead a `metadata.labels.app: <YOUR_APP`. The reason for this is that the pods this Deployment creates will have unique, auto-generated names, and therefore we need some other mechanism to keep track of this deployments pods (labels).

Let's apply it and see what happend:
```bash
kubectl apply -f deployment.yaml
kubectl get pod -l app=<YOUR_APP> # Uses label selector to get the pods labeled with app=<YOUR_NAME>
```

There are a lot of features not covered in this tutorial, but you should check out the [Deployment documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

## Service
Duration: 15m

The echoserver is an application meant to respond to HTTP requests. Our application is not currently configured for reliable or redundant communication. While it is possible to communicate with it using the Pod's IP address and the containers port (in some network configurations) this is not the recommended way because:
- a pods IP is not not static
- you won't be able to load balance
- you get a new Pod IP change every time a new Pod is created

The way kubernetes solves this is by using [services](https://kubernetes.io/docs/concepts/services-networking/service/)

### Service
A Kubernetes Service is an abstraction which defines a logical set of Pods and a policy by which to access them - sometimes called a micro-service. The set of Pods targeted by a Service is (usually) determined by a Label Selector.

#### Creating a Service
To make our echoserver availble inside the cluster we would create a `service.yaml` file like this:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: <YOUR_APP>
spec:
  type: ClusterIP
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: <YOUR_APP>
```
This makes it possible for other apps in the cluster to communicate with our app using `http://<YOUR_APP/`.

### Service discovery
Every service in kubernetes can be addressed using the service name (`<YOUR_APP>`), using the service + namespace (`service.namespace`), or by using the fully qualified cluster dns (usually `service.namespace.svc.cluster.local`)

## Ingress
The [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) resource manages external access to the services in a cluster, typically HTTP.

### Create ingress
Create a file `ingress.yaml` with the following contents:
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: <YOUR_APP>
spec:
  rules:
  - host: <YOUR_APP>.demo.dev-gke.nais.io
    http:
      paths:
      - backend:
          serviceName: <YOUR_APP>
          servicePort: 80
        path: /
```
Notice that we target a service by name here, not labels.

apply it `kubectl apply -f ingress.yaml`

This should enable you to access your echoserver using the following address: `https://<YOUR_APP>.demo.dev-gke.nais.io`, try it out:
```bash
curl http://<YOUR_APP>.demo.dev-gke.nais.io
```

## Rolling update
Duration: 5:00

In this chapter we'll take a look a thow we can roll out updates without interrupting the availability of our app.

### Adding a label
Let's say we wanted to add a new label to our pods, let's give it a try.

In your `deployment.yaml`
Set `spec.template.metadata.labels.important` to `obviously`

The metadata part of the template should something look like this:
```yaml
  template:
    metadata:
      labels:
        app: <YOUR_APP>
        important: obviously
```

Now, apply the deployment: `kubectl apply -f deployment.yaml; kubectl get pods -l app=<YOUR_APP>`
You should see two pods, one in the "ContainerCreating" state and one "Running". This is due to the fact that de default deployment strategy in kubernetes is "RollingUpdate", you can check this by issuing: `kubectl describe deployment <YOUR_APP>` and looking at the fields `StrategyType` and `RollingUpdateStrategy`

If the application you're running has 0ms startup time, this would be enough for zero downtime updates, however most apps need some time to warm up before they can start serving requests.

Enter Readiness probes.

### Readiness probe
Modify your `deployment.yaml` adding a readiness probe
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <YOUR_APP>
spec:
  replicas: 1
  selector:
    matchLabels:
      app: <YOUR_APP>
  template:
    metadata:
      labels:
        app: <YOUR_APP>
    spec:
      containers:
      - name: nais-testapp
        image: gcr.io/google-containers/echoserver:1.10
        ports:
        - containerPort: 8080
          protocol: TCP
        readinessProbe:
          httpGet:
            path: /
            port: 8080
```

## Scaling
Duration: 5m
```
kubectl scale deployment --replicas 2 <YOUR_APP>
kubectl get pod -l app=<YOUR_APP> # Notice you've got 2 pods now.
```

Go to https://YOUR_APP.demo.dev-gke.nais.io/ and refresh a couple of times, notice how the hostname changes? This is due to the fatc that
we're being load-balanced between our two pods.

## Inspect your app
### Logs
As long as your app logs to `stdout` the logs are available by using `kubectl logs <POD_NAME>`


## NAIS
Duration: 5:00

## Logging and metrics

## Clean-up
Duration 1:00

## Further reading

Check out the NAIS documentation at [https://nais.io/doc](https://nais.io/doc) and the Kubernetes documentation over at [https://kubernetes.io/docs/](https://kubernetes.io/docs/).

We can also recommend [the illustrated childrens guide to Kubernetes](https://www.youtube.com/watch?v=4ht22ReBjno).
