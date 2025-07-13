@echo off
setlocal enabledelayedexpansion

REM Simple Log Server Deployment Script for Windows

echo Simple Log Server Deployment
echo ==============================

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo Docker is not installed. Please install Docker first.
    pause
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if errorlevel 1 (
    docker compose version >nul 2>&1
    if errorlevel 1 (
        echo Docker Compose is not installed. Please install Docker Compose first.
        pause
        exit /b 1
    )
)

REM Handle command line arguments
if "%1"=="install" goto install_dependencies
if "%1"=="deploy" goto deploy_with_compose
if "%1"=="deploy-nginx" goto deploy_with_nginx
if "%1"=="deploy-cloud" goto deploy_to_cloud
if "%1"=="status" goto show_status
if "%1"=="cleanup" goto cleanup

echo Usage: %0 {install^|deploy^|deploy-nginx^|deploy-cloud^|status^|cleanup}
echo.
echo Commands:
echo   install       - Install Node.js dependencies
echo   deploy        - Deploy with Docker Compose
echo   deploy-nginx  - Deploy with Nginx reverse proxy
echo   deploy-cloud  - Prepare for cloud deployment
echo   status        - Show service status
echo   cleanup       - Stop services and cleanup
echo.
echo Examples:
echo   %0 install
echo   %0 deploy
echo   %0 deploy-nginx
exit /b 1

:install_dependencies
echo Installing dependencies...
npm install
if errorlevel 1 (
    echo Failed to install dependencies
    pause
    exit /b 1
)
echo Dependencies installed successfully!
goto end

:deploy_with_compose
echo Building and deploying with Docker Compose...

REM Create necessary directories
if not exist logs mkdir logs
if not exist backups mkdir backups
if not exist ssl mkdir ssl

REM Build and start services
docker-compose up -d --build
if errorlevel 1 (
    echo Failed to deploy services
    pause
    exit /b 1
)

echo Deployment completed!
echo Services:
echo   - Log Server: http://localhost:3000
echo   - Health Check: http://localhost:3000/health
echo   - Web Viewer: http://localhost:3000/
echo.
echo To view logs: docker-compose logs -f
echo To stop: docker-compose down
goto end

:deploy_with_nginx
echo Deploying with Nginx reverse proxy...

REM Create necessary directories
if not exist logs mkdir logs
if not exist backups mkdir backups
if not exist ssl mkdir ssl

REM Start services including nginx
docker-compose --profile with-nginx up -d --build
if errorlevel 1 (
    echo Failed to deploy services with Nginx
    pause
    exit /b 1
)

echo Deployment with Nginx completed!
echo Services:
echo   - Nginx Proxy: http://localhost:80
echo   - Direct Access: http://localhost:3000
echo   - Health Check: http://localhost/health
echo.
echo Note: Configure SSL certificates in ./ssl/ directory for HTTPS
goto end

:deploy_to_cloud
echo Preparing for cloud deployment...

REM Create production environment file
if not exist .env (
    copy .env.example .env
    echo Created .env file. Please configure it for production.
)

REM Build production image
docker build -t simple-log-server:production .
if errorlevel 1 (
    echo Failed to build production image
    pause
    exit /b 1
)

echo Production image built successfully!
echo Next steps for cloud deployment:
echo 1. Push image to container registry:
echo    docker tag simple-log-server:production your-registry/simple-log-server:latest
echo    docker push your-registry/simple-log-server:latest
echo.
echo 2. Deploy to your cloud provider using the image
echo 3. Configure environment variables in your cloud platform
echo 4. Set up SSL/TLS certificates
echo 5. Configure firewall rules
goto end

:show_status
echo Service Status:
docker-compose ps
echo.
echo Recent Logs:
docker-compose logs --tail=20
goto end

:cleanup
echo Cleaning up...
docker-compose down
docker system prune -f
echo Cleanup completed!
goto end

:end
if "%1"=="" pause
exit /b 0
