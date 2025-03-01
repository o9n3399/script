#!/bin/bash

# Set ROOT_PATH directly
ROOT_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# Load .env
if [[ -f "$ROOT_PATH/.env" ]]; then
  source "$ROOT_PATH/.env"
else
  echo "Error: .env file not found in $ROOT_PATH!"
  exit 1
fi

# Convert SERVERS array correctly
SERVERS_ARRAY=("${SERVERS[@]}")

# Function to show available servers
show_servers() {
  echo "Available servers:"
  for key in "${SERVERS_ARRAY[@]}"; do
    echo "  - $key"
  done
}

# Parse options
while getopts "s:l:r:" opt; do
  case $opt in
    s) SERVER_KEY=$OPTARG ;;
    l) SOURCE_PATH=$OPTARG ;;  # Source file/folder to push
    r) REMOTE_DEST=$OPTARG ;;  # Destination on the remote server
    *) echo "Invalid option"; exit 1 ;;
  esac
done

# Ensure required options are provided
if [[ -z "$SERVER_KEY" || -z "$SOURCE_PATH" || -z "$REMOTE_DEST" ]]; then
  echo "Usage: $0 -s <server_key> -l <source_path> -r <remote_destination>"
  show_servers
  exit 1
fi

# Check if server exists
if [[ ! " ${SERVERS_ARRAY[*]} " =~ " $SERVER_KEY " ]]; then
  echo "Error: Server '$SERVER_KEY' not found."
  show_servers
  exit 1
fi

# Retrieve server details
eval "SERVER_DETAILS=\"\${$SERVER_KEY}\""
read -r USER_HOST PASSWORD PORT <<< "$SERVER_DETAILS"

# Execute rsync
sshpass -p "$PASSWORD" rsync -avz --progress -e "ssh -p $PORT" "$SOURCE_PATH" "$USER_HOST:$REMOTE_DEST"

if [[ $? -eq 0 ]]; then
  echo "✅ Push successful!"
else
  echo "❌ Push failed!"
fi
