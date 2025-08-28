#!/usr/bin/env bash
set -euo pipefail
OUTDIR="evaluation/logs"
mkdir -p "$OUTDIR"
echo "Collecting Falco logs..."
kubectl logs -l app=falco -n kube-system --tail=500 > "$OUTDIR/falco.log" || true
echo "Collecting events..."
kubectl get events -A --sort-by=.metadata.creationTimestamp > "$OUTDIR/events.txt"
echo "Saved to $OUTDIR"
