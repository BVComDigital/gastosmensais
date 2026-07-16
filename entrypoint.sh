#!/bin/bash
set -e

echo "Coletando arquivos estáticos..."
python manage.py collectstatic --noinput

echo "Executando migrações..."
python manage.py migrate --noinput

echo "Iniciando Gunicorn..."
exec gunicorn \
  --bind 0.0.0.0:8000 \
  --workers 2 \
  --timeout 60 \
  --access-logfile - \
  --error-logfile - \
  gastosmensais.wsgi:application
