# argocd-with-argo-rollouts

Blue-Green, Canary Deployment with ArgoCD

## Prerequisite
- CPU: 2 * 3, Memory: 1800MB * 3
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/)
- [ArgoCD Kubectl Plugin](https://argoproj.github.io/argo-rollouts/installation/#kubectl-plugin-installation)


## Setup

Build minikube cluster with 3 nodes.

```
make cluster
```

```
minikube start driver=docker --profile example --nodes 3 --cpus=2 --memory=1800MB
😄  [example] Darwin 12.1 (arm64) 의 minikube v1.26.0
✨  자동적으로 docker 드라이버가 선택되었습니다

⛔  Docker Desktop only has 7851MiB available, you may encounter application deployment failures.
💡  권장:

    1. Click on "Docker for Desktop" menu icon
    2. Click "Preferences"
    3. Click "Resources"
    4. Increase "Memory" slider bar to 2.25 GB or higher
    5. Click "Apply & Restart"
📘  문서: https://docs.docker.com/docker-for-mac/#resources

📌  Using Docker Desktop driver with root privileges
👍  example 클러스터의 example 컨트롤 플레인 노드를 시작하는 중
🚜  베이스 이미지를 다운받는 중 ...
🔥  Creating docker container (CPUs=2, Memory=1800MB) ...
🐳  쿠버네티스 v1.24.1 을 Docker 20.10.17 런타임으로 설치하는 중
    ▪ 인증서 및 키를 생성하는 중 ...
    ▪ 컨트롤 플레인이 부팅...
    ▪ RBAC 규칙을 구성하는 중 ...
🔗  Configuring CNI (Container Networking Interface) ...
🔎  Kubernetes 구성 요소를 확인...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  애드온 활성화 : storage-provisioner, default-storageclass

👍  Starting worker node example-m02 in cluster example
🚜  베이스 이미지를 다운받는 중 ...
🔥  Creating docker container (CPUs=2, Memory=1800MB) ...
🌐  네트워크 옵션을 찾았습니다
    ▪ NO_PROXY=192.168.58.2
🐳  쿠버네티스 v1.24.1 을 Docker 20.10.17 런타임으로 설치하는 중
    ▪ env NO_PROXY=192.168.58.2
🔎  Kubernetes 구성 요소를 확인...

👍  Starting worker node example-m03 in cluster example
🚜  베이스 이미지를 다운받는 중 ...
🔥  Creating docker container (CPUs=2, Memory=1800MB) ...
🌐  네트워크 옵션을 찾았습니다
    ▪ NO_PROXY=192.168.58.2,192.168.58.3
🐳  쿠버네티스 v1.24.1 을 Docker 20.10.17 런타임으로 설치하는 중
    ▪ env NO_PROXY=192.168.58.2
    ▪ env NO_PROXY=192.168.58.2,192.168.58.3
🔎  Kubernetes 구성 요소를 확인...
🏄  끝났습니다! kubectl이 "example" 클러스터와 "default" 네임스페이스를 기본적으로 사용하도록 구성되었습니다.
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
