#!/bin/bash

# Login no ECR
echo "Fazendo login no ECR..."
chmod +x ecr-login.sh
./ecr-login.sh

# Baixar imagem mais recente
echo "Baixando imagem mais recente..."
docker pull 046394856713.dkr.ecr.us-east-1.amazonaws.com/CloudFix-hml:latest

# Parar container atual se existir
echo "Parando container atual..."
docker-compose down

# Iniciar novo container
echo "Iniciando aplicação..."
docker-compose up -d

echo "✅ Aplicação implantada com sucesso!"
echo "📊 Acesse: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
