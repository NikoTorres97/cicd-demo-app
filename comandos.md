## service POC
helm uninstall cicd-demo-app --namespace production
helm install cicd-demo-app ./k8s/cicd-demo-app --namespace production --create-namespace
helm upgrade cicd-demo-app ./k8s/cicd-demo-app --namespace production --create-namespace

## ingress controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace


## prometheus 

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install myprom prometheus-community/prometheus --version=26.0.1 --create-namespace --namespace=monitoring  --values=k8s/prometheus/values.yaml
helm upgrade myprom prometheus-community/prometheus --version=26.0.1 --create-namespace --namespace=monitoring  --values=k8s/prometheus/values.yaml
helm uninstall myprom -n monitoring

kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=myprom" -o jsonpath="{.items[0].metadata.name}"
kubectl --namespace monitoring port-forward myprom-prometheus-server-844f4dd86b-hb6bq 9090

kubectl --namespace monitoring port-forward myprom-prometheus-node-exporter-mnrwg  9100

## grafana

helm repo add grafana-community https://grafana-community.github.io/helm-charts
helm repo update

helm install grafana ./k8s/grafana --namespace monitoring
helm upgrade grafana ./k8s/grafana --namespace monitoring

kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}"


kubectl --namespace monitoring port-forward grafana-78f45b6469-rk24d 3000



### grafana credenciales

user: admin
#### get password -> m1DPep7vkW58CelhYnnlCGn9w1UckteZ0OuvLLTG
kubectl -n monitoring get secret grafana -o jsonpath="{.data.admin-password}" | base64 -d

helm uninstall grafana -n monitoring


kubectl run mycurlpod -n monitoring --image=curlimages/curl -i --tty --rm -- sh

curl --request GET --url 'http://myprom-prometheus-server:80/api/v1/query?query=container_memory_usage_bytes'

## Jekins

helm install jenkins ./k8s/jenkins --namespace jenkins --create-namespace

kubectl auth can-i list secrets --namespace production --as=system:serviceaccount:jenkins:default
