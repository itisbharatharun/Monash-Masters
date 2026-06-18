from pydantic import BaseModel
from typing import List


class InferenceRequest(BaseModel):
    uuid: str
    image: str  # base64-encoded image string


class BoundingBox(BaseModel):
    x: float
    y: float
    width: float
    height: float
    probability: float


class PredictResponse(BaseModel):
    uuid: str
    count: int
    detections: List[str]
    boxes: List[BoundingBox]
    speed_preprocess_ms: float
    speed_inference_ms: float
    speed_postprocess_ms: float


class AnnotateResponse(BaseModel):
    uuid: str
    image: str  # base64-encoded annotated image
