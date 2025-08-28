#!/usr/bin/env bash
set -euo pipefail
OUTDIR="evaluation/metrics"
mkdir -p "$OUTDIR"
PROM="http://localhost:31000"
echo "Exporting pod CPU..."
curl -s "$PROM/api/v1/query?query=rate(container_cpu_usage_seconds_total{pod=~\"demo-nginx.*\",container!=\"\"}[1m])" | jq . > "$OUTDIR/pod_cpu.json"
echo "Exporting pod memory..."
curl -s "$PROM/api/v1/query?query=container_memory_usage_bytes{pod=~\"demo-nginx.*\",container!=\"\"}" | jq . > "$OUTDIR/pod_mem.json"
echo "Exporting chaos statuses..."
curl -s "$PROM/api/v1/query?query=chaos_experiment_status" | jq . > "$OUTDIR/chaos_status.json"
echo "Done -> $OUTDIR"
