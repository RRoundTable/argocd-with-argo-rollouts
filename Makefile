PROFILE_NAME=example
CLSUTER_OPTION=driver=docker --profile $(PROFILE_NAME) --nodes 3 --cpus=2 --memory=1800MB

cluster:
	minikube start $(CLSUTER_OPTION)

node-limit:
	pass

argocd:
	kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl apply -f argocd-application-controller-clusterrolebinding.yaml
argocd-password:
	bash -x update-argocd-password.sh
argo-rollouts:
	kubectl apply -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
	kubectl apply -f argo-rollouts-clusterrolebinding.yaml
port-forward:
	kubectl port-forward svc/argocd-server 8080:443 --address 0.0.0.0

finalize:
	minikube delete -p $(PROFILE_NAME)
