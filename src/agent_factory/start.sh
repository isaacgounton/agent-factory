#!/bin/sh
set -eu

# Set default values for environment variables if not set
: "${FRAMEWORK:=openai}"
: "${MODEL:=o3}"
: "${A2A_SERVER_HOST:=0.0.0.0}"
: "${A2A_SERVER_PORT:=8080}"
: "${LOG_LEVEL:=info}"
: "${CHAT:=1}"
: "${MAX_TURNS:=40}"

# Check if CHAT is set to 1 or 0 and set the chat flag accordingly
if [ "$CHAT" -eq 1 ]; then
    chat_flag="--chat"
else
    chat_flag="--nochat"
fi

# Start the agent server in the background
uv run -m agent_factory \
    --framework "$FRAMEWORK" \
    --model "$MODEL" \
    --host "$A2A_SERVER_HOST" \
    --port "$A2A_SERVER_PORT" \
    --log-level "$LOG_LEVEL" \
    --max-turns "$MAX_TURNS" \
    "$chat_flag" &

# Wait for the agent server to start
sleep 5

# Start the Chainlit web interface on port 8000 (foreground)
exec uv run chainlit run src/agent_factory/chainlit.py --host 0.0.0.0 --port 8000
