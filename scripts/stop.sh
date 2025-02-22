# scripts/stop.sh
#!/bin/bash

# Stop databases based on arguments
for db in "$@"; do
  case $db in
    postgres|