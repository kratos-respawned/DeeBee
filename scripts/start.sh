# scripts/start.sh
#!/bin/bash

# Start core services
docker compose --profile core up -d

# Start databases based on arguments
for db in "$@"; do
  case $db in
    postgres|redis|mongodb)
      cd $db && docker compose up -d && cd ..
      ;;
    *)
      echo "Unknown database: $db"
      ;;
  esac
done

# Start backup if any database is running
if [ $# -gt 0 ]; then
  cd backup && docker compose up -d && cd ..
fi

