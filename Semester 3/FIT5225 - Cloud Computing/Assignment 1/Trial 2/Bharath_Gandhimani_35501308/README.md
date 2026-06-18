# CloudEco Wildlife Detection API

**FIT5225 Cloud Computing — Assignment 1**
**Model 4: Wildlife Detection (YOLOv8l-ONNX)**
**Student:** Bharath Gandhimani | **ID:** 35501308

---

## Live Deployment

The API is deployed on a 3-node Kubernetes cluster (GCP, australia-southeast2 — Melbourne):

```
http://34.129.108.113:30503
```

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/readyz` | GET | Readiness probe — returns `{"status":"ready"}` when model is loaded |
| `/healthz` | GET | Liveness probe — returns `{"status":"alive"}` |
| `/api/predict` | POST | Run YOLO inference, return JSON detections |
| `/api/annotate` | POST | Run YOLO inference, return base64 annotated image |
| `/docs` | GET | Interactive Swagger UI |

---

## Quick Test

```bash
# Check API is ready
curl http://34.129.108.113:30503/readyz

# Run inference on a test image
python3 - <<'EOF'
import base64, requests, json

with open("DATA/IMAGES/test_images/zebra_1.jpg", "rb") as f:
    image_b64 = base64.b64encode(f.read()).decode("utf-8")

payload = {"uuid": "test-001", "image": image_b64}
response = requests.post("http://34.129.108.113:30503/api/predict", json=payload)
print(json.dumps(response.json(), indent=2))
EOF
```

---

## Project Structure

```
wildlife-yolo-detector/
├── app/
│   ├── main.py          # FastAPI application, async concurrency with ThreadPoolExecutor
│   ├── model.py         # YOLOv8l-ONNX inference engine with image decode cache
│   └── schemas.py       # Pydantic request/response models
├── terraform/           # IaC — provisions GCP VMs + Kubernetes cluster end-to-end
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── scripts/
│       ├── common.sh    # containerd + kubeadm install (all nodes)
│       ├── master.sh    # kubeadm init + Flannel CNI
│       └── worker.sh    # kubeadm join
├── deployment.yaml      # Kubernetes Deployment manifest (1 vCPU limit, probes)
├── service.yaml         # Kubernetes NodePort Service (port 30503)
├── locustfile.py        # Locust load generation script
├── Dockerfile           # Multi-stage build, non-root user, CPU-only PyTorch
├── requirements.txt
└── yolov8l.onnx         # ONNX-exported model weights
```

---

## Running Locally

```bash
# 1. Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Start the API server
uvicorn app.main:app --host 0.0.0.0 --port 8000

# 4. Run smoke tests (in a separate terminal)
python test_local.py DATA/IMAGES/test_images/zebra_1.jpg
```

---

## Docker

```bash
# Pull and run the pre-built image
docker pull bgan0012/wildlife-yolo-detector:v3
docker run --rm -p 8000:8000 bgan0012/wildlife-yolo-detector:v3

# Build from source
docker build --no-cache --platform linux/amd64 \
  -t bgan0012/wildlife-yolo-detector:v3 .
docker push bgan0012/wildlife-yolo-detector:v3
```

---

## Kubernetes Cluster Setup (IaC)

The entire infrastructure — firewall rules, static IPs, VMs, and K8s cluster bootstrap — is provisioned with a single command:

```bash
cd terraform/
terraform init
terraform apply
```

This runs `common.sh` (containerd + kubeadm) on all nodes, `master.sh` (kubeadm init + Flannel CNI) on the master, fetches the join token, and runs `worker.sh` on both workers. The full cluster is ready in approximately 15-20 minutes.

**Prerequisites:**
- Terraform >= 1.5.0
- GCP credentials configured (`gcloud auth application-default login`)
- SSH key at `~/.ssh/fit5225_oci`
- `terraform.tfvars` populated with your SSH public key

---

## Deploying to Kubernetes

```bash
# Copy manifests to master node
scp -i ~/.ssh/fit5225_oci deployment.yaml service.yaml ubuntu@34.129.108.113:~/

# SSH into master and apply
ssh -i ~/.ssh/fit5225_oci ubuntu@34.129.108.113
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Watch pods come up (takes ~90 seconds due to readiness probe)
kubectl get pods -w

# Scale replicas for benchmarking
kubectl scale deployment wildlife-detector --replicas=2
kubectl scale deployment wildlife-detector --replicas=4
kubectl scale deployment wildlife-detector --replicas=8
```

---

## Load Testing (Locust)

```bash
# Install Locust
pip install locust pillow

# Run benchmark against the live cluster
TEST_IMAGE_PATH="DATA/IMAGES/test_images/zebra_1.jpg" \
  locust -f locustfile.py --host http://34.129.108.113:30503

# Open http://localhost:8089 to control the test
```

---

## Architecture Notes

- **Non-blocking inference:** YOLO is CPU-bound. All inference is offloaded to a `ThreadPoolExecutor(max_workers=1)` via `loop.run_in_executor()`, preventing event-loop blocking under concurrent load.
- **ONNX Runtime:** YOLOv8l exported to ONNX for 3-5x CPU speedup over native PyTorch.
- **Input normalisation:** All images are resized server-side to 480×480 before inference, regardless of original dimensions.
- **Multi-stage Docker build:** Builder stage compiles dependencies; runtime stage copies only the installed packages, keeping the final image lean.
- **Non-root container:** Runs as `appuser` (UID 1001) for security compliance.
- **Readiness/Liveness probes:** Traffic is only routed to pods that have fully loaded the ONNX model weights (`/readyz` returns 200 only after model load completes).
