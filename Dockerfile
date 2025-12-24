FROM python:3.11-slim

ENV DBT_PROFILES_DIR=/app
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# -----------------------------
# OS dependencies
# -----------------------------
RUN apt-get update && \
    apt-get install -y git bash curl && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# Python dependencies
# -----------------------------
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Optional: Streamlit + Plotly if not in requirements
RUN pip install --no-cache-dir streamlit plotly

# -----------------------------
# Copy app and scripts
# -----------------------------
COPY . .
RUN chmod +x docker-entrypoint.sh

# -----------------------------
# Expose ports
# -----------------------------
EXPOSE 8080
EXPOSE 8501

# -----------------------------
# Health check for Streamlit
# -----------------------------
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:8501/_stcore/health || exit 1

# -----------------------------
# Entrypoint
# -----------------------------
ENTRYPOINT ["bash", "./docker-entrypoint.sh"]


