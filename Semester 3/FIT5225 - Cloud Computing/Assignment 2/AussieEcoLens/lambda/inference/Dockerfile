FROM public.ecr.aws/lambda/python:3.12

RUN dnf install -y \
    mesa-libGL \
    glib2 \
    libgomp \
    cmake \
    gcc \
    gcc-c++ \
    protobuf-compiler \
    protobuf-devel \
    && dnf clean all

RUN pip install --no-cache-dir \
    torch torchvision --index-url https://download.pytorch.org/whl/cpu

RUN pip install --no-cache-dir megadetector

RUN pip install --no-cache-dir --no-deps onnx2torch

RUN pip install --no-cache-dir "onnx>=1.14.0"

RUN pip install --no-cache-dir \
    opencv-python-headless \
    tqdm \
    boto3

COPY handler.py ${LAMBDA_TASK_ROOT}/

CMD ["handler.lambda_handler"]
