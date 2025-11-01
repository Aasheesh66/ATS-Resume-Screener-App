# ATS Resume Scanner

This is a Streamlit web application for an Applicant Tracking System (ATS) Resume Scanner. It allows users to upload a PDF resume and a job description, and then provides various analyses based on the uploaded documents.

## Features

- **Upload PDF Resume**: Users can upload their resume in PDF format.
- **Input Job Description**: Users can input the job description in a text area.
- **Tell Me About the Resume**: Provides an evaluation of the candidate's profile against the job description, highlighting strengths and weaknesses.
- **Get Keywords**: Identifies specific skills and keywords necessary for the resume to have maximum impact, provided in JSON format.
- **Percentage Match**: Evaluates the percentage match of the resume with the job description, along with keywords missing and final thoughts.

## Installation

1. Clone the repository:

```
git clone https://github.com/Aditya190803/Application-Tracking-System.git
```

Install the required dependencies:

```
pip install -r requirements.txt
```

Run the Streamlit app:

```
streamlit run app.py
```

## Usage

Open the Streamlit app in your browser.
Input the job description in the text area provided.
Upload the PDF resume using the "Upload your resume(PDF)..." button.
Click on the desired action buttons to perform various analyses.

## Technologies Used

- Python
- Streamlit
- pdf2image
- Google Gemini

## Deploying to Google Cloud Run

The project is ready to be containerized and deployed to Google Cloud Run. The provided `Dockerfile` is configured to read the runtime port from the `PORT` environment variable (Cloud Run sets this for you). A `cloudbuild.yaml` is included for CI deployments with Cloud Build.

Quick deploy (local build + gcloud)

1) Authenticate and set project:

```powershell
# Windows / PowerShell
gcloud init
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

2) Build and push the image to Google Container Registry:

```powershell
$PROJECT_ID = (gcloud config get-value project)
docker build -t gcr.io/$PROJECT_ID/ats-streamlit:latest .
docker push gcr.io/$PROJECT_ID/ats-streamlit:latest
```

3) Deploy to Cloud Run:

```powershell
gcloud run deploy ats-streamlit \
 --image gcr.io/$PROJECT_ID/ats-streamlit:latest \
 --region us-central1 \
 --platform managed \
 --allow-unauthenticated \
 --set-env-vars=PORT=8080
```

Secrets (Google API key)

The app expects a Google API key to be available as `st.secrets.GOOGLE_API_KEY` in `app.py`. Recommended secure options:

- Use Secret Manager (recommended):
 1. Create a secret in Secret Manager and grant Cloud Run's runtime service account access.
 2. Deploy Cloud Run and map the secret as an environment variable with `--update-secrets=GOOGLE_API_KEY=projects/$PROJECT_ID/secrets/YOUR_SECRET:latest`.

- For dev/test you can set an env var during deploy (less secure):
 `--set-env-vars=GOOGLE_API_KEY=your_key_here`

Cloud Build

The `cloudbuild.yaml` will build the container, push the image to GCR, and deploy to Cloud Run. Connect the file to a Cloud Build trigger or run it manually with:

```powershell
gcloud builds submit --config cloudbuild.yaml .
```

Notes

- Cloud Run requires your app to bind to the `PORT` env var; the `Dockerfile` already uses `${PORT}` when starting Streamlit.
- `poppler-utils` is installed in the image to support `pdf2image`.
- If you want, I can add a Cloud Build trigger, Secret Manager automation, or a GitHub Actions workflow for CI/CD.
