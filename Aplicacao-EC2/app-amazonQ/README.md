# App de Teste - Infraestrutura AWS

Aplicação Python Flask para testar conexões com RDS PostgreSQL e Redis (Valkey).

## Endpoints Disponíveis

- `GET /` - Página inicial com lista de endpoints
- `GET /health` - Status da aplicação e conexões
- `GET /db/test` - Testa conexão PostgreSQL
- `POST /db/user` - Cria usuário no PostgreSQL
- `GET /db/users` - Lista usuários do PostgreSQL
- `GET /redis/test` - Testa conexão Redis
- `POST /redis/set` - Define valor no Redis
- `GET /redis/get/<key>` - Busca valor no Redis

## Como usar

### 1. Build e Push para ECR
```bash
./build-push-ecr.sh
```

### 2. Testar localmente
```bash
docker-compose up --build
```

### 3. Testar na EC2
Após fazer o push para ECR, use a imagem no docker-compose da EC2.

## Exemplos de Teste

### Criar usuário
```bash
curl -X POST http://localhost:8000/db/user \
  -H "Content-Type: application/json" \
  -d '{"name": "João Silva", "email": "joao@example.com"}'
```

### Definir valor no Redis
```bash
curl -X POST http://localhost:8000/redis/set \
  -H "Content-Type: application/json" \
  -d '{"key": "teste", "value": {"msg": "Hello Redis!"}, "ttl": 3600}'
```

### Buscar valor no Redis
```bash
curl http://localhost:8000/redis/get/teste
```
