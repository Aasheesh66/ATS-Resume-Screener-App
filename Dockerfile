# Lightweight Dockerfile for the ATS Streamlit app
# - Installs poppler-utils (required by pdf2image)
# - Installs Python dependencies from requirements.txt
# - Runs Streamlit on 0.0.0.0:8501

FROM python:3.11-slim

# Keep Python output unbuffered and avoid writing .pyc files
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install system packages required for pdf2image and building some Python packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    poppler-utils \
    build-essential \
    pkg-config \
    libpoppler-cpp-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python packages
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r /app/requirements.txt

# Copy application source
COPY . /app

# Streamlit recommended env settings for containerized/headless usage
# Cloud Run injects the PORT environment variable; default to 8080 when not provided
ENV STREAMLIT_SERVER_HEADLESS=true \
    STREAMLIT_SERVER_ENABLE_CORS=false \
    STREAMLIT_SERVER_RUN_ON_SAVE=false \
    PORT=8080

# Create a non-root user and set ownership of /app for improved security
RUN adduser --disabled-password --gecos "" app \
    && chown -R app:app /app

# Expose the default Cloud Run port
EXPOSE 8080

# Switch to the non-root user for running the app
USER app

# Use sh -c so the $PORT env var is expanded at runtime (Cloud Run sets PORT)
CMD ["sh", "-c", "streamlit run app.py --server.port ${PORT} --server.address 0.0.0.0"]
