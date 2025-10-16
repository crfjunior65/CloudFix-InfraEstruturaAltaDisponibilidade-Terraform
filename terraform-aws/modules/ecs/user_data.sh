#!/bin/bash
# User Data Script for ECS Instances

# Update system
yum update -y

# Configure ECS agent
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config

# Install CloudWatch Agent
yum install -y amazon-cloudwatch-agent

# Configure Docker to use ECR
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin $(echo ${ecr_repository} | cut -d'/' -f1)

# Create environment file for containers
mkdir -p /opt/app
cat > /opt/app/.env << EOF
DB_HOST=${db_endpoint}
REDIS_HOST=${valkey_endpoint}
AWS_REGION=${aws_region}
EOF

# Start ECS agent
start ecs

# Log completion
echo "$(date): ECS instance setup completed" >> /var/log/user-data.log
