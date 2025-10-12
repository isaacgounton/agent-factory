#!/bin/bash

# Agent Factory Services Manager
# Usage: ./manage-services.sh [start|stop|restart|logs|status]

set -e

COMPOSE_FILE="docker-compose.yml"

case "${1:-help}" in
    "start")
        echo "🚀 Starting both Agent Factory services..."
        docker-compose -f "$COMPOSE_FILE" up -d
        echo "✅ Services started!"
        echo "📊 A2A API Server: http://localhost:8084"
        echo "🌐 Chainlit Web UI: http://localhost:8004"
        ;;
    "stop")
        echo "🛑 Stopping Agent Factory services..."
        docker-compose -f "$COMPOSE_FILE" down
        echo "✅ Services stopped!"
        ;;
    "restart")
        echo "🔄 Restarting Agent Factory services..."
        docker-compose -f "$COMPOSE_FILE" restart
        echo "✅ Services restarted!"
        ;;
    "logs")
        service="${2:-}"
        if [ -n "$service" ]; then
            echo "📋 Showing logs for $service..."
            docker-compose -f "$COMPOSE_FILE" logs -f "$service"
        else
            echo "📋 Showing logs for all services..."
            docker-compose -f "$COMPOSE_FILE" logs -f
        fi
        ;;
    "status")
        echo "📊 Service Status:"
        docker-compose -f "$COMPOSE_FILE" ps
        ;;
    "help"|*)
        echo "Agent Factory Services Manager"
        echo ""
        echo "Usage: $0 [command] [options]"
        echo ""
        echo "Commands:"
        echo "  start          Start both services"
        echo "  stop           Stop both services"
        echo "  restart        Restart both services"
        echo "  logs [service] Show logs (optionally for specific service)"
        echo "  status         Show service status"
        echo "  help           Show this help"
        echo ""
        echo "Services:"
        echo "  agent-factory-a2a      A2A API Server (port 8084)"
        echo "  agent-factory-chainlit Chainlit Web UI (port 8004)"
        echo ""
        echo "Examples:"
        echo "  $0 start"
        echo "  $0 logs agent-factory-chainlit"
        echo "  $0 stop"
        ;;
esac