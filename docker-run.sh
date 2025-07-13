#!/bin/bash

# Simple Log Server Docker Run Script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

IMAGE_NAME="simple-log-server"
CONTAINER_NAME="simple-log-server"
PORT=3333

echo -e "${GREEN}Simple Log Server Docker Runner${NC}"
echo "=================================="

# Function to build the image
build_image() {
    echo -e "${YELLOW}Building Docker image...${NC}"
    docker build -t $IMAGE_NAME .
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Image built successfully!${NC}"
    else
        echo -e "${RED}Failed to build image${NC}"
        exit 1
    fi
}

# Function to run container (basic)
run_basic() {
    echo -e "${YELLOW}Starting container (basic mode)...${NC}"
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PORT:3333 \
        $IMAGE_NAME
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Container started successfully!${NC}"
        echo "Server available at: http://localhost:$PORT"
    else
        echo -e "${RED}Failed to start container${NC}"
    fi
}

# Function to run container with persistent logs
run_with_logs() {
    echo -e "${YELLOW}Starting container with persistent logs...${NC}"
    
    # Create logs directory if it doesn't exist
    mkdir -p ./logs
    
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PORT:3333 \
        -v "$(pwd)/user_logs:/app/user_logs" \
        $IMAGE_NAME
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Container started with persistent logs!${NC}"
        echo "Server available at: http://localhost:$PORT"
        echo "Logs will be saved to: ./user_logs"
    else
        echo -e "${RED}Failed to start container${NC}"
    fi
}

# Function to run container interactively
run_interactive() {
    echo -e "${YELLOW}Starting container in interactive mode...${NC}"
    docker run -it \
        --name $CONTAINER_NAME \
        -p $PORT:3333 \
        -v "$(pwd)/user_logs:/app/user_logs" \
        $IMAGE_NAME
}

# Function to stop and remove container
stop_container() {
    echo -e "${YELLOW}Stopping and removing container...${NC}"
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
    echo -e "${GREEN}Container stopped and removed${NC}"
}

# Function to view logs
view_logs() {
    echo -e "${YELLOW}Container logs:${NC}"
    docker logs $CONTAINER_NAME
}

# Function to show container status
show_status() {
    echo -e "${YELLOW}Container status:${NC}"
    docker ps -a --filter "name=$CONTAINER_NAME"
}

# Main menu
show_menu() {
    echo ""
    echo "Choose an option:"
    echo "1) Build image"
    echo "2) Run (basic)"
    echo "3) Run with persistent logs"
    echo "4) Run interactive"
    echo "5) Stop container"
    echo "6) View logs"
    echo "7) Show status"
    echo "8) Exit"
    echo ""
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# If arguments provided, run specific command
case "$1" in
    build)
        build_image
        ;;
    run)
        stop_container
        run_with_logs
        ;;
    basic)
        stop_container
        run_basic
        ;;
    interactive)
        stop_container
        run_interactive
        ;;
    stop)
        stop_container
        ;;
    logs)
        view_logs
        ;;
    status)
        show_status
        ;;
    *)
        # Interactive mode
        while true; do
            show_menu
            read -p "Enter your choice [1-8]: " choice
            case $choice in
                1)
                    build_image
                    ;;
                2)
                    stop_container
                    run_basic
                    ;;
                3)
                    stop_container
                    run_with_logs
                    ;;
                4)
                    stop_container
                    run_interactive
                    ;;
                5)
                    stop_container
                    ;;
                6)
                    view_logs
                    ;;
                7)
                    show_status
                    ;;
                8)
                    echo -e "${GREEN}Goodbye!${NC}"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}Invalid option. Please choose 1-8.${NC}"
                    ;;
            esac
        done
        ;;
esac
