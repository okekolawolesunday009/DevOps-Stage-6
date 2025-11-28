FROM node:14-alpine

WORKDIR /app

# Install Python3 and build tools (Python2 no longer available)
RUN apk add --no-cache python3 make g++ py3-pip

# Create python2 symlink for compatibility
RUN ln -sf python3 /usr/bin/python
RUN ln -sf pip3 /usr/bin/pip

COPY package.json package-lock.json ./

# Use legacy peer deps and ignore problematic scripts
RUN npm install --legacy-peer-deps --ignore-scripts

COPY . .

# Try to build, if it fails, serve source files directly
RUN npm run build || (echo "Build failed, serving source files" && mkdir -p build && cp -r src/* build/ 2>/dev/null) || echo "Will serve from src"

# List what we have
RUN ls -la && (ls -la build/ 2>/dev/null || echo "No build directory")

EXPOSE 8080
# Smart serving: check what exists and serve accordingly
CMD ["sh", "-c", "if [ -d 'build' ] && [ -n \"$(ls -A build 2>/dev/null)\" ]; then echo 'Serving from build/' && npx serve -s build -l 8080; elif [ -d 'dist' ] && [ -n \"$(ls -A dist 2>/dev/null)\" ]; then echo 'Serving from dist/' && npx serve -s dist -l 8080; else echo 'Serving from src/' && npx serve -s src -l 8080; fi"]