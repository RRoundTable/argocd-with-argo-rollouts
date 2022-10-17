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

Create canary-rollout aplication

```
argocd app create canary-rollouts --repo https://github.com/RRoundTable/argocd-with-argo-rollouts --path canary-rollouts --dest-server https://kubernetes.default.svc --dest-namespace default
```

```
argocd app sync canary-rollouts
```

Get `canary-rollouts` info

In our cluster, rollout max replicas is 3. So If we want to promote canary rollouts with replicas 3, we need to use `maxUnavailable`.

```
# canary-rollouts/rollout-canary.yaml

  strategy:
    canary:
      maxUnavailable: 40%
```


```
kubectl argo rollouts get rollouts rollout-canary
```

```
Namespace:       default
Status:          ॥ Paused
Message:         CanaryPauseStep
Strategy:        Canary
  Step:          1/4
  SetWeight:     33
  ActualWeight:  33
Images:          argoproj/rollouts-demo:blue (stable)
                 argoproj/rollouts-demo:yellow (canary)
Replicas:
  Desired:       3
  Current:       3
  Updated:       1
  Ready:         3
  Available:     3

NAME                                        KIND        STATUS     AGE    INFO
⟳ rollout-canary                            Rollout     ॥ Paused   5m31s
├──# revision:2
│  └──⧉ rollout-canary-59dcc859bd           ReplicaSet  ✔ Healthy  62s    canary
│     └──□ rollout-canary-59dcc859bd-rxnqh  Pod         ✔ Running  62s    ready:1/1
└──# revision:1
   └──⧉ rollout-canary-65ccbcd464           ReplicaSet  ✔ Healthy  5m31s  stable
      ├──□ rollout-canary-65ccbcd464-fftpr  Pod         ✔ Running  5m31s  ready:1/1
      └──□ rollout-canary-65ccbcd464-smdx9  Pod         ✔ Running  5m31s  ready:1/1vamespace:       default
Status:          ॥ Paused
Message:         CanaryPauseStep
Strategy:        Canary
  Step:          1/4
  SetWeight:     33
  ActualWeight:  33
Images:          argoproj/rollouts-demo:blue (stable)
                 argoproj/rollouts-demo:yellow (canary)
Replicas:
  Desired:       3
  Current:       3
  Updated:       1
  Ready:         3
  Available:     3

NAME                                        KIND        STATUS     AGE    INFO
⟳ rollout-canary                            Rollout     ॥ Paused   5m31s
├──# revision:2
│  └──⧉ rollout-canary-59dcc859bd           ReplicaSet  ✔ Healthy  62s    canary
│     └──□ rollout-canary-59dcc859bd-rxnqh  Pod         ✔ Running  62s    ready:1/1
└──# revision:1
   └──⧉ rollout-canary-65ccbcd464           ReplicaSet  ✔ Healthy  5m31s  stable
      ├──□ rollout-canary-65ccbcd464-fftpr  Pod         ✔ Running  5m31s  ready:1/1
      └──□ rollout-canary-65ccbcd464-smdx9  Pod         ✔ Running  5m31s  ready:1/1v
```

Check application on `localhost:8080` (ArgoCD)

<img width="800" alt="image" src="https://user-images.githubusercontent.com/27891090/196194366-315671b6-5556-4867-b33c-12fc58ce3432.png">

Check canary svcs are created.

```
kubectl get svc | grep canary
```

```
rollout-canary                            ClusterIP   10.100.101.114   <none>        80/TCP                       106s
```


## Rollout

Rollout with image update.

```
kubectl argo rollouts set image rollout-canary rollouts-demo=argoproj/rollouts-demo:yellow
```

Check `rollout-canary`. As you can see, the number of revision:1 pods is two and the number of revision:2 pod is one. Because `maxUnavailable` is `40%`, one of revision:1 pods can be shutdown and one pod of reivision:2 is created.

```
kubectl argo rollouts get rollouts canary
```

