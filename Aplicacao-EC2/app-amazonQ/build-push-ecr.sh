#!/bin/bash

# Configurações
AWS_REGION="us-east-1"
ECR_REPOSITORY="dolfy-hml"
IMAGE_TAG="latest"

# Pega o account ID da AWS
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"

echo "🔐 Fazendo login no ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}

echo "🏗️  Construindo a imagem..."
docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} .

echo "🏷️  Taggeando a imagem..."
docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}

echo "📤 Enviando para o ECR..."
docker push ${ECR_URI}:${IMAGE_TAG}

echo "✅ Imagem enviada com sucesso!"
echo "📋 URI da imagem: ${ECR_URI}:${IMAGE_TAG}"
