# ============== STAGE 1: BUILD ==============
FROM python:3.12-slim AS builder

WORKDIR /app

# Instalar ferramentas de compilação (build-essential, libpq-dev)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements
COPY requirements.txt .

# Instalar dependências Python em /root/.local
RUN pip install --no-cache-dir --user -r requirements.txt
# ============== STAGE 2: RUNTIME ==============
FROM python:3.12-slim

# Variáveis de ambiente (Python não buffering)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Instalar apenas dependências runtime (libpq5 para Postgres, curl para healthcheck)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copiar dependências do builder
COPY --from=builder /root/.local /root/.local

# Ativar PATH para usar binários (pip, gunicorn)
ENV PATH=/root/.local/bin:$PATH

# Copiar código
COPY requirements.txt .
COPY . .

# Copiar e executar entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
