FROM python:3.11-slim AS builder
WORKDIR /install
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libglib2.0-0 libgl1 && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --upgrade pip --no-cache-dir \
 && pip install --no-cache-dir --prefix=/install/deps \
        torch==2.5.1 torchvision==0.20.1 \
        --index-url https://download.pytorch.org/whl/cpu \
 && pip install --no-cache-dir --prefix=/install/deps \
        -r requirements.txt \
        --extra-index-url https://download.pytorch.org/whl/cpu \
 && pip install --no-cache-dir --prefix=/install/deps \
        numpy==1.26.4

FROM python:3.11-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 libgl1 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /install/deps /usr/local
RUN pip install --no-cache-dir numpy==1.26.4
RUN groupadd --gid 1001 appgroup \
 && useradd --uid 1001 --gid appgroup --no-create-home appuser
WORKDIR /app
COPY --chown=appuser:appgroup app/ ./app/
COPY --chown=appuser:appgroup yolov8l.onnx ./yolov8l.onnx
COPY --chown=appuser:appgroup yolov8l.onnx.data ./yolov8l.onnx.data
ENV MODEL_PATH=yolov8l.onnx
ENV INFER_SIZE=480
ENV ULTRALYTICS_CONFIG_DIR=/app/.cache/ultralytics
ENV MPLCONFIGDIR=/app/.cache/matplotlib
RUN mkdir -p /app/.cache/ultralytics /app/.cache/matplotlib \
 && chown -R appuser:appgroup /app/.cache
USER appuser
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
