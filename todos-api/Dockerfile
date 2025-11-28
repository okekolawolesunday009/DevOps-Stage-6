FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install 

COPY . .

EXPOSE 8082

# Use the app’s declared start script
CMD ["npm", "start"]
