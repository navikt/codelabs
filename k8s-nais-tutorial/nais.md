author: Team Aura
id: nais-tutorial
summary: This tutorial walks you through to how to deploy on NAIS.
status: draft
feedback link:

# NAIS tutorial

## About this tutorial
This tutorial walks you through NAIS basics and will introduce you to the features that the NAIS platform provides
you.

### NAIS
[NAIS](https://nais.io) is [NAV](https://nav.no)'s application infrastructure platform built to increase development speed by providing our developers at NAV with the best possible tools to develop and run their applications. The platform is  based on Kubernetes and provides additional tools and components that our developers might need.

## Prerequisites
Duration: 3:00

- Docker Desktop for Mac/Windows locally on your machine
- Enable Kuberentes via Docker Desktop
- Kubectl

### Setup
Duration: 15:00

#### Docker Desktop for Mac/Windows
Users working on Mac can download and install the application from [docker-ce-desktop-mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac)

Windows users are recommended to follow the setup from Github: [Oppsett av Docker på Windows laptop](https://github.com/navikt/utvikling/blob/master/Oppsett%20av%20Docker%20p%C3%A5%20Windows%20laptop.md)

PS: Windows-users, be sure that you have local admin on your computer

#### Enable Kubernetes locally
When Docker Desktop is installed, you can follow one of the two tutorials for enabling Kubernetes

* Mac: https://docs.docker.com/docker-for-mac/#kubernetes
* Windows: https://docs.docker.com/docker-for-windows/#kubernetes

#### Kubectl
Kubectl should be installed when enabling Kubernetes. Verify kubectl is properly installed by issuing `kubectl version`.

Output should be something like:
```bash
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.0", GitCommit:"641856db18352033a0d96dbc99153fa3b27298e5", GitTreeState:"clean", BuildDate:"2019-03-26T00:04:52Z", GoVersion:"go1.12.1", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"10", GitVersion:"v1.10.11", GitCommit:"637c7e288581ee40ab4ca210618a89a555b6e7e9", GitTreeState:"clean", BuildDate:"2018-11-26T14:25:46Z", GoVersion:"go1.9.3", Compiler:"gc", Platform:"linux/amd64"}
```

You can also install `kubectl` using the instructions on the [Kubernetes documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl).

#### (Optional) Shell autocompletion
If you want to enable shell autocompletion, you need to run the steps described [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion).

#### Access
Verify that you have gained access to local Kubernetes, and that everything is ready for the next steps:
```bash
$ kubectl get pods
No resources found.
```

The command uses config written to file, default `$HOME/.kube/config`, you can take a look at it if you're curious.

#### Load balancer

To be able to use ingress locally with Kubernetes for Docker, we need to run a load balancer. Run the following command, and it will (with some magic) start Nginx and use that as the load balancer.
```bash
curl https://raw.githubusercontent.com/navikt/codelabs/master/k8s-nais-tutorial/loadbalancer.yaml | kubectl apply -f -
```

After the course, you can take a look at the `loadbalancer.yaml` to see more of how this is set up.

PS: This will not work if you have other softwars listening to 80/433.

#### Naiserator

Naiserator is a Kubernetes operator that handles the lifecycle of the CustomResource called nais.io/Application. The main goal of Naiserator is to simplify application deployment by providing a high-level abstraction tailored for the NAIS-platform.

Apply the following file to your cluster to start the Naiserator operator.
```
kind: Deployment
apiVersion: apps/v1
metadata:
  name: naiserator
  labels:
    app: naiserator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: naiserator
  template:
    metadata:
      labels:
        app: naiserator
    spec:
      containers:
      - name: naiserator
        image: navikt/naiserator:2019-05-24-6b0f733
        imagePullPolicy: Always
        env:
          - name: ACCESS_POLICY_ENABLED
            value: "false"
          - name: NAIS_CLUSTER_NAME
            value: docker-for-desktop
          - name: NAIS_VAULT_ENABLED
            value: "false"
          - name: CERTIFICATE_AUTHORITY_ENABLED
            value: "false"
```

After this we need to apply the Application CustomResourceDefinition.

```
curl https://raw.githubusercontent.com/nais/naiserator/master/pkg/apis/naiserator/v1alpha1/application.yaml | k apply -f -
```

## NAIS
Duration: 5:00

Write file: `app.yaml` with contents:
```
apiVersion: nais.io/v1alpha1
kind: Application
metadata:
  name: <YOUR_APP>
  labels:
    team: workshop
spec:
  image: gcr.io/google-containers/echoserver:1.10
  port: 8080
  liveness:
    path: /
  readiness:
    path: /
  env:
    - name: ENV_NAME
      value: "value"
  ingresses: 
    - "https://<YOUR_APP>.127.0.0.1.xip.io"
```

```
kubectl apply -f app.yaml
```

Take a look at the resources that gets created:

```
kubectl get all -l app=YOUR_APP
```

This command will output all recources that is labeled by `app=YOUR_APP`. You might need to run this a couple of times to see everthing.

### Visit your app

Run a new curl to see that your app is running:

```bash
curl http://<YOUR_APP>.127.0.0.1.xip.iox
```

### Naiserator

Check out the file [naiserator-max.yaml](https://github.com/nais/naiserator/blob/master/examples/nais-max.yaml) to see all features and possibilities provided by naiserator.

## Clean-up
Duration 1:00

You can delete your app by running:

```
kubectl delete application YOUR_APP
```

## Further reading

Check out the NAIS documentation at [https://nais.io/doc](https://nais.io/doc).
