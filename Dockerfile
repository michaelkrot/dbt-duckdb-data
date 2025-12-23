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

EXPOSE 8080

# Install Streamlit (if not already via requirements.txt)
RUN pip install streamlit plotly  # Add if missing; safe to duplicate

# Expose Streamlit port
EXPOSE 8501

# Health check for Streamlit
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:8501/_stcore/health || exit 1


# Explicit bash avoids exec format errors
ENTRYPOINT ["bash", "./docker-entrypoint.sh"]

