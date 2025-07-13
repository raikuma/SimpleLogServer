# Internet Deployment Guide

This guide explains how to deploy your Simple Log Server to be accessible from the internet.

## Security Considerations

⚠️ **Important Security Notes:**
- The server includes basic rate limiting and security headers
- For production use, consider implementing authentication
- Always use HTTPS in production
- Configure firewall rules appropriately
- Monitor logs for suspicious activity

## Quick Start

### 1. Install Dependencies
```bash
npm install
# or
./deploy.sh install
```

### 2. Basic Internet Deployment
```bash
# Using Docker Compose
./deploy.sh deploy

# Using Windows
deploy.bat deploy
```

### 3. Deployment with Nginx Reverse Proxy
```bash
# With SSL termination and additional security
./deploy.sh deploy-nginx

# Using Windows
deploy.bat deploy-nginx
```

## Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```env
# Server Configuration
PORT=3000
HOST=0.0.0.0
NODE_ENV=production

# Security Configuration
RATE_LIMIT=100
ALLOWED_ORIGINS=https://yourdomain.com,https://api.yourdomain.com

# For development, use:
# ALLOWED_ORIGINS=*
```

### Docker Compose Configuration

The `docker-compose.yml` file includes:
- Main application container
- Optional Nginx reverse proxy
- Volume mounts for persistent logs
- Health checks
- Network isolation

## Cloud Deployment Options

### 1. AWS ECS/Fargate
```bash
# Build production image
./deploy.sh deploy-cloud

# Tag and push to ECR
docker tag simple-log-server:production your-account.dkr.ecr.region.amazonaws.com/simple-log-server:latest
docker push your-account.dkr.ecr.region.amazonaws.com/simple-log-server:latest
```

### 2. Google Cloud Run
```bash
# Build and deploy
docker build -t gcr.io/your-project/simple-log-server .
docker push gcr.io/your-project/simple-log-server
gcloud run deploy --image gcr.io/your-project/simple-log-server --platform managed
```

### 3. Digital Ocean App Platform
```bash
# Push to registry
docker build -t your-registry/simple-log-server .
docker push your-registry/simple-log-server
```

### 4. Heroku
```bash
# Using Heroku CLI
heroku container:push web
heroku container:release web
```

## Port Configuration

The server listens on `0.0.0.0:3000` by default, making it accessible from external networks.

### Firewall Rules

Make sure to configure your firewall to allow:
- Port 3000 (or your configured port)
- Port 80 (HTTP) - if using Nginx
- Port 443 (HTTPS) - if using SSL

## SSL/HTTPS Setup

### Using Let's Encrypt with Nginx

1. Obtain SSL certificates:
```bash
certbot certonly --standalone -d yourdomain.com
```

2. Copy certificates to `./ssl/` directory:
```bash
cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ./ssl/cert.pem
cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ./ssl/key.pem
```

3. Update `nginx.conf` to enable HTTPS section

4. Deploy with Nginx:
```bash
./deploy.sh deploy-nginx
```

## Monitoring and Maintenance

### Health Checks
- Health endpoint: `http://your-server:3000/health`
- Returns server status, uptime, and timestamp

### Logs
```bash
# View application logs
docker-compose logs -f simple-log-server

# View nginx logs
docker-compose logs -f nginx
```

### Backup
```bash
# Backup logs directory
tar -czf backup-$(date +%Y%m%d).tar.gz logs/

# Download logs via API
curl http://your-server:3000/api/logs/download -o logs-backup.zip
```

## API Endpoints

All endpoints are accessible via HTTP/HTTPS:

- `POST /log` - Submit log entry
- `GET /health` - Health check
- `GET /api/logs` - List all log files
- `GET /api/logs/:user_id` - Get specific user logs
- `GET /api/logs/download` - Download all logs as ZIP
- `GET /` - Web viewer interface

## Rate Limiting

Built-in rate limiting:
- Default: 100 requests per minute per IP
- Configurable via `RATE_LIMIT` environment variable
- Additional Nginx rate limiting available

## Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Check what's using the port
   netstat -tulpn | grep :3000
   
   # Change port in .env file
   PORT=3001
   ```

2. **CORS issues**
   ```bash
   # Update ALLOWED_ORIGINS in .env
   ALLOWED_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
   ```

3. **Rate limiting too strict**
   ```bash
   # Increase rate limit in .env
   RATE_LIMIT=200
   ```

### Logs and Debugging

```bash
# Check container logs
docker-compose logs simple-log-server

# Check nginx logs
docker-compose logs nginx

# Check system resources
docker stats
```

## Security Checklist

- [ ] Configure proper CORS origins
- [ ] Set up HTTPS with valid certificates
- [ ] Configure firewall rules
- [ ] Set appropriate rate limits
- [ ] Monitor access logs
- [ ] Regular security updates
- [ ] Implement authentication if needed
- [ ] Regular backups
- [ ] Monitor disk usage for logs

## Performance Optimization

1. **Use Nginx for static file serving**
2. **Configure proper caching headers**
3. **Monitor and rotate log files**
4. **Use CDN for static assets**
5. **Configure connection pooling**

For production deployments, consider implementing:
- Authentication and authorization
- Database backend for logs
- Log rotation and archiving
- Monitoring and alerting
- Load balancing
- Auto-scaling
