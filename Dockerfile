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

EXPOSE 8501

HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

# Explicit bash avoids exec format errors
ENTRYPOINT ["bash", "./docker-entrypoint.sh"]

