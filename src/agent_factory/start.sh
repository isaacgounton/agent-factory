#!/bin/sh
set -eu

# Add better error handling
trap 'echo "Error occurred at line $LINENO"; exit 1' ERR

# Set default values for environment variables if not set
: "${FRAMEWORK:=openai}"
: "${MODEL:=o3}"
: "${A2A_SERVER_HOST:=0.0.0.0}"
: "${A2A_SERVER_PORT:=8080}"
: "${CHAINLIT_PORT:=8000}"
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
echo "Starting agent server on port $A2A_SERVER_PORT..."
uv run -m agent_factory \
    --framework "$FRAMEWORK" \
    --model "$MODEL" \
    --host "$A2A_SERVER_HOST" \
    --port "$A2A_SERVER_PORT" \
    --log-level "$LOG_LEVEL" \
    --max-turns "$MAX_TURNS" \
    "$chat_flag" &

AGENT_PID=$!

# Wait for the agent server to start
sleep 5

# Wait for agent server to be ready
echo "Waiting for agent server to start..."
timeout=30
counter=0
while ! curl -s http://localhost:$A2A_SERVER_PORT/.well-known/agent.json > /dev/null 2>&1; do
  if [ $counter -ge $timeout ]; then
    echo "Timeout waiting for agent server. Checking if it's still running..."
    if ! kill -0 $AGENT_PID 2>/dev/null; then
      echo "Agent server process has died. Exiting."
      exit 1
    fi
  fi
  sleep 1
  counter=$((counter + 1))
done
echo "Agent server is ready!"

# Start the Chainlit web interface (foreground)
echo "Starting Chainlit on port $CHAINLIT_PORT..."
exec uv run chainlit run chainlit.py --host 0.0.0.0 --port "$CHAINLIT_PORT"
