"""
main.py — CloudEco Wildlife Detection FastAPI Service.

Concurrency architecture:
  YOLO inference is CPU-bound and synchronous.  Running it directly inside
  an async route blocks the entire event loop, serialising ALL concurrent
  requests behind a single inference call.

  Fix: every CPU-bound call is offloaded to a dedicated ThreadPoolExecutor
  with max_workers=1.  This matches the pod's 1 vCPU limit — more workers
  would cause OS-level thread contention on a single core, increasing
  context-switching overhead with no throughput benefit.

  Each endpoint makes exactly ONE executor call (decode + infer combined),
  eliminating the redundant context switch introduced by two sequential
  run_in_threadpool calls.
"""

import asyncio
import logging
from concurrent.futures import ThreadPoolExecutor
from contextlib import asynccontextmanager
from typing import Any, Dict

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse

from .schemas import AnnotateResponse, InferenceRequest, PredictResponse

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s - %(message)s",
)
logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Dedicated thread pool — 1 worker matches the 1 vCPU pod resource limit.
# Avoids thread contention that would occur with the default pool size.
# ---------------------------------------------------------------------------
_executor = ThreadPoolExecutor(max_workers=1)

# ---------------------------------------------------------------------------
# Application state
# ---------------------------------------------------------------------------
app_state: Dict[str, Any] = {}


async def _run(func, *args):
    """Run a blocking callable in the dedicated single-worker executor."""
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(_executor, func, *args)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Load the YOLO model once at startup in the executor thread (non-blocking),
    then serve requests.  Kubernetes readiness probe keeps hitting /readyz
    until this completes before routing any traffic.
    """
    logger.info("Application startup: loading ONNX model …")
    from .model import WildlifeDetector

    detector = await _run(WildlifeDetector)
    app_state["detector"] = detector
    app_state["ready"] = True
    logger.info("Startup complete — API is ready.")

    yield

    logger.info("Application shutdown: releasing resources.")
    app_state.clear()
    _executor.shutdown(wait=False)


# ---------------------------------------------------------------------------
# FastAPI application
# ---------------------------------------------------------------------------
app = FastAPI(
    title="CloudEco Wildlife Detection API",
    description=(
        "RESTful inference service for YOLOv8-ONNX wildlife detection. "
        "Detects Elephant, Giraffe, Gorilla, Lion, Tiger, and Zebra."
    ),
    version="2.0.0",
    lifespan=lifespan,
)


# ---------------------------------------------------------------------------
# Health / probe endpoints
# ---------------------------------------------------------------------------

@app.get("/healthz", tags=["Probes"])
async def liveness():
    """Liveness probe — returns 200 as long as the process is alive."""
    return {"status": "alive"}


@app.get("/readyz", tags=["Probes"])
async def readiness():
    """Readiness probe — returns 200 only after YOLO model is fully loaded."""
    if app_state.get("ready"):
        return {"status": "ready"}
    raise HTTPException(status_code=503, detail="Model not yet loaded")


# ---------------------------------------------------------------------------
# Inference endpoints
# ---------------------------------------------------------------------------

@app.post("/api/predict", response_model=PredictResponse, tags=["Inference"])
async def predict(request: InferenceRequest):
    """
    Accept a base64-encoded image and return structured detection results.

    Decode and inference are combined into a single executor call to avoid
    the overhead of two sequential threadpool context switches.
    """
    detector = app_state.get("detector")
    if detector is None:
        raise HTTPException(status_code=503, detail="Model not ready")

    try:
        result = await _run(detector.decode_and_predict, request.image)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        logger.exception("Inference failed for uuid=%s", request.uuid)
        raise HTTPException(status_code=500, detail="Inference failed") from exc

    return PredictResponse(uuid=request.uuid, **result)


@app.post("/api/annotate", response_model=AnnotateResponse, tags=["Inference"])
async def annotate(request: InferenceRequest):
    """
    Accept a base64-encoded image and return it with bounding boxes drawn,
    also base64-encoded.
    """
    detector = app_state.get("detector")
    if detector is None:
        raise HTTPException(status_code=503, detail="Model not ready")

    try:
        annotated_b64 = await _run(detector.decode_and_annotate, request.image)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        logger.exception("Annotation failed for uuid=%s", request.uuid)
        raise HTTPException(status_code=500, detail="Annotation failed") from exc

    return AnnotateResponse(uuid=request.uuid, image=annotated_b64)


# ---------------------------------------------------------------------------
# Global exception handler
# ---------------------------------------------------------------------------

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.exception("Unhandled exception on %s", request.url)
    return JSONResponse(
        status_code=500,
        content={"detail": "An unexpected error occurred."},
    )
