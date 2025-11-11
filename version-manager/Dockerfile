FROM node:20-alpine

WORKDIR /app

COPY package.json ./
RUN npm install --production

COPY api/ ./api/
COPY database/ ./database/

EXPOSE 3000

CMD ["node", "api/server.js"]
