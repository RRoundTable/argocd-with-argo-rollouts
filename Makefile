PROFILE_NAME=example
CLSUTER_OPTION=driver=docker --profile $(PROFILE_NAME) --nodes 3 --cpus=2 --memory=1800MB

cluster:
	minikube start $(CLSUTER_OPTION)

node-limit:
	pass

argocd:
	pass

argo-rollouts:
	pass

tunnel:
	minikube tunnel --profile=$(PROFILE_NAME)


