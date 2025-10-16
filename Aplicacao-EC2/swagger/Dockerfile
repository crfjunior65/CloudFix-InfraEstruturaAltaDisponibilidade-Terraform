# Use a imagem oficial do Node.js
FROM node:18-alpine

# Defina o diretório de trabalho
WORKDIR /app

# Copie package.json e package-lock.json
COPY package*.json ./

# Instale as dependências
# Instale o Swagger UI Express e dependências do OpenAPI
RUN npm install \
    swagger-ui-express@4.6.2 \
    swagger-jsdoc@4.18.2 \
    yamljs@0.0.17


# Copie o código da aplicação
COPY . .

# Instale o Swagger UI Express e dependências do OpenAPI
#RUN npm install swagger-ui-express swagger-jsdoc yamljs

# Exponha a porta
EXPOSE 3000

# Comando para iniciar a aplicação
CMD ["node", "app.js"]
