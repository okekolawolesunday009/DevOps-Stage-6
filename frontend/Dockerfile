FROM node:18-alpine

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build

RUN ls -la
EXPOSE 8080
CMD ["npx", "serve", "-s", "build", "-l", "8080"]