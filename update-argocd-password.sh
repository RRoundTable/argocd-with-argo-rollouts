password=$(kubectl get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd login localhost:8080 --username admin --password $password --insecure
argocd account update-password --current-password $password --new-password rootadmin


