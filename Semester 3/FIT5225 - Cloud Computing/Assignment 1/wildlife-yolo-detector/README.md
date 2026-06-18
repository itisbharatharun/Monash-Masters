# 🦁 Wild Animals Detection using YOLOv8

A comprehensive implementation of a wild animals detection system using YOLOv8, Roboflow, and Python. This project enables real-time detection and tracking of wild animals in images and videos. 

![Python](https://img.shields.io/badge/Python-3.7+-blue.svg)
![YOLOv8](https://img.shields.io/badge/YOLO-v8-brightgreen.svg)
![OpenCV](https://img.shields.io/badge/OpenCV-4.x-red.svg)

![lions_detected](https://github.com/user-attachments/assets/1fb43c97-a643-4a4c-a0ae-e61e97767bd8)

![tiger_detected](https://github.com/user-attachments/assets/ca734f18-4deb-4efa-ac65-0eb46e6e791e)



## 🚀 Features

- Real-time wild animal detection in images and videos
- Support for both local files and URL-based images
- Automatic tracking of animals in video streams
- Confidence-based filtering of detections
- Custom visualization with optimized annotations
- Easy-to-use interface for both image and video processing

## 📋 Prerequisites

Before running this project, make sure you have the following dependencies installed:

```bash
pip install roboflow ultralytics supervision opencv-python matplotlib numpy requests
```

## 🛠️ Installation

1. Clone the repository:
```bash
git clone https://github.com/Pushtogithub23/wildlife-yolo-detector.git
cd wildlife-yolo-detector
```

2. Install required packages:
```bash
pip install -r requirements.txt
```

3. Set up your Roboflow API key:
- Create an account on [Roboflow](https://roboflow.com)
- Replace `YOUR_API_KEY` in the notebook with your actual API key

## 💻 Usage

### Image Detection

```python

# For local images
display_prediction(
    "DATA/IMAGES/test_images/zebra_1.jpg",
    save_fig=True,
    filename='zebras_detected_1.jpg'
)

# For images from URL
display_prediction(
    "https://example.com/image.jpg",
    save_fig=True,
    filename='detected_image.jpg'
)
```

I have attached a few image detections below:

![elephants_detected](https://github.com/user-attachments/assets/7c715b0a-daa0-4046-bd7d-3d2d4dfdec11)

![giraffes_detected](https://github.com/user-attachments/assets/c41bdc75-5a0b-48b2-9092-689aa1c82a0b)

![zebras_detected](https://github.com/user-attachments/assets/8130cc73-b461-4cda-b2c7-ad3e1a22d26c)

### Video Detection

```python

predict_in_videos(
    "DATA/VIDEOS/test_videos/zebras.mp4",
    save_video=True,
    filename='zebras_detected.mp4'
)
```
I have attached a few video detections below in gif format:

![zebras_detected](https://github.com/user-attachments/assets/03f0d723-4d36-46b8-9d8a-d41cf616ca74)

![giraffe_detected](https://github.com/user-attachments/assets/f8bf1c33-cbf8-449d-b5fe-1d135c2cef6f)

## 📦 Project Structure

```
wild-animals-detection/
├── DATA/
│   ├── IMAGES/
│   │   ├── test_images/
│   │   └── detected_images/
│   └── VIDEOS/
│       ├── test_videos/
│       └── captured_videos/
|── yolo-wild-animals-detection.ipynb
├── requirements.txt
└── README.md
```

## 🔧 Model Training

The project uses YOLOv8 large model (`yolov8l.pt`) as the base model for transfer learning. To train the model on your own dataset:

1. Prepare your dataset using Roboflow
2. Update the data.yaml file with correct paths
3. Run the training script:

```python
model = YOLO('yolov8l.pt')
model.train(
    data="WILD-ANIMALS-DETECTION-1/data.yaml",
    epochs=100,
    imgsz=640
)
```

## 📝 Key Parameters

- Detection confidence threshold: 0.5
- Video processing can be stopped by pressing 'p'
- Image size for training: 640x640
- Training epochs: 100

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## 🙏 References

- [Ultralytics](https://github.com/ultralytics/ultralytics) for YOLOv8
- [Roboflow](https://roboflow.com) for dataset management
- [Supervision](https://github.com/roboflow/supervision) for annotation tools

You can find the project on Roboflow by clicking [here](https://universe.roboflow.com/puspendu-ai-vision-workspace/wild-animals-detection-fspct)

You can view the training results on wandb(Weights & Biases) by clicking [here](https://wandb.ai/ranapuspendu24-iit-madras-foundation/Ultralytics/runs/o2ze0pai/workspace?nw=nwuserranapuspendu24)
