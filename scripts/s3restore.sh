#!/usr/bin/env sh

set -e -o pipefail

export AWS_S3_BUCKET=$(echo $VCAP_SERVICES | jq -r .s3[0].credentials.bucket)
export AWS_DEFAULT_REGION=$(echo $VCAP_SERVICES | jq -r .s3[0].credentials.region)
export AWS_ACCESS_KEY_ID=$(echo $VCAP_SERVICES | jq -r .s3[0].credentials.access_key_id)
export AWS_SECRET_ACCESS_KEY=$(echo $VCAP_SERVICES | jq -r .s3[0].credentials.secret_access_key)

echo Restore started at $(date '+%Y%m%d%H%M%S')

aws s3 cp s3://${AWS_S3_BUCKET}/backup.sql - | psql $DATABASE_URL

echo Restore completed at $(date '+%Y%m%d%H%M%S')