#!/bin/bash
ROOT_PATH="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
shopt -s expand_aliases

# alias get_root_path="${ROOT_PATH}/get_root_path/index.sh" 
alias rsyncpull="${ROOT_PATH}/ssh/rsync-pull/index.sh" 
alias rsyncpush="${ROOT_PATH}/ssh/rsync-push/index.sh" 


