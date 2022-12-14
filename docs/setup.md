
## Setup


### Build Cluster

Build minikube cluster with 3 nodes.

```
make cluster
```

```
minikube start driver=docker --profile example --nodes 3 --cpus=2 --memory=1800MB
π  [example] Darwin 12.1 (arm64) μ minikube v1.26.0
β¨  μλμ μΌλ‘ docker λλΌμ΄λ²κ° μ νλμμ΅λλ€

β  Docker Desktop only has 7851MiB available, you may encounter application deployment failures.
π‘  κΆμ₯:

    1. Click on "Docker for Desktop" menu icon
    2. Click "Preferences"
    3. Click "Resources"
    4. Increase "Memory" slider bar to 2.25 GB or higher
    5. Click "Apply & Restart"
π  λ¬Έμ: https://docs.docker.com/docker-for-mac/#resources

π  Using Docker Desktop driver with root privileges
π  example ν΄λ¬μ€ν°μ example μ»¨νΈλ‘€ νλ μΈ λΈλλ₯Ό μμνλ μ€
π  λ² μ΄μ€ μ΄λ―Έμ§λ₯Ό λ€μ΄λ°λ μ€ ...
π₯  Creating docker container (CPUs=2, Memory=1800MB) ...
π³  μΏ λ²λ€ν°μ€ v1.24.1 μ Docker 20.10.17 λ°νμμΌλ‘ μ€μΉνλ μ€
    βͺ μΈμ¦μ λ° ν€λ₯Ό μμ±νλ μ€ ...
    βͺ μ»¨νΈλ‘€ νλ μΈμ΄ λΆν...
    βͺ RBAC κ·μΉμ κ΅¬μ±νλ μ€ ...
π  Configuring CNI (Container Networking Interface) ...
π  Kubernetes κ΅¬μ± μμλ₯Ό νμΈ...
    βͺ Using image gcr.io/k8s-minikube/storage-provisioner:v5
π  μ λμ¨ νμ±ν : storage-provisioner, default-storageclass

π  Starting worker node example-m02 in cluster example
π  λ² μ΄μ€ μ΄λ―Έμ§λ₯Ό λ€μ΄λ°λ μ€ ...
π₯  Creating docker container (CPUs=2, Memory=1800MB) ...
π  λ€νΈμν¬ μ΅μμ μ°Ύμμ΅λλ€
    βͺ NO_PROXY=192.168.58.2
π³  μΏ λ²λ€ν°μ€ v1.24.1 μ Docker 20.10.17 λ°νμμΌλ‘ μ€μΉνλ μ€
    βͺ env NO_PROXY=192.168.58.2
π  Kubernetes κ΅¬μ± μμλ₯Ό νμΈ...

π  Starting worker node example-m03 in cluster example
π  λ² μ΄μ€ μ΄λ―Έμ§λ₯Ό λ€μ΄λ°λ μ€ ...
π₯  Creating docker container (CPUs=2, Memory=1800MB) ...
π  λ€νΈμν¬ μ΅μμ μ°Ύμμ΅λλ€
    βͺ NO_PROXY=192.168.58.2,192.168.58.3
π³  μΏ λ²λ€ν°μ€ v1.24.1 μ Docker 20.10.17 λ°νμμΌλ‘ μ€μΉνλ μ€
    βͺ env NO_PROXY=192.168.58.2
    βͺ env NO_PROXY=192.168.58.2,192.168.58.3
π  Kubernetes κ΅¬μ± μμλ₯Ό νμΈ...
π  λλ¬μ΅λλ€! kubectlμ΄ "example" ν΄λ¬μ€ν°μ "default" λ€μμ€νμ΄μ€λ₯Ό κΈ°λ³Έμ μΌλ‘ μ¬μ©νλλ‘ κ΅¬μ±λμμ΅λλ€.
```

Check K8s nodes

```
kubectl get nodes
```

Cluster is Ready with 3 nodes.

```
NAME          STATUS   ROLES           AGE    VERSION
example       Ready    control-plane   115s   v1.24.1
example-m02   Ready    <none>          79s    v1.24.1
example-m03   Ready    <none>          47s    v1.24.1
```

### Deploy ArgoCD

Deploy ArgoCD

```
make argocd
```

Check ArgoCD Pods.

```
kubectl get pod
```

```
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          89s
argocd-applicationset-controller-677774f99d-gc9gj   1/1     Running   0          89s
argocd-dex-server-7d897b85b-z2zjq                   1/1     Running   0          89s
argocd-notifications-controller-75ff767c89-jwjnm    1/1     Running   0          89s
argocd-redis-5dff748d9c-zwpvh                       1/1     Running   0          89s
argocd-repo-server-5bd47f8b96-tq5dv                 1/1     Running   0          89s
argocd-server-76797bdd8f-pwp7j                      1/1     Running   0          89s
```

Run port-forwarding to argocd server. `localhost:8080` is connected to `svc/argocd-server`

```
make port-forward
```

Change ArgoCd password to be `rootadmin`

```
make argocd-password
```

NOTE: If you want to private repository, check [Private Repositories](https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories/)


### Deploy Argo Rollouts

Deploy argo-rollouts

```
make argo-rollouts
```

Check argo-rollouts pod is running.
```
kubectl get pod
```

```
NAME                                                READY   STATUS    RESTARTS   AGE
argo-rollouts-76fcfc8d7f-j8ppw                      0/1     Running   0          44s
```

