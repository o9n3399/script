#!/bin/bash
ROOT_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
shopt -s expand_aliases

# Load .env file from root path
if [[ -f "$ROOT_PATH/.env" ]]; then
  source "$ROOT_PATH/.env"
else
  echo "Error: .env file not found in $ROOT_PATH!"
  exit 1
fi

# Convert SERVERS string into an actual array
eval "SERVERS_ARRAY=(${SERVERS[@]})"

# Function to show available servers
show_servers() {
  echo "Available servers:"
  for key in "${SERVERS_ARRAY[@]}"; do
    echo "  - $key"
  done
}

# Parse options
while getopts "s:r:l:" opt; do
  case $opt in
    s) SERVER_KEY=$OPTARG ;;
    r) REMOTE_PATH=$OPTARG ;;
    l) LOCAL_DEST=$OPTARG ;;
    *) echo "Invalid option"; exit 1 ;;
  esac
done

# Ensure required options are provided
if [[ -z "$SERVER_KEY" || -z "$REMOTE_PATH" || -z "$LOCAL_DEST" ]]; then
  echo "Usage: $0 -s <server_key> -r <remote_path> -l <local_destination>"
  show_servers
  exit 1
fi

# Check if the server exists in the array
if [[ ! " ${SERVERS_ARRAY[*]} " =~ " $SERVER_KEY " ]]; then
  echo "Error: Server '$SERVER_KEY' not found."
  show_servers
  exit 1
fi

# Retrieve server details dynamically
SERVER_DETAILS="${!SERVER_KEY}"
read -r USER_HOST PASSWORD PORT <<< "$SERVER_DETAILS"

# Execute rsync with sshpass to pull the file/folder
echo "Pulling '$REMOTE_PATH' from '$USER_HOST' to '$LOCAL_DEST' on port $PORT..."
sshpass -p "$PASSWORD" rsync -avz -e "ssh -p $PORT" "$USER_HOST:$REMOTE_PATH" "$LOCAL_DEST"

if [[ $? -eq 0 ]]; then
  echo "✅ Pull successful!"
else
  echo "❌ Pull failed!"
fi

