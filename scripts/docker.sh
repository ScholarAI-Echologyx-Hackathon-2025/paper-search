#!/bin/bash

# Scholar AI Paper Search Docker Management Script
# This script provides commands to build, run, test, and manage the Docker containerized Paper Search

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="scholar-paper-search"
CONTAINER_NAME="scholar-paper-search"
IMAGE_NAME="scholar-paper-search:latest"
COMPOSE_FILE="docker-compose.yml"
DEFAULT_PORT=8001

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    
    if ! docker-compose version > /dev/null 2>&1; then
        print_error "Docker Compose is not available. Please install Docker Compose and try again."
        exit 1
    fi
    
    print_success "Docker and Docker Compose are available"
}

# Create Docker network if it doesn't exist
create_network() {
    if ! docker network ls | grep -q "docker_scholarai-network"; then
        print_status "Creating Docker network..."
        docker network create docker_scholarai-network
        print_success "Docker network created successfully!"
    else
        print_status "Network scholarai-network already exists"
    fi
}

# Function to build the Docker image
build() {
    print_status "Building Docker image for $APP_NAME..."
    
    create_network
    
    # Build the image
    docker-compose build
    
    print_success "Docker image built successfully!"
}

# Function to rebuild the Docker image without cache
rebuild_nocache() {
    print_status "Rebuilding Docker image for $APP_NAME without cache..."
    
    create_network
    
    # Remove existing image first
    docker-compose down --rmi all
    
    # Build fresh image without cache
    docker-compose build --no-cache --pull
    
    print_success "Docker image rebuilt successfully without cache!"
}

# Function to start the container
run() {
    print_status "Starting $APP_NAME container..."
    
    create_network
    
    # Start the container
    docker-compose up -d
    
    # Wait for container to be ready
    print_status "Waiting for container to be ready..."
    sleep 10
    
    # Check if container is running
    if docker ps | grep -q "$CONTAINER_NAME"; then
        print_success "Container started successfully!"
        print_status "$APP_NAME is available at http://localhost:$DEFAULT_PORT"
    else
        print_error "Container failed to start. Check logs with: docker-compose logs"
        exit 1
    fi
}

# Function to stop the container
stop() {
    print_status "Stopping $APP_NAME container..."
    
    docker-compose down
    
    print_success "Container stopped successfully!"
}

# Function to restart the container
restart() {
    print_status "Restarting $APP_NAME container..."
    
    stop
    run
    
    print_success "Container restarted successfully!"
}

# Function to view logs
logs() {
    print_status "Showing logs for $APP_NAME..."
    
    docker-compose logs -f
}

# Function to check container status
status() {
    print_status "Checking status of $APP_NAME..."
    
    if docker ps | grep -q "$CONTAINER_NAME"; then
        print_success "Container is running"
        docker ps | grep "$CONTAINER_NAME"
    else
        print_warning "Container is not running"
    fi
}

# Function to clean up
cleanup() {
    print_status "Cleaning up $APP_NAME..."
    
    docker-compose down --rmi all --volumes --remove-orphans
    
    print_success "Cleanup completed!"
}

# Function to show help
show_help() {
    echo -e "${CYAN}Scholar AI Paper Search Docker Management Script${NC}"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  build                    Build the Docker image"
    echo "  rebuild-nocache          Rebuild the Docker image without cache"
    echo "  run                      Start the container"
    echo "  stop                     Stop the container"
    echo "  restart                  Restart the container"
    echo "  logs                     View container logs"
    echo "  status                   Check container status"
    echo "  cleanup                  Clean up containers, images, and volumes"
    echo "  help                     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build                 Build the image"
    echo "  $0 run                   Start the service"
    echo "  $0 logs                  View logs"
}

# Main function
main() {
    check_docker
    
    case "${1:-help}" in
        "build")
            build
            ;;
        "rebuild-nocache")
            rebuild_nocache
            ;;
        "run")
            run
            ;;
        "stop")
            stop
            ;;
        "restart")
            restart
            ;;
        "logs")
            logs
            ;;
        "status")
            status
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function
main "$@"
