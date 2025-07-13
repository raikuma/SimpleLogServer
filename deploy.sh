#!/bin/bash

# Simple Log Server Deployment Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Simple Log Server Deployment${NC}"
echo "=============================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

# Function to install dependencies
install_dependencies() {
    echo -e "${YELLOW}Installing dependencies...${NC}"
    npm install
    echo -e "${GREEN}Dependencies installed successfully!${NC}"
}

# Function to build and deploy with Docker Compose
deploy_with_compose() {
    echo -e "${YELLOW}Building and deploying with Docker Compose...${NC}"
    
    # Create necessary directories
    mkdir -p logs backups ssl
    
    # Build and start services
    docker-compose up -d --build
    
    echo -e "${GREEN}Deployment completed!${NC}"
    echo -e "${BLUE}Services:${NC}"
    echo "  - Log Server: http://localhost:3000"
    echo "  - Health Check: http://localhost:3000/health"
    echo "  - Web Viewer: http://localhost:3000/"
    echo ""
    echo -e "${YELLOW}To view logs: docker-compose logs -f${NC}"
    echo -e "${YELLOW}To stop: docker-compose down${NC}"
}

# Function to deploy with nginx reverse proxy
deploy_with_nginx() {
    echo -e "${YELLOW}Deploying with Nginx reverse proxy...${NC}"
    
    # Create necessary directories
    mkdir -p logs backups ssl
    
    # Start services including nginx
    docker-compose --profile with-nginx up -d --build
    
    echo -e "${GREEN}Deployment with Nginx completed!${NC}"
    echo -e "${BLUE}Services:${NC}"
    echo "  - Nginx Proxy: http://localhost:80"
    echo "  - Direct Access: http://localhost:3000"
    echo "  - Health Check: http://localhost/health"
    echo ""
    echo -e "${YELLOW}Note: Configure SSL certificates in ./ssl/ directory for HTTPS${NC}"
}

# Function to deploy to cloud (basic Docker deployment)
deploy_to_cloud() {
    echo -e "${YELLOW}Preparing for cloud deployment...${NC}"
    
    # Create production environment file
    if [ ! -f .env ]; then
        cp .env.example .env
        echo -e "${YELLOW}Created .env file. Please configure it for production.${NC}"
    fi
    
    # Build production image
    docker build -t simple-log-server:production .
    
    echo -e "${GREEN}Production image built successfully!${NC}"
    echo -e "${BLUE}Next steps for cloud deployment:${NC}"
    echo "1. Push image to container registry:"
    echo "   docker tag simple-log-server:production your-registry/simple-log-server:latest"
    echo "   docker push your-registry/simple-log-server:latest"
    echo ""
    echo "2. Deploy to your cloud provider using the image"
    echo "3. Configure environment variables in your cloud platform"
    echo "4. Set up SSL/TLS certificates"
    echo "5. Configure firewall rules"
}

# Function to show status
show_status() {
    echo -e "${YELLOW}Service Status:${NC}"
    docker-compose ps
    echo ""
    echo -e "${YELLOW}Recent Logs:${NC}"
    docker-compose logs --tail=20
}

# Function to cleanup
cleanup() {
    echo -e "${YELLOW}Cleaning up...${NC}"
    docker-compose down
    docker system prune -f
    echo -e "${GREEN}Cleanup completed!${NC}"
}

# Main menu
case "$1" in
    install)
        install_dependencies
        ;;
    deploy)
        deploy_with_compose
        ;;
    deploy-nginx)
        deploy_with_nginx
        ;;
    deploy-cloud)
        deploy_to_cloud
        ;;
    status)
        show_status
        ;;
    cleanup)
        cleanup
        ;;
    *)
        echo "Usage: $0 {install|deploy|deploy-nginx|deploy-cloud|status|cleanup}"
        echo ""
        echo "Commands:"
        echo "  install       - Install Node.js dependencies"
        echo "  deploy        - Deploy with Docker Compose"
        echo "  deploy-nginx  - Deploy with Nginx reverse proxy"
        echo "  deploy-cloud  - Prepare for cloud deployment"
        echo "  status        - Show service status"
        echo "  cleanup       - Stop services and cleanup"
        echo ""
        echo "Examples:"
        echo "  $0 install"
        echo "  $0 deploy"
        echo "  $0 deploy-nginx"
        exit 1
        ;;
esac
