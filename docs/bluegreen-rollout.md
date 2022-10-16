## Add a New Application on ArgoCD

We will deploy rollouts with `podAntiAffinity` to limit rollout pod per one node.

```YAML
# blue-green-rollouts/rollout-bluegreen.yaml
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
          matchExpressions:
            - key: test
              operator: In
              values:
                - test
          topologyKey: "kubernetes.io/hostname"
```

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
  Current:       3
  Updated:       1
  Ready:         2
  Available:     2

NAME                                           KIND        STATUS     AGE  INFO
⟳ rollout-bluegreen                            Rollout     ॥ Paused   76s
├──# revision:2
│  └──⧉ rollout-bluegreen-5b88cddb5c           ReplicaSet  ✔ Healthy  14s  preview
│     └──□ rollout-bluegreen-5b88cddb5c-qhmdv  Pod         ✔ Running  14s  ready:1/1
└──# revision:1
   └──⧉ rollout-bluegreen-df8d78c45            ReplicaSet  ✔ Healthy  56s  stable,active
      ├──□ rollout-bluegreen-df8d78c45-dzpn2   Pod         ✔ Running  56s  ready:1/1
      └──□ rollout-bluegreen-df8d78c45-pcrr2   Pod         ✔ Running  56s  ready:1/1
```

In our cluster, rollout max replicas is 3. So If we want to promote bluegreen rollouts, the sum of the number of preveiw and active is 3.

So Set `previewReplicaCount` as 1. (Actice `replica` is 2)
```
# blue-green-rollouts/rollout-bluegreen.yaml
  previewReplicaCount: 1
```


And check pods, 3 pods are running(revision1:2, revision2:1)

```
kubectl get pod | grep blueegreen
```

```
rollout-bluegreen-5ffd47b8d4-5wjld                  1/1     Running   0          11m
rollout-bluegreen-5ffd47b8d4-qwv2k                  1/1     Running   0          11m
rollout-bluegreen-674b45d9b4-nwbsn                  1/1     Running   0          2m1s
```

Check Application on ArgoCD.

<img width="800" alt="image" src="https://user-images.githubusercontent.com/27891090/195986501-4400e91c-56df-4eea-884b-9bd6f0270895.png">

Check `rollout-bluegreen-active`

```
kubectl port-forward svc/rollout-bluegreen-active 3080:80
```
<img width="500" alt="image" src="https://user-images.githubusercontent.com/27891090/195973778-d2504718-4675-4dfe-a905-3647bbf51b7c.png">

`rollout-bluegreen-preview`

```
kubectl port-forward svc/rollout-bluegreen-preview 3080:80
```

<img width="500" alt="image" src="https://user-images.githubusercontent.com/27891090/195973756-2742fd1d-ef72-4afb-836c-36103d326170.png">

`rollout-bluegreen-preview` and `rollout-bluegreen-active` are not same because rollout occurs.

## Promote Rollout

NOTE: In our cluster, only 3 rollout pod can running. If we promote `rollout-bluegreen`, Additional `revision: 1` pod are created because replicas is set to 2. So there are 4 pods. 3 pods are running. 1 pod is pendding. So We have to set `maxUnavialble` to `50%`. It means during the update, 50% of desired pods can be unavailable.

```
# blue-green-rollouts
  maxUnavailable: 50%
```

Let's promte rollouts

```
kubectl argo rollouts promote rollout-bluegreen
```

```
rollout 'rollout-bluegreen' promoted
```

Check rollouts

```
kubectl argo rollouts get rollouts bluegreen-rollout
```
```
Name:            rollout-bluegreen
Namespace:       default
Status:          ✔ Healthy
Strategy:        BlueGreen
Images:          argoproj/rollouts-demo:yellow (stable, active)
Replicas:
  Desired:       2
  Current:       2
  Updated:       2
  Ready:         2
  Available:     2

NAME                                           KIND        STATUS     AGE   INFO
⟳ rollout-bluegreen                            Rollout     ✔ Healthy  2m
└──# revision:1
   └──⧉ rollout-bluegreen-5b88cddb5c           ReplicaSet  ✔ Healthy  111s  stable,active
      ├──□ rollout-bluegreen-5b88cddb5c-8fzbb  Pod         ✔ Running  111s  ready:1/1
      └──□ rollout-bluegreen-5b88cddb5c-j5dbh  Pod         ✔ Running  111s  ready:1/1
```
Check Pod, active pod is deleted and only preview pod is running.

```
kubectl get pod | grep bluegreen
```

```
rollout-bluegreen-674b45d9b4-nwbsn                  1/1     Running   0          12m
rollout-bluegreen-674b45d9b4-pc5k9                  1/1     Running   0          12m
```

Check Application on ArgoCD. As you can see APP Health is `Healthy` status.
<img width="800" alt="image" src="https://user-images.githubusercontent.com/27891090/195974275-f70135c4-06ad-4efb-b4a5-dbe6fc593c8c.png">



Check `rollout-bluegreen-active`

```
kubectl port-forward svc/rollout-bluegreen-active 3080:80
```
<img width="500" alt="image" src="https://user-images.githubusercontent.com/27891090/195974705-ac67079a-a3cd-496b-b6d6-08baa36d520a.png">

`rollout-bluegreen-preview`

```
kubectl port-forward svc/rollout-bluegreen-preview 3080:80
```
<img width="500" alt="image" src="https://user-images.githubusercontent.com/27891090/195974114-0cfeebe8-9e93-4198-949b-0ade3dbce520.png">

`rollout-bluegreen-preview` and `rollout-bluegreen-active` are same because rollout completed.


## Delete `rollout-bluegreen`

Delete ArgoCD Application `blue-green-rollouts`
```
argocd app delete blue-green-rollouts
```

Check pod

```
kubectl get pod | grep bluegreen
```
