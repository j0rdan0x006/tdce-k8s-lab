# TDCE-K8s-Lab
Threat-Driven Chaos Engineering for Kubernetes — local KinD lab with Falco, Prometheus, Grafana, Chaos Mesh, and CALDERA.

## What’s inside
- Multi-node KinD cluster (`kind-config.yaml`)
- Demo app (Nginx) for load/attack target
- Falco runtime detection with custom rules (PrivEsc, Lateral, Persistence)
- Prometheus + Grafana with auto dashboards (resources, Falco, chaos impact)
- Chaos Mesh experiments (pod-kill, network-delay, cpu-stress)
- CALDERA adversary emulation (ATT&CK T1610, T1046)
- Chaos events Prometheus exporter (timeline markers)
- Makefile + GitHub Actions CI

## Prereqs
- Docker, kubectl, kind, helm, (jq recommended)

## Quickstart
```bash
# 1) Cluster
make kind-up

# 2) Monitoring + Falco + RBAC + demo app + exporter
make deploy-base

# 3) Install Chaos Mesh CRDs/controllers
make install-chaos-mesh

# 4) (Optional) CALDERA adversary server
make deploy-caldera

# 5) Run chaos experiments (auto marks timeline in Prometheus)
make run-experiments
