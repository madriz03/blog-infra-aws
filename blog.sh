#!/bin/bash
# Recupera secretos desde Secrets Manager (ejemplo simplificado)
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id prod/blog/settings/nginx --query 'SecretString' --output text)

# Extrae valores con jq (asegúrate de tener instalado jq o usa otro método)
export SECRET_KEY=$(echo $SECRET_JSON | jq -r '.SECRET_KEY')
export API_URL=$(echo $SECRET_JSON | jq -r '.API_URL')
export DEBUG=$(echo $SECRET_JSON | jq -r '.DEBUG')
export DATABASE_USER=$(echo $SECRET_JSON | jq -r '.DATABASE_USER')
export DATABASE_PASSWORD=$(echo $SECRET_JSON | jq -r '.DATABASE_PASSWORD')
export DATABASE_NAME=$(echo $SECRET_JSON | jq -r '.DATABASE_NAME')
export DATABASE_PORT=$(echo $SECRET_JSON | jq -r '.DATABASE_PORT')

# Supongamos que ALB_DNS se pasa directamente desde CloudFormation mediante parámetros
export ALB_DNS="${ALB_DNS}"

# Reemplaza el placeholder en la configuración de Nginx
NGINX_CONF="/etc/nginx/sites-available/blog"
sed -i "s/{{ALB_DNS}}/${ALB_DNS}/g" $NGINX_CONF

# Reinicia Nginx para aplicar los cambios
systemctl restart nginx

# Ejecuta migraciones de Django
cd /home/ubuntu/BlogJaviDev
source /home/ubuntu/venv/bin/activate
python manage.py migrate

# Reinicia Gunicorn (si aplica)
systemctl restart gunicorn
