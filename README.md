# argocd-with-argo-rollouts

Blue-Green, Canary Deployment with ArgoCD

## Prerequisite
- CPU: 2 * 3, Memory: 1800MB * 3
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/)
- [ArgoCD Kubectl Plugin](https://argoproj.github.io/argo-rollouts/installation/#kubectl-plugin-installation)

## Setup

[setup](docs/setup.md)

## BlueGreen Rollout

[bluegreen-rollout](docs/bluegreen-rollout.md)

## Canary Rollout

[canary-rollout](docs/canary-rollout.md)

## Finalize

Delete minikube cluster.

```
make finalize
```
