# KiteEdge Data Pipeline — Python Kafka consumers
# Installs the package so entry-point scripts are on PATH.

# ---- Build stage ----
FROM python:3.11-slim-bookworm AS build

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential librdkafka-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml ./
COPY consumers/ consumers/

RUN pip install --no-cache-dir --prefix=/install .

# ---- Runtime stage ----
FROM python:3.11-slim-bookworm AS runtime

RUN apt-get update && \
    apt-get install -y --no-install-recommends librdkafka1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /install /usr/local
COPY consumers/ consumers/

RUN useradd --create-home appuser
USER appuser

# Default: run the candle builder. Override via docker-compose command.
CMD ["kiteedge-candle-builder"]
