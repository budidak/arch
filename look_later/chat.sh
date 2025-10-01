#!/usr/bin/env bash

# -------------------------------------------------
# Ollama + Zenity interactive chat loop
# -------------------------------------------------

MODEL="gpt-oss:20b"

# Check whether a process named “ollama” is already alive
if pgrep -x ollama >/dev/null; then
  echo "Ollama is already running."
else
  echo "Starting Ollama server..."
  # Run it detached from the terminal; redirect output to a log file
  nohup ollama serve >"$HOME/.ollama.log" 2>&1 &
  OLLAMA_PID=$!
  # Give the server a few seconds to bind the socket
  sleep 3
  echo "Ollama started (PID=$OLLAMA_PID)"
fi

# Create a *new* temporary file for this session
# Use a timestamp (or a random suffix) so each run gets its own file
SESSION_FILE=$(mktemp "$HOME/ollama_chat_$(date +%Y%m%d_%H%M%S)_XXXX.log")
echo "=== New chat session started at $(date) ===" >"$SESSION_FILE"

chat_once() {
  # 1️⃣ Ask the user for a prompt
  QUESTION=$(zenity --entry \
    --title="Ollama Chat" \
    --text="Ask the AI:" \
    --width=400)

  # If the user closed the dialog or left it empty → stop the loop
  [[ -z "$QUESTION" ]] && return 1

  # Send the prompt to Ollama and capture the answer
  RESPONSE=$(echo "$QUESTION" | ollama run --hidethinking "$MODEL" 2>/dev/null)

  # ---- build a nicely formatted block -----------------------------
  BLOCK=$(printf "\n----------\nYOU: %s\n\n<span foreground='green'>AI: %s</span>\n" "$QUESTION" "$RESPONSE")

  # ---- append the block to the session file -----------------------
  printf "%s" "$BLOCK" >>"$SESSION_FILE"

  # Show the 'entire' conversation so far
  zenity --text-info --markup \
    --title="Ollama ($MODEL) - Conversation" \
    --filename="$SESSION_FILE" \
    --width=600 \
    --height=400 \
    --ok-label="Ask" >/dev/null

  return 0
}

# -------------------------------------------------
# Main loop – press the window’s “Ask again” button
# (or close the dialog) to get a new prompt.
# -------------------------------------------------
while true; do
  chat_once || break
done

# tell the user where the log was saved
zenity --info \
  --title="Chat saved" \
  --text="Your conversation was saved to:\n$SESSION_FILE" \
  --width=400 \
  --ok-label="Close"
