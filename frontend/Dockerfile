# frontend/Dockerfile
FROM node:14-alpine AS build
WORKDIR /app
COPY package*.json ./

# install python and build tools
RUN npm install --no-audit

COPY . .
EXPOSE 8080
CMD ["npm", "start"]
