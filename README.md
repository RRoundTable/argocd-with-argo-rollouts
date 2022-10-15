# argocd-with-argo-rollouts

Blue-Green, Canary Deployment with ArgoCD

## Prerequisite
- CPU: 2 * 3, Memory: 1800MB * 3
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/)
- [ArgoCD Kubectl Plugin](https://argoproj.github.io/argo-rollouts/installation/#kubectl-plugin-installation)


## Setup


### Build Cluster

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

Start minikube Tunneling

```
make tunnel
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

### Add a New Application on ArgoCD

Create blue-green-rollout aaplication

```
argocd app create blue-green-rollouts --repo https://github.com/RRoundTable/argocd-with-argo-rollouts --path blue-green-rollouts --dest-server https://kubernetes.default.svc --dest-namespace default
```

```
argocd app sync blue-green-rollouts
```

Get `blue-green-rollouts` info

```
kubectl argo rollouts get rollouts rollout-bluegreen
```

```
Namespace:       default
Status:          ✔ Healthy
Strategy:        BlueGreen
Images:          argoproj/rollouts-demo:blue (stable, active)
Replicas:
  Desired:       2
  Updated:       2
  Ready:         2
  Available:     2

NAME                                           KIND        STATUS     AGE  INFO
⟳ rollout-bluegreen                            Rollout     ✔ Healthy  34s
└──# revision:1
   └──⧉ rollout-bluegreen-5ffd47b8d4           ReplicaSet  ✔ Healthy  34s  stable,active
      ├──□ rollout-bluegreen-5ffd47b8d4-kndt5  Pod         ✔ Running  34s  ready:1/1
      └──□ rollout-bluegreen-5ffd47b8d4-qvnd7  Pod         ✔ Running  34s  ready:1/1
```

Check application on `localhost:8080` (ArgoCD)

<img width="700" alt="image" src="https://user-images.githubusercontent.com/27891090/195973381-4d98d19f-c9a3-46c7-9aa3-56577f31e6ad.png">



Check bluegreen svcs are created.

```
kubectl get svc
```

```
rollout-bluegreen-active                  ClusterIP   10.97.32.117    <none>        80/TCP                       8m11s
rollout-bluegreen-preview                 ClusterIP   10.98.88.89     <none>        80/TCP                       8m11s
```



Check `rollout-bluegreen-active`

```
kubectl port-forward svc/rollout-bluegreen-active 3080:80
```
<img width="500" alt="image" src="https://user-images.githubusercontent.com/27891090/195973327-5c0c089c-2d67-4daa-a383-453d2c67c9b3.png">

`rollout-bluegreen-preview`

```
kubectl port-forward svc/rollout-bluegreen-preview 3080:80
```

<img width="500" alt="image" src="https://user-images.githubusercontent.com/27891090/195973327-5c0c089c-2d67-4daa-a383-453d2c67c9b3.png">

`rollout-bluegreen-preview` and `rollout-bluegreen-active` are same because no rollout occurs.

## Rollout

Rollout with image update.

```
kubectl argo rollouts set image rollout-bluegreen rollouts-demo=argoproj/rollouts-demo:yellow
```



Check `rollout-bluegreen`

```
kubectl argo rollouts get rollouts rollout-bluegreen
```

```
Name:            rollout-bluegreen
Namespace:       default
Status:          ॥ Paused
Message:         BlueGreenPause
Strategy:        BlueGreen
Images:          argoproj/rollouts-demo:blue (stable, active)
                 argoproj/rollouts-demo:yellow (preview)
Replicas:
  Desired:       2
  Current:       4
  Updated:       2
  Ready:         2
  Available:     2

NAME                                           KIND        STATUS     AGE    INFO
⟳ rollout-bluegreen                            Rollout     ॥ Paused   30h
├──# revision:6
│  └──⧉ rollout-bluegreen-674b45d9b4           ReplicaSet  ✔ Healthy  30h    preview
│     ├──□ rollout-bluegreen-674b45d9b4-nwbsn  Pod         ✔ Running  58s    ready:1/1
│     └──□ rollout-bluegreen-674b45d9b4-pc5k9  Pod         ✔ Running  58s    ready:1/1
└──# revision:5
   └──⧉ rollout-bluegreen-5ffd47b8d4           ReplicaSet  ✔ Healthy  30h    stable,active
      ├──□ rollout-bluegreen-5ffd47b8d4-5wjld  Pod         ✔ Running  9m58s  ready:1/1
      └──□ rollout-bluegreen-5ffd47b8d4-qwv2k  Pod         ✔ Running  9m58s  ready:1/1
```

And check pods, 4 pods are running(blue:2, green:2)

```
kubectl get pod | grep blueegreen
```

```
rollout-bluegreen-5ffd47b8d4-5wjld                  1/1     Running   0          11m
rollout-bluegreen-5ffd47b8d4-qwv2k                  1/1     Running   0          11m
rollout-bluegreen-674b45d9b4-nwbsn                  1/1     Running   0          2m1s
rollout-bluegreen-674b45d9b4-pc5k9                  1/1     Running   0          2m1s
```

Check Application on ArgoCD. As you can see APP Health is `Suspended` status.

<img width="800" alt="image" src="https://user-images.githubusercontent.com/27891090/195973659-56b07c17-e737-47d1-9c37-6d68b41be483.png">
