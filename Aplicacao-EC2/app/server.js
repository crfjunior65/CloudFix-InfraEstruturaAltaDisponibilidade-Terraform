const express = require('express');
const { Pool } = require('pg');
const Redis = require('ioredis');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Configurações do banco de dados
const dbConfig = {
  host: process.env.DB_HOST?.split(':')[0], // Remove porta se presente
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'dolfy',
  user: process.env.DB_USER || 'dolfy',
  password: process.env.DB_PASSWORD || 'dolfy_password',
  ssl: process.env.NODE_ENV === 'production'
};

// Configurações do Redis
const redisConfig = {
  host: process.env.REDIS_HOST,
  port: process.env.REDIS_PORT || 6379,
  retryDelayOnFailover: 100,
  maxRetriesPerRequest: 3
};

// Clientes de banco (serão inicializados sob demanda)
let dbPool = null;
let redisClient = null;

// Health check completo
app.get('/health', async (req, res) => {
  const healthCheck = {
    status: 'OK',
    timestamp: new Date().toISOString(),
    service: 'Dolfy API',
    version: '1.0.0',
    checks: {}
  };

  try {
    // Check banco de dados
    if (!dbPool) {
      dbPool = new Pool(dbConfig);
    }
    const dbResult = await dbPool.query('SELECT NOW() as time');
    healthCheck.checks.database = {
      status: 'OK',
      response_time: 'connected',
      details: `PostgreSQL ${dbResult.rows[0].time}`
    };
  } catch (dbError) {
    healthCheck.checks.database = {
      status: 'ERROR',
      error: dbError.message
    };
    healthCheck.status = 'DEGRADED';
  }

  try {
    // Check Redis
    if (!redisClient) {
      redisClient = new Redis(redisConfig);
    }
    await redisClient.ping();
    healthCheck.checks.redis = {
      status: 'OK',
      response_time: 'connected'
    };
  } catch (redisError) {
    healthCheck.checks.redis = {
      status: 'ERROR',
      error: redisError.message
    };
    healthCheck.status = 'DEGRADED';
  }

  const statusCode = healthCheck.status === 'OK' ? 200 : 503;
  res.status(statusCode).json(healthCheck);
});

// Endpoint principal
app.get('/api', (req, res) => {
  res.json({
    message: '🚀 Dolfy API está funcionando!',
    environment: process.env.NODE_ENV || 'development',
    region: process.env.AWS_REGION || 'us-east-1',
    endpoints: {
      health: '/health',
      users: '/api/users',
      cache: '/api/cache'
    }
  });
});

// CRUD de usuários (exemplo com PostgreSQL)
app.get('/api/users', async (req, res) => {
  try {
    if (!dbPool) dbPool = new Pool(dbConfig);

    const result = await dbPool.query(`
      SELECT * FROM users LIMIT 10
    `);

    res.json({
      success: true,
      data: result.rows,
      count: result.rowCount
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Cache com Redis (exemplo)
app.get('/api/cache/:key', async (req, res) => {
  try {
    if (!redisClient) redisClient = new Redis(redisConfig);

    const { key } = req.params;
    const value = await redisClient.get(key);

    if (value) {
      res.json({
        success: true,
        source: 'cache',
        data: JSON.parse(value)
      });
    } else {
      // Simular dados do banco
      const mockData = {
        id: key,
        message: 'Dados do banco',
        timestamp: new Date().toISOString()
      };

      // Salvar no cache por 5 minutos
      await redisClient.setex(key, 300, JSON.stringify(mockData));

      res.json({
        success: true,
        source: 'database',
        data: mockData
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Inicialização segura
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🎯 Dolfy API rodando na porta ${PORT}`);
  console.log(`🏥 Health Check: http://localhost:${PORT}/health`);
  console.log(`📚 API Docs: http://localhost:${PORT}/api`);
  console.log(`🗄️  Database: ${dbConfig.host}`);
  console.log(`🔮 Redis: ${redisConfig.host}`);
});
