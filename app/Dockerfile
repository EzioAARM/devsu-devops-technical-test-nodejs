FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 8000

ENTRYPOINT ["node"]
CMD ["index.js"]
    