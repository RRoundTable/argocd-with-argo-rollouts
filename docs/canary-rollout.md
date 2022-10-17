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

Check `rollout-bluegreen`

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
Status:          ◌ Progressing
Message:         old replicas are pending termination
Strategy:        Canary
  Step:          4/8
  SetWeight:     60
  ActualWeight:  50
Images:          argoproj/rollouts-demo:blue (stable)
                 argoproj/rollouts-demo:yellow (canary)
Replicas:
  Desired:       2
  Current:       3
  Updated:       2
  Ready:         2
  Available:     2

NAME                                        KIND        STATUS               AGE    INFO
⟳ rollout-canary                            Rollout     ◌ Progressing        7m16s
├──# revision:2
│  └──⧉ rollout-canary-59dcc859bd           ReplicaSet  ◌ Progressing        5m39s  canary
│     ├──□ rollout-canary-59dcc859bd-4sh55  Pod         ✔ Running            5m39s  ready:1/1
│     └──□ rollout-canary-59dcc859bd-sln82  Pod         ◌ ContainerCreating  15s    ready:0/1
└──# revision:1
   └──⧉ rollout-canary-65ccbcd464           ReplicaSet  ✔ Healthy            7m16s  stable
      └──□ rollout-canary-65ccbcd464-m5xff  Pod         ✔ Running            7m16s  ready:1/1
```

After a about 40s,

```
Name:            rollout-canary
Namespace:       default
Status:          ✔ Healthy
Strategy:        Canary
  Step:          8/8
  SetWeight:     100
  ActualWeight:  100
Images:          argoproj/rollouts-demo:yellow (stable)
Replicas:
  Desired:       2
  Current:       2
  Updated:       2
  Ready:         2
  Available:     2

NAME                                        KIND        STATUS        AGE    INFO
⟳ rollout-canary                            Rollout     ✔ Healthy     8m51s
├──# revision:2
│  └──⧉ rollout-canary-59dcc859bd           ReplicaSet  ✔ Healthy     7m14s  stable
│     ├──□ rollout-canary-59dcc859bd-4sh55  Pod         ✔ Running     7m14s  ready:1/1
│     └──□ rollout-canary-59dcc859bd-sln82  Pod         ✔ Running     110s   ready:1/1
└──# revision:1
   └──⧉ rollout-canary-65ccbcd464           ReplicaSet  • ScaledDown  8m51s

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
