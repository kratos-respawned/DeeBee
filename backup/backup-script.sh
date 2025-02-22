# backup/backup-script.sh
#!/bin/bash

# Create timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup"

# Ensure backup directory exists
mkdir -p $BACKUP_DIR

# Backup PostgreSQL
echo "Starting PostgreSQL backup..."
PGPASSWORD=$POSTGRES_PASSWORD pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER $POSTGRES_DB > $BACKUP_DIR/postgres_$TIMESTAMP.sql

# Backup MongoDB
echo "Starting MongoDB backup..."
mongodump --host $MONGO_HOST --username $MONGO_USER --password $MONGO_PASSWORD --out $BACKUP_DIR/mongodb_$TIMESTAMP

# Backup Redis
echo "Starting Redis backup..."
redis-cli -h $REDIS_HOST -a $REDIS_PASSWORD SAVE
cp /data/dump.rdb $BACKUP_DIR/redis_$TIMESTAMP.rdb

# Compress all backups
tar -czf $BACKUP_DIR/backup_$TIMESTAMP.tar.gz $BACKUP_DIR/postgres_$TIMESTAMP.sql $BACKUP_DIR/mongodb_$TIMESTAMP $BACKUP_DIR/redis_$TIMESTAMP.rdb

# Upload to R2/S3
if [ -n "$R2_ENDPOINT" ]; then
    aws --endpoint-url $R2_ENDPOINT s3 cp $BACKUP_DIR/backup_$TIMESTAMP.tar.gz s3://$BUCKET_NAME/backups/backup_$TIMESTAMP.tar.gz
else
    aws s3 cp $BACKUP_DIR/backup_$TIMESTAMP.tar.gz s3://$BUCKET_NAME/backups/backup_$TIMESTAMP.tar.gz
fi

# Cleanup
rm -rf $BACKUP_DIR/postgres_$TIMESTAMP.sql $BACKUP_DIR/mongodb_$TIMESTAMP $BACKUP_DIR/redis_$TIMESTAMP.rdb $BACKUP_DIR/backup_$TIMESTAMP.tar.gz

echo "Backup completed successfully!"

