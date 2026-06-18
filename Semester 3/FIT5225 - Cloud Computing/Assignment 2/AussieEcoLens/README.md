# AussieEcoLens

**FIT5225 Cloud Computing and Security — Assignment 2**
**Group 20 | Monash University | Semester 1, 2026**

AussieEcoLens is a multi-cloud serverless wildlife observation platform. Users upload images and videos of Australian fauna, which are automatically processed through an ML inference pipeline to detect and tag species. Files are queryable by species, tag counts, or thumbnail URL. Users can manage tags, delete files, and subscribe to email notifications per species.

---

## Team

| Name | Student ID | Role |
|---|---|---|
| Bharath Ganesh | bgan0012 | AWS backend, Lambda functions, infrastructure |
| Gokhul Raj Saravanan | gsar0011 | React + Vite frontend |
| Premkumar Sathish | psat0006 | GCP Cloud Function proxy |
| Melissa Aug | maug0012 | DynamoDB, SNS, Cognito, notifications testing |

---

## Architecture Overview

**Primary cloud — AWS (us-east-1):**
Amazon Cognito, API Gateway, Lambda, S3, DynamoDB, SNS, ECR

**Secondary cloud — GCP (us-central1):**
Cloud Function acting as an HTTP proxy, forwarding authenticated frontend requests to AWS API Gateway

All backend services are already deployed and live. No backend setup is required.

---

## Running the Application

### Prerequisites

- Node.js v18 or above
- A modern web browser
- A valid email address for account registration

### Steps

1. Clone the repository:

```bash
git clone https://github.com/bgan0012/AussieEcoLens.git
cd AussieEcoLens
```

2. Navigate to the frontend directory:

```bash
cd frontend
```

3. Install dependencies:

```bash
npm install
```

4. Start the development server:

```bash
npm run dev
```

5. Open your browser and go to `http://localhost:5173`

---

## Using the Application

**Register** — Click Sign Up, enter your email address, first name, last name, and a password. Check your email for the Cognito verification code and enter it when prompted.

**Sign in** — Use your registered email and password to log in.

**Upload** — Select Upload Media, choose an image (JPG, PNG) or video (MP4, MOV), and click Upload. The backend automatically runs deduplication, species detection, thumbnail generation, and stores the results. Allow a few minutes for processing before querying.

**Query** — Select Search Library and choose a query mode: by species name, by tag counts (e.g. `kangaroo:1`), or by thumbnail URL. Results are displayed with thumbnail previews.

**Reverse Search** — Upload a query image to detect its species and find matching files in the database. The query image is not stored.

**Manage Tags** — Paste one or more S3 file URLs, enter species tags, and choose Add or Remove.

**Delete Files** — Paste S3 file URLs, confirm the checkbox, and click Delete. The file, its thumbnail, and its database record are all removed.

**Notifications** — Enter your email and the species names you want to watch, then click Subscribe. You will receive an SNS confirmation email. After confirming, you will receive alerts whenever a new matching file is uploaded.

---

## Repository Structure

```
AussieEcoLens/
├── frontend/          # React + Vite web application
├── lambdas/           # Python Lambda function handlers
│   ├── upload/
│   ├── deduplication/
│   ├── inference/     # Docker container image (ECR)
│   ├── thumbnail/
│   ├── query/
│   ├── tags/
│   ├── notifications/
│   ├── presign/
│   └── delete/
├── batch.py           # Standalone ML inference script
├── config.yaml        # Model configuration
├── labels.txt         # Species class labels
└── requirements.txt   # Python dependencies for batch inference
```

---

## Standalone Batch Inference (optional)

To run the ML inference script independently without the full application:

```bash
python -m pip install megadetector tqdm
python -m pip install onnx2torch
python batch.py
```

Supported species classes are defined in `labels.txt`.
