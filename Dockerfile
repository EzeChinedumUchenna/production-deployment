# Stage 1: Build environment
FROM python:3.11-slim as builder

# Security best practices:
# 1. Use slim image to reduce attack surface
# 2. Pin Python version
# 3. Create non-root user

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PIP_NO_CACHE_DIR 1
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

WORKDIR /app

# Install system dependencies (minimal set)
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc python3-dev && \
    rm -rf /var/lib/apt/lists/*

# Create and switch to non-root user
RUN useradd -m appuser && chown -R appuser /app
USER appuser

# Install Python dependencies
COPY --chown=appuser requirements.txt .
RUN pip install --user --no-warn-script-location -r requirements.txt


# Stage 2: Runtime environment
FROM python:3.11-slim as runtime

# Security best practices:
# 1. Start fresh with clean image
# 2. Use same Python version as builder
# 3. Copy only what's needed

WORKDIR /app

# Create non-root user (must match UID from builder)
RUN useradd -m appuser && \
    mkdir -p /app && \
    chown -R appuser /app

# Copy installed Python packages from builder
COPY --from=builder --chown=appuser /home/appuser/.local /home/appuser/.local
COPY --chown=appuser . .

# Ensure scripts in .local are usable
ENV PATH=/home/appuser/.local/bin:$PATH

# Switch to non-root user
USER appuser

# Security hardening:
# 1. Run as non-root
# 2. Set umask for proper file permissions
# 3. Use environment variables for configuration

# Set secure defaults
ENV UMASK=0077
ENV UWSGI_HTTP=:8000
ENV UWSGI_MASTER=1
ENV UWSGI_WORKERS=2
ENV UWSGI_THREADS=2
ENV UWSGI_UID=appuser
ENV UWSGI_GID=appuser
ENV UWSGI_LAZY_APPS=1
ENV UWSGI_WSGI_ENV_BEHAVIOR=holy

# Expose port (documentation only, doesn't actually publish)
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the application (using uvicorn directly for simplicity)
# For production, consider using gunicorn with uvicorn workers
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--no-access-log"]
