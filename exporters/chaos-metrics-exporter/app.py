from flask import Flask, request
from prometheus_client import Counter, Gauge, generate_latest, CONTENT_TYPE_LATEST
import time

app = Flask(__name__)

chaos_experiment_status = Gauge(
    "chaos_experiment_status",
    "Status of chaos experiment (1=running, 0=stopped)",
    ["experiment"]
)

chaos_experiment_events_total = Counter(
    "chaos_experiment_events_total",
    "Total chaos experiment events",
    ["experiment", "event"]
)

@app.post("/start/<experiment>")
def start_experiment(experiment):
    chaos_experiment_status.labels(experiment=experiment).set(1)
    chaos_experiment_events_total.labels(experiment=experiment, event="started").inc()
    return {"ok": True, "experiment": experiment, "state": "started", "t": time.time()}

@app.post("/end/<experiment>")
def end_experiment(experiment):
    chaos_experiment_status.labels(experiment=experiment).set(0)
    chaos_experiment_events_total.labels(experiment=experiment, event="ended").inc()
    return {"ok": True, "experiment": experiment, "state": "ended", "t": time.time()}

@app.get("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
