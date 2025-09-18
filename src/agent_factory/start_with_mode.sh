#!/bin/sh
set -eu

# Set default values for environment variables if not set
: "${FRAMEWORK:=tinyagent}"
: "${MODEL:=openai/o3}"
: "${A2A_SERVER_HOST:=0.0.0.0}"
: "${A2A_SERVER_PORT:=8080}"
: "${LOG_LEVEL:=info}"
: "${CHAT:=1}"
: "${MAX_TURNS:=40}"
: "${START_MODE:=a2a}"  # Default to A2A server

# Check if CHAT is set to 1 or 0 and set the chat flag accordingly
if [ "$CHAT" -eq 1 ]; then
    chat_flag="--chat"
else
    chat_flag="--nochat"
fi

case "$START_MODE" in
    "chainlit")
        echo "Starting Agent Factory with Chainlit web interface on port 8000..."
        # Set Chainlit to run on port 8000 (exposed by Dockerfile)
        export CHAINLIT_PORT=8000
        exec uv run -m agent_factory.chainlit
        ;;
    "a2a")
        echo "Starting Agent Factory A2A server on port 8080..."
        exec uv run -m agent_factory \
            --framework "$FRAMEWORK" \
            --model "$MODEL" \
            --host "$A2A_SERVER_HOST" \
            --port "$A2A_SERVER_PORT" \
            --log-level "$LOG_LEVEL" \
            --max-turns "$MAX_TURNS" \
            "$chat_flag"
        ;;
    *)
        echo "Invalid START_MODE: $START_MODE. Use 'a2a' or 'chainlit'"
        exit 1
        ;;
esac