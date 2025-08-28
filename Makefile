CLUSTER_NAME=tdce-cluster
REGISTRY=chaos-metrics-exporter
EXPORTER_IMG=chaos-metrics-exporter:local

.PHONY: kind-up kind-down load-exporter build-exporter deploy-base deploy-falco deploy-monitoring deploy-caldera deploy-chaos deploy-demo exporter install-chaos-mesh run-experiments collect clean

kind-up:
	kind create cluster --name $(CLUSTER_NAME) --config=kind-config.yaml

kind-down:
	kind delete cluster --name $(CLUSTER_NAME)

build-exporter:
	docker build -t $(EXPORTER_IMG) exporters/chaos-metrics-exporter

load-exporter:
	kind load docker-image $(EXPORTER_IMG) --name $(CLUSTER_NAME)

exporter: build-exporter load-exporter
	kubectl apply -f manifests/chaos-metrics-exporter.yaml

deploy-base: deploy-monitoring deploy-falco exporter
	kubectl apply -f manifests/rbac.yaml
	kubectl apply -f manifests/networkpolicy.yaml
	kubectl apply -f manifests/demo-app.yaml

deploy-falco:
	kubectl apply -f manifests/falco-daemonset.yaml
	kubectl apply -f falco/

deploy-monitoring:
	kubectl apply -f manifests/prometheus-grafana.yaml

install-chaos-mesh:
	helm repo add chaos-mesh https://charts.chaos-mesh.org
	helm repo update
	helm upgrade --install chaos-mesh chaos-mesh/chaos-mesh -n chaos-testing --create-namespace --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock

deploy-chaos:
	kubectl apply -f chaos/

deploy-caldera:
	kubectl apply -f adversary/caldera-deployment.yaml

deploy-demo:
	kubectl apply -f manifests/demo-app.yaml

run-experiments:
	bash scripts/run_all.sh

collect:
	bash scripts/collect_logs.sh
	bash scripts/export_metrics.sh

clean:
	-kubectl delete -f adversary/ || true
	-kubectl delete -f chaos/ || true
	-kubectl delete -f falco/ || true
	-kubectl delete -f manifests/ || true
