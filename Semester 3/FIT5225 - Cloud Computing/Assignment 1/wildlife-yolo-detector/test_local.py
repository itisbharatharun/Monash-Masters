#!/usr/bin/env python3
"""
test_local.py — Quick smoke-test for the CloudEco API running locally.

Run AFTER starting the server:
    uvicorn app.main:app --host 0.0.0.0 --port 8000

Then in a separate terminal:
    python test_local.py path/to/image.jpg
"""

import base64
import json
import sys
import uuid
import requests

API_BASE = "http://localhost:8000"


def encode_image(path: str) -> str:
    with open(path, "rb") as f:
        return base64.b64encode(f.read()).decode("utf-8")


def test_readiness():
    r = requests.get(f"{API_BASE}/readyz", timeout=10)
    print(f"[readyz] status={r.status_code}  body={r.json()}")
    assert r.status_code == 200, "Readiness probe failed — model not loaded yet"


def test_predict(image_path: str):
    payload = {"uuid": str(uuid.uuid4()), "image": encode_image(image_path)}
    r = requests.post(f"{API_BASE}/api/predict", json=payload, timeout=60)
    print(f"\n[/api/predict] status={r.status_code}")
    data = r.json()
    print(json.dumps(data, indent=2))
    assert r.status_code == 200
    assert "count" in data
    assert "boxes" in data
    assert "speed_inference_ms" in data
    print(f"\nDetected {data['count']} animal(s): {data['detections']}")


def test_annotate(image_path: str):
    payload = {"uuid": str(uuid.uuid4()), "image": encode_image(image_path)}
    r = requests.post(f"{API_BASE}/api/annotate", json=payload, timeout=60)
    print(f"\n[/api/annotate] status={r.status_code}")
    assert r.status_code == 200
    data = r.json()
    assert "image" in data and len(data["image"]) > 0
    # Save annotated image to disk so you can inspect it visually
    out_path = "annotated_output.jpg"
    with open(out_path, "wb") as f:
        f.write(base64.b64decode(data["image"]))
    print(f"Annotated image saved to {out_path}")


if __name__ == "__main__":
    image_path = sys.argv[1] if len(sys.argv) > 1 else "DATA/IMAGES/test_images/zebra_1.jpg"
    print(f"Testing with image: {image_path}\n")
    test_readiness()
    test_predict(image_path)
    test_annotate(image_path)
    print("\nAll tests passed.")
