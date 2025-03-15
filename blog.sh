#!/bin/bash

# Recupera secretos desde AWS Secrets Manager
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id prod/blog/settings/nginx --query 'SecretString' --output text)

# Validar si el secreto se obtuvo correctamente
if [[ -z "$SECRET_JSON" ]]; then
    echo "Error: No se pudo recuperar el secreto de AWS Secrets Manager."
    exit 1
fi

# Extrae valores con jq (asegúrate de tener instalado jq o usa otro método)
export SECRET_KEY=$(echo $SECRET_JSON | jq -r '.SECRET_KEY')
export API_URL=$(echo $SECRET_JSON | jq -r '.API_URL')
export DEBUG=$(echo $SECRET_JSON | jq -r '.DEBUG')
export DATABASE_USER=$(echo $SECRET_JSON | jq -r '.DATABASE_USER')
export DATABASE_PASSWORD=$(echo $SECRET_JSON | jq -r '.DATABASE_PASSWORD')
export DATABASE_NAME=$(echo $SECRET_JSON | jq -r '.DATABASE_NAME')
export DATABASE_PORT=$(echo $SECRET_JSON | jq -r '.DATABASE_PORT')


# Guarda las variables de entorno para que persistan
echo "SECRET_KEY=$SECRET_KEY" | sudo tee -a /etc/environment
echo "API_URL=$API_URL" | sudo tee -a /etc/environment
echo "DEBUG=$DEBUG" | sudo tee -a /etc/environment
echo "DATABASE_USER=$DATABASE_USER" | sudo tee -a /etc/environment
echo "DATABASE_PASSWORD=$DATABASE_PASSWORD" | sudo tee -a /etc/environment
echo "DATABASE_NAME=$DATABASE_NAME" | sudo tee -a /etc/environment
echo "DATABASE_PORT=$DATABASE_PORT" | sudo tee -a /etc/environment

# Recargar las variables de entorno
source /etc/environment


# Reinicia Nginx para aplicar los cambios
sudo systemctl restart nginx

# Ejecuta migraciones de Django
cd /home/ubuntu/BlogJaviDev/blog
source /home/ubuntu/myenv/bin/activate
python3 manage.py migrate

# Reinicia Gunicorn (si aplica)
systemctl restart gunicorn
