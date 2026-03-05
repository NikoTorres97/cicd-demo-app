#!/bin/bash

## namspaces

MONITORING_NAMESPACE="monitoring"
JENKINS_NAMESPACE="jenkins"
DEPLOYMENT_NAMESPACE=$1

## services

PROMETHEUS_SERVICE="myprom-prometheus-server"
PROMETHEUS_PORT=9090

GRAFANA_PORT=3000
GRAFANA_USER=admin


JENKINS_PORT=8080

## PIDS

PIDS=()

cleanup() {
    echo "Caught signal, killing processes..."
    for pid in "${PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then # Check if process is still running
            kill "$pid" # Send SIGTERM
        fi
    done
    # Optional: use 'kill -- -$$' to kill the whole process group
    exit 0
}

echo "Instalando Ingress-nginx"

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace

echo "Creando namespace '$MONITORING_NAMESPACE'"

kubectl create namespace $MONITORING_NAMESPACE

echo "namespace '$MONITORING_NAMESPACE' creado"


echo "Creando namespace '$JENKINS_NAMESPACE'"

kubectl create namespace $JENKINS_NAMESPACE

echo "namespace '$JENKINS_NAMESPACE' creado"


echo "Creando namespace '$DEPLOYMENT_NAMESPACE'"

kubectl create namespace $DEPLOYMENT_NAMESPACE

echo "namespace '$DEPLOYMENT_NAMESPACE' creado"

## Instalación de prometheus

echo "Instalndo Prometheus"

helm install myprom prometheus-community/prometheus --version=26.0.1 --create-namespace --namespace=monitoring  --values=k8s/prometheus/values.yaml

echo "Exponiendo Prometheus en $PROMETHEUS_PORT"

kubectl get pods --namespace $MONITORING_NAMESPACE -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=myprom" -o jsonpath="{.items[0].metadata.name}" & 
PROMETHEUS_POD=$!

kubectl --namespace $MONITORING_NAMESPACE port-forward $PROMETHEUS_POD $PROMETHEUS_PORT &
PROMETHEUS_PORT_FORWARD_PID=$!

PIDS+=($PROMETHEUS_PORT_FORWARD_PID)

echo "Exponiendo Prometheus en 127.0.0.1:$PROMETHEUS_PORT"

## Instalación de grafana

echo "Instalndo Grafana"

helm install grafana ./k8s/grafana --namespace $MONITORING_NAMESPACE


kubectl get pods --namespace $MONITORING_NAMESPACE -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}" &
GRAFANA_POD=$!

kubectl --namespace $MONITORING_NAMESPACE port-forward $GRAFANA_POD $GRAFANA_PORT &
GRAFANA_PORT_FORWARD_PID=$!

PIDS+=($GRAFANA_PORT_FORWARD_PID)

kubectl -n $MONITORING_NAMESPACE get secret grafana -o jsonpath="{.data.admin-password}" | base64 -d &
GRAFANA_PASS=$!

echo "Exponiendo Grafana en 127.0.0.1:$GRAFANA_PORT"
echo "Exponiendo credenciales de Grafana usuario:$GRAFANA_USER pass:$GRAFANA_PASS"

## Instalación de Jenkins

echo "Instalndo Jenkins"

helm install jenkins ./k8s/jenkins --namespace $JENKINS_NAMESPACE --create-namespace

kubectl get pods --namespace $JENKINS_NAMESPACE -l "app.kubernetes.io/name=jenkins,app.kubernetes.io/instance=jenkins" -o jsonpath="{.items[0].metadata.name}" &
JENKINS_POD=$!

kubectl --namespace $JENKINS_NAMESPACE port-forward $JENKINS_POD $JENKINS_PORT &
JENKINS_PORT_FORWARD_PID=$!

PIDS+=($JENKINS_PORT_FORWARD_PID)

echo "Exponiendo JENKINS en 127.0.0.1:$JENKINS_PORT"

# Trap signals (like Ctrl+C) to kill the background process
trap cleanup SIGINT SIGTERM SIGHUP EXIT

echo "Script running. Press Ctrl+C to stop all processes."
wait -n "${PIDS[@]}"