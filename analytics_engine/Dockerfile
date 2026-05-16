# KiteEdge Analytics Engine — Python FastAPI
# Multi-stage build: install deps → slim runtime image.

# ---- Build stage ----
FROM python:3.11-slim-bookworm AS build

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml ./
RUN pip install --no-cache-dir --prefix=/install .

# ---- Runtime stage ----
FROM python:3.11-slim-bookworm AS runtime

RUN apt-get update && \
    apt-get install -y --no-install-recommends libgomp1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /install /usr/local
COPY analytics_engine/ analytics_engine/

RUN useradd --create-home appuser
USER appuser

EXPOSE 8001

CMD ["uvicorn", "analytics_engine.api.main:app", "--host", "0.0.0.0", "--port", "8001", "--workers", "2"]
