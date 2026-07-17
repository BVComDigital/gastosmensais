#!/bin/bash
set -e

cd /app #Faz o comando entrar na pasta djangoapp para encontrar manage.py

echo "Coletando arquivos estáticos..."
python djangoapp/manage.py collectstatic --noinput

echo "Executando migrações..."
python djangoapp/manage.py migrate --noinput

echo "Iniciando Gunicorn..."
export PYTHONPATH=$PYTHONPATH:/app/djangoapp 
#Faz o comando entrar na pasta djangoapp para achar o setup no wsgi.py

exec gunicorn \
  --bind 0.0.0.0:8000 \
  --workers 2 \
  --timeout 60 \
  --access-logfile - \
  --error-logfile - \
  djangoapp.setup.wsgi:application
