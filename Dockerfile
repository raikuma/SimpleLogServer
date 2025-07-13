# Use the official Node.js runtime as the base image
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy the rest of the application code
COPY . .

# Create user_logs directory and ensure proper permissions
RUN mkdir -p user_logs && chmod 777 user_logs

# Create a non-root user to run the application (optional, but we'll run as root for simplicity)
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Change ownership of the app directory to the nodejs user
RUN chown -R nextjs:nodejs /app

# For simplicity and to avoid permission issues with volume mounts, run as root
# USER nextjs

# Expose the port the app runs on
EXPOSE 3333

# Define environment variable
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "const http = require('http'); \
  const options = { \
    host: 'localhost', \
    port: 3333, \
    path: '/health', \
    timeout: 2000, \
  }; \
  const request = http.request(options, (res) => { \
    console.log('STATUS: ' + res.statusCode); \
    process.exitCode = res.statusCode === 200 ? 0 : 1; \
  }); \
  request.on('error', function(err) { \
    console.log('ERROR'); \
    process.exitCode = 1; \
  }); \
  request.end();"

# Command to run the application
CMD ["npm", "start"]
