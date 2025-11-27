FROM node:14-alpine

WORKDIR /app

# Install Python and build tools needed for node-sass
RUN apk add --no-cache python2 make g++

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps --ignore-scripts

COPY . .
RUN npm run build

RUN ls -la
EXPOSE 8080
CMD ["npx", "serve", "-s", "build", "-l", "8080"]