#!/usr/bin/env bash
set -euo pipefail

echo "Deploying demo app..."
kubectl apply -f manifests/demo-app.yaml
kubectl rollout status deploy/demo-nginx -n default

# Exporter events
EXPORTER="http://chaos-metrics-exporter.monitoring.svc.cluster.local:8080"

echo "Starting pod-kill..."
kubectl apply -f chaos/pod-kill.yaml
kubectl run curl --image=curlimages/curl -n monitoring --rm -i --restart=Never -- \
  curl -s -X POST ${EXPORTER}/start/pod-kill || true
sleep 35
kubectl run curl --image=curlimages/curl -n monitoring --rm -i --restart=Never -- \
  curl -s -X POST ${EXPORTER}/end/pod-kill || true

echo "Starting network-delay..."
kubectl apply -f chaos/network-delay.yaml
kubectl run curl --image=curlimages/curl -n monitoring --rm -i --restart=Never -- \
  curl -s -X POST ${EXPORTER}/start/network-delay || true
sleep 50
kubectl run curl --image=curlimages/curl -n monitoring --rm -i --restart=Never -- \
  curl -s -X POST ${EXPORTER}/end/network-delay || true

echo "Starting cpu-stress..."
kubectl apply -f chaos/cpu-stress.yaml
kubectl run curl --image=curlimages/curl -n monitoring --rm -i --restart=Never -- \
  curl -s -X POST ${EXPORTER}/start/cpu-stress || true
sleep 65
kubectl run curl --image=curlimages/curl -n monitoring --rm -i --restart=Never -- \
  curl -s -X POST ${EXPORTER}/end/cpu-stress || true

echo "Collecting logs/metrics..."
bash scripts/collect_logs.sh
bash scripts/export_metrics.sh
echo "Done."
