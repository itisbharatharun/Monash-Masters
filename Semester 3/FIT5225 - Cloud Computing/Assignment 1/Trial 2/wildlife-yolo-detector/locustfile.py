"""
locustfile.py — CloudEco Wildlife Detection load testing script.

Usage:
    locust -f locustfile.py --host http://<NODE_IP>:30503

Then open http://localhost:8089 in your browser to control the test.

Test protocol:
    Run separate experiments for 1, 2, 4, and 8 pod replicas.
    Gradually increase concurrent users until the system reaches its
    breaking point — defined as the threshold at which response times
    degrade exponentially or HTTP 500/503 errors begin to occur.
    Record the maximum stable concurrent users and average response time.

Image pre-processing:
    Images are resized to 480×480 before base64 encoding, matching the
    server-side INFER_SIZE. This reduces payload size and ensures the
    Locust client is not the bottleneck due to large image transfers.
    The image is encoded once at module load and shared across all users.
"""

import base64
import io
import os
import uuid

from locust import HttpUser, between, constant, task
from PIL import Image as PILImage

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
TEST_IMAGE_PATH = os.environ.get(
    "TEST_IMAGE_PATH",
    "DATA/IMAGES/test_images/zebra_1.jpg",
)

INFER_SIZE = 480   # must match server-side INFER_SIZE env var


def _load_and_encode(path: str) -> str:
    """Load, resize, and base64-encode the test image once at startup."""
    img = PILImage.open(path).convert("RGB")
    img = img.resize((INFER_SIZE, INFER_SIZE), PILImage.LANCZOS)
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=85)
    return base64.b64encode(buf.getvalue()).decode("utf-8")


# Pre-encoded once — all simulated users share this to avoid client bottleneck
_B64_IMAGE: str = _load_and_encode(TEST_IMAGE_PATH)


# ---------------------------------------------------------------------------
# Locust user definition
# ---------------------------------------------------------------------------

class WildlifeAPIUser(HttpUser):
    """
    Simulates a client that continuously sends wildlife images to the API.
    Each virtual user:
      1. Generates a fresh UUID per request.
      2. Calls /api/predict (weighted 2x) and /api/annotate (weighted 1x).
      3. Validates the HTTP 200 response structure.
    """

    wait_time = constant(0)

    def _payload(self) -> dict:
        return {"uuid": str(uuid.uuid4()), "image": _B64_IMAGE}

    @task(2)
    def predict(self):
        """POST to /api/predict — primary inference endpoint."""
        with self.client.post(
            "/api/predict",
            json=self._payload(),
            catch_response=True,
            name="/api/predict",
        ) as response:
            if response.status_code == 200:
                data = response.json()
                if "count" not in data or "boxes" not in data:
                    response.failure("Response missing required fields")
                else:
                    response.success()
            else:
                response.failure(
                    f"Unexpected status {response.status_code}: {response.text[:200]}"
                )

    @task(1)
    def annotate(self):
        """POST to /api/annotate — annotation pipeline."""
        with self.client.post(
            "/api/annotate",
            json=self._payload(),
            catch_response=True,
            name="/api/annotate",
        ) as response:
            if response.status_code == 200:
                data = response.json()
                if "image" not in data or not data["image"]:
                    response.failure("Annotated image missing from response")
                else:
                    response.success()
            else:
                response.failure(
                    f"Unexpected status {response.status_code}: {response.text[:200]}"
                )
