FROM python:3.11-slim

ENV DBT_PROFILES_DIR=/app
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# OS deps (git needed for dbt deps)
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chmod +x docker-entrypoint.sh

# Explicit bash avoids exec format errors
ENTRYPOINT ["bash", "./docker-entrypoint.sh"]

