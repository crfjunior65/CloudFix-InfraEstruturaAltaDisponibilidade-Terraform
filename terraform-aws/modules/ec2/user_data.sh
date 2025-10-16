#!/bin/bash
# User Data Script for Application EC2 Instances
echo "$(date): EC2 instance setup iniciado..." >> /var/log/user-data.log
# Update system
yum update -y

echo "$(date): EC2 instance setup docker..." >> /var/log/user-data.log
# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
echo "$(date): EC2 instance setup aws cli..." >> /var/log/user-data.log
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
echo "$(date): EC2 instance setup agente cloudwhatch..." >> /var/log/user-data.log
# Install CloudWatch Agent
yum install -y amazon-cloudwatch-agent

# Configure Docker to use ECR
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_repository}
echo "$(date): EC2 instance setup dir app..." >> /var/log/user-data.log
# Create application directory
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app
chown -R ec2-user:ec2-user /home/ec2-user/

# Adicionar usuário atual ao grupo docker
sudo usermod -aG docker ec2-user ###$USER

# Recarregar as groups (faça logout/login ou execute)
newgrp docker

# Agora teste sem sudo
#docker-compose up -d
echo "$(date): EC2 instance setup app env..." >> /var/log/user-data.log
# Create environment file
cat > .env << EOF
DB_HOST=${db_endpoint}
REDIS_HOST=${valkey_endpoint}
AWS_REGION=${aws_region}
ECR_REPOSITORY=${ecr_repository}
EOF
echo "$(date): EC2 instance setup docker-compose..." >> /var/log/user-data.log
# Create docker-compose.yaml for application
cat > docker-compose.yaml << EOF
version: '3.8'
services:
  app:
    image: ${ecr_repository}:latest
    ports:
      - "80:3000"
    environment:
      - DB_HOST=${db_endpoint}
      - REDIS_HOST=${valkey_endpoint}
      - AWS_REGION=${aws_region}
    restart: unless-stopped
    logging:
      driver: awslogs
      options:
        awslogs-group: /aws/ec2/app
        awslogs-region: ${aws_region}
        awslogs-stream: app-container
EOF

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create CloudWatch log group
aws logs create-log-group --log-group-name /aws/ec2/app --region ${aws_region} || true

# Enable and start the application service
systemctl daemon-reload

# Create health check endpoint
mkdir -p /var/www/html
echo "OK" > /var/www/html/health
echo "$(date): EC2 instance setup Up App..." >> /var/log/user-data.log
# Create Script para subir App for application
cat > up-app-ec2.sh << EOF
#!/bin/bash

echo "🎯 Iniciando deploy na EC2..."

# Verificar se usuário está no grupo docker
if ! groups $USER | grep -q '\bdocker\b'; then
    echo "❌ Usuário não está no grupo docker. Execute:"
    echo "   sudo usermod -a -G docker $USER"
    echo "   # Depois faça logout e login da EC2"
    echo "   # Execute o script novamente após login"
    exit 1
fi

# Login no ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 046394856713.dkr.ecr.us-east-1.amazonaws.com

sudo usermod -a -G docker ec2-user
#newgrp docker

# Parar container atual se existir
docker-compose down

# Pull da imagem mais recente
docker pull 046394856713.dkr.ecr.us-east-1.amazonaws.com/dolfy-hml:latest

# Iniciar aplicação
docker-compose up -d

echo "✅ Deploy concluído!"
echo "📊 Verificar status: docker-compose ps"
echo "📝 Ver logs: docker-compose logs -f dolfy-app"
echo "🌐 Acesse: http://localhost/health"
EOF

# Make the script executable
chmod +x /home/ec2-user/up-app-ec2.sh

# # Install and configure nginx for health checks
# yum install -y nginx
# systemctl start nginx
# systemctl enable nginx

# # Configure nginx for health check and proxy
# cat > /etc/nginx/conf.d/app.conf << EOF
# server {
#     listen 80;

#     location /health {
#         root /var/www/html;
#         try_files \$uri \$uri/ =404;
#     }

#     location / {
#         proxy_pass http://localhost:8080;
#         proxy_set_header Host \$host;
#         proxy_set_header X-Real-IP \$remote_addr;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto \$scheme;
#     }
# }
# EOF

# systemctl restart nginx

chown -R ec2-user:ec2-user /home/ec2-user/
chmod +x /home/ec2-user/app/up-app-ec2.sh

# Log completion
echo "$(date): EC2 instance setup completed" >> /var/log/user-data.log
