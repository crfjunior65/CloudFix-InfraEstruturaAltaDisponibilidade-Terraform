from flask import Flask, jsonify, request
import psycopg2
import redis
import os
import json
from datetime import datetime

app = Flask(__name__)

# Configurações do banco
DB_CONFIG = {
    'host': os.getenv('DB_HOST'),
    'port': os.getenv('DB_PORT', 5432),
    'database': os.getenv('DB_NAME'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD')
}

# Configurações do Redis
REDIS_CONFIG = {
    'host': os.getenv('REDIS_HOST'),
    'port': int(os.getenv('REDIS_PORT', 6379)),
    'decode_responses': True
}

@app.route('/')
def home():
    return jsonify({
        'message': 'API de Teste - Infraestrutura AWS',
        'endpoints': [
            'GET /health - Status da aplicação',
            'GET /db/test - Testa conexão PostgreSQL',
            'POST /db/user - Cria usuário no PostgreSQL',
            'GET /db/users - Lista usuários do PostgreSQL',
            'GET /redis/test - Testa conexão Redis',
            'POST /redis/set - Define valor no Redis',
            'GET /redis/get/<key> - Busca valor no Redis'
        ]
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'services': {
            'database': test_db_connection(),
            'redis': test_redis_connection()
        }
    })

def test_db_connection():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        conn.close()
        return 'connected'
    except Exception as e:
        return f'error: {str(e)}'

def test_redis_connection():
    try:
        r = redis.Redis(**REDIS_CONFIG)
        r.ping()
        return 'connected'
    except Exception as e:
        return f'error: {str(e)}'

@app.route('/db/test')
def db_test():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()

        # Cria tabela se não existir
        cur.execute('''
            CREATE TABLE IF NOT EXISTS test_users (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100),
                email VARCHAR(100),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        conn.commit()

        # Testa inserção
        cur.execute("INSERT INTO test_users (name, email) VALUES (%s, %s) RETURNING id",
                   ('Test User', 'test@example.com'))
        user_id = cur.fetchone()[0]
        conn.commit()

        cur.close()
        conn.close()

        return jsonify({
            'status': 'success',
            'message': 'PostgreSQL conectado e funcionando',
            'test_user_id': user_id
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/db/user', methods=['POST'])
def create_user():
    try:
        data = request.get_json()
        name = data.get('name')
        email = data.get('email')

        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()

        cur.execute("INSERT INTO test_users (name, email) VALUES (%s, %s) RETURNING id",
                   (name, email))
        user_id = cur.fetchone()[0]
        conn.commit()

        cur.close()
        conn.close()

        return jsonify({
            'status': 'success',
            'user_id': user_id,
            'name': name,
            'email': email
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/db/users')
def get_users():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()

        cur.execute("SELECT id, name, email, created_at FROM test_users ORDER BY created_at DESC LIMIT 10")
        users = cur.fetchall()

        cur.close()
        conn.close()

        return jsonify({
            'status': 'success',
            'users': [
                {
                    'id': user[0],
                    'name': user[1],
                    'email': user[2],
                    'created_at': user[3].isoformat() if user[3] else None
                }
                for user in users
            ]
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/redis/test')
def redis_test():
    try:
        r = redis.Redis(**REDIS_CONFIG)

        # Testa set/get
        test_key = 'test_key'
        test_value = f'test_value_{datetime.now().isoformat()}'

        r.set(test_key, test_value, ex=300)  # Expira em 5 minutos
        retrieved_value = r.get(test_key)

        return jsonify({
            'status': 'success',
            'message': 'Redis conectado e funcionando',
            'test': {
                'key': test_key,
                'set_value': test_value,
                'retrieved_value': retrieved_value
            }
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/redis/set', methods=['POST'])
def redis_set():
    try:
        data = request.get_json()
        key = data.get('key')
        value = data.get('value')
        ttl = data.get('ttl', 3600)  # Default 1 hora

        r = redis.Redis(**REDIS_CONFIG)
        r.set(key, json.dumps(value), ex=ttl)

        return jsonify({
            'status': 'success',
            'key': key,
            'value': value,
            'ttl': ttl
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/redis/get/<key>')
def redis_get(key):
    try:
        r = redis.Redis(**REDIS_CONFIG)
        value = r.get(key)

        if value is None:
            return jsonify({'status': 'not_found', 'key': key}), 404

        try:
            parsed_value = json.loads(value)
        except:
            parsed_value = value

        return jsonify({
            'status': 'success',
            'key': key,
            'value': parsed_value,
            'ttl': r.ttl(key)
        })
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
