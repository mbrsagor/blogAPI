# ------------------------------
# Builder Stage
# ------------------------------
FROM python:3.10-alpine AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /install

# System deps
RUN apk add --no-cache build-base

COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --prefix=/install --no-cache-dir -r requirements.txt

# ------------------------------
# Final Stage
# ------------------------------
FROM python:3.10-alpine

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/install/bin:$PATH"

# Copy installed deps
COPY --from=builder /install /install

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY ./app ./app

USER appuser

EXPOSE 8000

CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "app.main:app", "--bind", "0.0.0.0:8000", "--workers", "4"]
