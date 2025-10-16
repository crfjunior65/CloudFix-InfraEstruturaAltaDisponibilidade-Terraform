#!/bin/bash

# Configurações
ECR_REGISTRY="046394856713.dkr.ecr.us-east-1.amazonaws.com"
IMAGE_NAME="dolfy-hml"
TAG="latest"

echo "🔨 Construindo imagem Docker..."
docker build -t ${ECR_REGISTRY}/${IMAGE_NAME}:${TAG} .

echo "🔐 Login no ECR..."
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REGISTRY

echo "📤 Fazendo push da imagem..."
docker push ${ECR_REGISTRY}/${IMAGE_NAME}:${TAG}

echo "✅ Imagem publicada com sucesso!"
