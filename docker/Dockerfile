# Build stage - install dependencies
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY app/requirements.txt .

# Install Python dependencies to a virtual environment
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir --upgrade pip && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt


# Runtime stage - minimal image
FROM python:3.11-slim AS runtime

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser -d /home/appuser -s /bin/bash appuser

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Copy application code
COPY --chown=appuser:appuser app/ .

# Switch to non-root user
USER appuser

# Use virtual environment
ENV PATH="/opt/venv/bin:$PATH"

# Expose gunicorn port
EXPOSE 8000

# Healthcheck for the app itself.
# NOTE: python:3.11-slim ships neither curl nor wget, so we probe the
# endpoint with the stdlib that is guaranteed to be present. urlopen()
# raises on connection errors and on non-2xx responses, giving a
# non-zero exit code when the app is unhealthy.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request as u; u.urlopen('http://localhost:8000/health')"

# Run gunicorn with 4 workers
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "--access-logfile", "-", "--error-logfile", "-", "app:app"]