```
Name:            rollout-canary
Namespace:       default
Status:          ॥ Paused
Message:         CanaryPauseStep
Strategy:        Canary
  Step:          1/4
  SetWeight:     33
  ActualWeight:  33
Images:          argoproj/rollouts-demo:blue (stable)
                 argoproj/rollouts-demo:yellow (canary)
Replicas:
  Desired:       3
  Current:       3
  Updated:       1
  Ready:         3
  Available:     3

NAME                                        KIND        STATUS     AGE    INFO
⟳ rollout-canary                            Rollout     ॥ Paused   5m31s
├──# revision:2
│  └──⧉ rollout-canary-59dcc859bd           ReplicaSet  ✔ Healthy  62s    canary
│     └──□ rollout-canary-59dcc859bd-rxnqh  Pod         ✔ Running  62s    ready:1/1
└──# revision:1
   └──⧉ rollout-canary-65ccbcd464           ReplicaSet  ✔ Healthy  5m31s  stable
      ├──□ rollout-canary-65ccbcd464-fftpr  Pod         ✔ Running  5m31s  ready:1/1
      └──□ rollout-canary-65ccbcd464-smdx9  Pod         ✔ Running  5m31s  ready:1/1
```

Check Application on ArgoCD, `localhost:8080`

<img width="800" alt="image" src="https://user-images.githubusercontent.com/27891090/196196226-69d5ef19-eb99-4f87-bd7f-692ed0d7b289.png">



## Promote Rollout

Let's promte rollouts

```
kubectl argo rollouts promote rollout-canary
```

```
rollout 'rollout-canary' promoted
```

Check rollouts

```
kubectl argo rollouts get rollouts canary-rollout
```
```
Name:            rollout-canary
Namespace:       default
Status:          ॥ Paused
Message:         CanaryPauseStep
Strategy:        Canary
  Step:          3/4
  SetWeight:     66
  ActualWeight:  66
Images:          argoproj/rollouts-demo:blue (stable)
                 argoproj/rollouts-demo:yellow (canary)
Replicas:
  Desired:       3
  Current:       3
  Updated:       2
  Ready:         3
  Available:     3

NAME                                        KIND        STATUS     AGE    INFO
⟳ rollout-canary                            Rollout     ॥ Paused   2m55s
├──# revision:2
│  └──⧉ rollout-canary-59dcc859bd           ReplicaSet  ✔ Healthy  2m32s  canary
│     ├──□ rollout-canary-59dcc859bd-p9dr9  Pod         ✔ Running  2m32s  ready:1/1
│     └──□ rollout-canary-59dcc859bd-7k245  Pod         ✔ Running  15s    ready:1/1
└──# revision:1
   └──⧉ rollout-canary-65ccbcd464           ReplicaSet  ✔ Healthy  2m55s  stable
      └──□ rollout-canary-65ccbcd464-xrhw2  Pod         ✔ Running  2m55s  ready:1/1
```

In ArgoCD


<img width="800" alt="스크린샷 2022-10-17 오후 11 00 25" src="https://user-images.githubusercontent.com/27891090/196199653-5ef0c330-c8b8-4c5b-9f79-85203d01bc77.png">


After a about 40s,

```
Name:            rollout-canary
Namespace:       default
Status:          ◌ Progressing
Message:         updated replicas are still becoming available
Strategy:        Canary
  Step:          4/4
  SetWeight:     100
  ActualWeight:  100
Images:          argoproj/rollouts-demo:yellow (canary)
Replicas:
  Desired:       3
  Current:       3
  Updated:       3
  Ready:         2
  Available:     2

NAME                                        KIND        STATUS         AGE    INFO
⟳ rollout-canary                            Rollout     ◌ Progressing  3m34s
├──# revision:2
│  └──⧉ rollout-canary-59dcc859bd           ReplicaSet  ◌ Progressing  3m11s  canary
│     ├──□ rollout-canary-59dcc859bd-p9dr9  Pod         ✔ Running      3m11s  ready:1/1
│     ├──□ rollout-canary-59dcc859bd-7k245  Pod         ✔ Running      54s    ready:1/1
│     └──□ rollout-canary-59dcc859bd-5ldz4  Pod         ◌ Pending      0s     ready:0/1
└──# revision:1
   └──⧉ rollout-canary-65ccbcd464           ReplicaSet  • ScaledDown   3m34s  stable
      └──□ rollout-canary-65ccbcd464-xrhw2  Pod         ◌ Terminating  3m34s  ready:1/1
```

In ArgoCD

<img width="800" alt="스크린샷 2022-10-17 오후 11 01 06" src="https://user-images.githubusercontent.com/27891090/196199714-7924ff12-46ec-49f1-ad72-675fa170c34c.png">



## Delete `rollout-canary`

Delete ArgoCD Application `canary-rollouts`
```
argocd app delete canary-rollouts
```

Check pod

```
kubectl get pod | grep canary
```
