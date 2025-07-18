# Blog Infrastructure AWS

Este proyecto implementa la infraestructura necesaria para desplegar un blog basado en Django utilizando servicios de AWS CloudFormation.

## Descripción

Este proyecto define una infraestructura completa en AWS para alojar una aplicación web de blog desarrollada en Django. La infraestructura se despliega mediante una plantilla de AWS CloudFormation que automatiza la creación de todos los recursos necesarios.

## Arquitectura

La infraestructura incluye los siguientes componentes:

- **Red**: VPC con subredes públicas y privadas distribuidas en dos zonas de disponibilidad
- **Base de datos**: Instancia RDS PostgreSQL en subredes privadas
- **Aplicación**: Auto Scaling Group con instancias EC2 que ejecutan la aplicación Django
- **Balanceo de carga**: Application Load Balancer para distribuir el tráfico
- **Seguridad**: Grupos de seguridad configurados para cada componente
- **Conectividad**: Internet Gateway para acceso público y NAT Gateway para que las instancias privadas accedan a Internet

## Diagrama de Arquitectura

```
                                  Internet
                                     │
                                     ▼
                            ┌───────────────┐
                            │Internet Gateway│
                            └───────┬───────┘
                                    │
                              ┌─────▼─────┐
                              │    ALB     │
                              └──────┬─────┘
                                     │
                     ┌───────────────┴───────────────┐
                     │                               │
              ┌──────▼─────┐                 ┌──────▼─────┐
              │  EC2 (ASG) │                 │  EC2 (ASG) │
              │ Subnet Pub1│                 │ Subnet Pub2│
              └──────┬─────┘                 └──────┬─────┘
                     │                               │
                     ▼                               ▼
              ┌────────────┐                         │
              │NAT Gateway │                         │
              └──────┬─────┘                         │
                     │                               │
              ┌──────▼─────┐                 ┌──────▼─────┐
              │  RDS DB    │◄───────────────►│  RDS DB    │
              │Subnet Priv1│                 │Subnet Priv2│
              └────────────┘                 └────────────┘
```

## Componentes Principales

1. **VPC y Subredes**: Configuración de red con subredes públicas y privadas en dos zonas de disponibilidad.
2. **RDS PostgreSQL**: Base de datos relacional para almacenar los datos del blog.
3. **Auto Scaling Group**: Gestiona automáticamente las instancias EC2 que ejecutan la aplicación.
4. **Application Load Balancer**: Distribuye el tráfico entre las instancias.
5. **Script de Inicialización**: Configura las instancias EC2 al iniciar, obteniendo credenciales desde AWS Secrets Manager.

## Despliegue

Para desplegar esta infraestructura:

1. Asegúrate de tener configurado AWS CLI con las credenciales adecuadas.
2. Ejecuta el siguiente comando:

```bash
aws cloudformation create-stack \
  --stack-name blog-stack \
  --template-body file://blog-infra-aws.yaml \
  --parameters \
    ParameterKey=CidrVpc,ParameterValue=10.0.0.0/24 \
    ParameterKey=CidrPublicOne,ParameterValue=10.0.0.0/26 \
    ParameterKey=CidrPublicTwo,ParameterValue=10.0.0.64/26 \
    ParameterKey=CidrPrivateOne,ParameterValue=10.0.0.128/26 \
    ParameterKey=CidrPrivateTwo,ParameterValue=10.0.0.192/26 \
    ParameterKey=DbName,ParameterValue=blogdb \
    ParameterKey=DbUsername,ParameterValue=dbadmin \
    ParameterKey=DbMasterUserPassword,ParameterValue=<password> \
    ParameterKey=AsgImageId,ParameterValue=<ami-id> \
    ParameterKey=AsgKeyName,ParameterValue=<key-name>
```

## Requisitos Previos

- AMI configurada con Django, Nginx y Gunicorn
- Secreto en AWS Secrets Manager con las credenciales de la base de datos
- Archivo blog.sh en un bucket S3
- Par de claves SSH para acceder a las instancias EC2

## Seguridad

La infraestructura implementa varias capas de seguridad:
- Base de datos en subredes privadas
- Grupos de seguridad restrictivos
- Credenciales almacenadas en AWS Secrets Manager
- Acceso SSH limitado a las instancias EC2

## Tecnologías Utilizadas

- AWS CloudFormation
- Amazon VPC
- Amazon EC2 con Auto Scaling
- Amazon RDS (PostgreSQL)
- Elastic Load Balancing
- AWS Secrets Manager
- Amazon S3
- IAM Roles y Políticas

## Autor

- Javier Madriz