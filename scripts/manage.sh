#!/bin/bash
#
# This script will bootstrap the creation of a cloud.gov deployment
# environment.
#

set -eo pipefail

APP_DB_SERVICE=db
APP_DB_SERVICE_KEY=${APP_DB_SERVICE}-service-key
RDSTYPE=shared-psql
APP_STORAGE_SERVICE=data
APP_STORAGE_SERVICE_KEY=${APP_STORAGE_SERVICE}-service-key
S3BUCKETTYPE=basic

usage()
{
    cat << EOF
Manage a cloud.gov deployment environment.

Usage: manage.sh <OPERATION> -o <cloud.gov organization name> -s <cloud.gov space name>

OPERATION:
    setup   - create a new cloud.gov space, login.gov certificate, and strapi secrets
    show    - show Terraform S3 and cloud.gov credentials
    export  - when used with source, exports credentials to the environment
    deploy  - deploy the locally-built application via Terraform
    rotate  - replace current secrets with new secrets

Options:
  -o, --organization organization_name   Cloud.gov organization name
  -s, --space space_name                 Cloud.gov space name
  -e, --environment environment_name     Cloud.gov app and service instance suffix
  -a, --application app_name             Cloud.gov application name
  -h                                     Print usage
EOF
}

validate_parameters()
{
  if [ -z ${operation+x} ]; then
    printf "${RED}Please supply an operation.\n${NC}"
    usage
    exit 1
  fi

  if [ -z ${organization_name+x} ]; then
    printf "${RED}Please provide an organization name.\n${NC}"
    usage
    exit 1
  fi

  if [ -z ${space_name+x} ]; then
    printf "${RED}Please provide a space name.\n${NC}"
    usage
    exit 1
  fi

  if [ -z ${environment_name+x} ]; then
    printf "${RED}Please provide an environment name.\n${NC}"
    usage
    exit 1
  fi

  if [ -z ${app_name+x} ]; then
    printf "${RED}Please provide an app name.\n${NC}"
    usage
    exit 1
  fi
}

space_exists() {
  cf space "$1" >/dev/null 2>&1
}

service_exists() {
  cf service "$1" >/dev/null 2>&1
}

service_key_exists() {
  cf service-key "$1" "$2" >/dev/null 2>&1
}

export_app_storage_key() {
  echo "Querying for ${app_name}-${APP_STORAGE_SERVICE}-${environment_name} ..."
  SKEY=$(cf service-key ${app_name}-${APP_STORAGE_SERVICE}-${environment_name} ${app_name}-${APP_STORAGE_SERVICE_KEY}-${environment_name} | tail -n +2)
  echo "Exporting ${app_name}-${APP_STORAGE_SERVICE}-${environment_name} S3 AWS credentials..."
  export AWS_ACCESS_KEY_ID=$(echo $SKEY | jq -r .access_key_id)
  export AWS_SECRET_ACCESS_KEY=$(echo $SKEY | jq -r .secret_access_key)
  export AWS_DEFAULT_REGION=$(echo $SKEY | jq -r .region)
  export BUCKET_NAME=$(echo $SKEY | jq -r .bucket)
}

export_service_key() {
  echo "Querying for ${app_name}-${APP_DB_SERVICE}-${environment_name} ..."
  DBKEY=$(cf service-key ${app_name}-${APP_DB_SERVICE}-${environment_name} ${app_name}-${APP_DB_SERVICE_KEY}-${environment_name} | tail -n +2)
  echo "Exporting ${app_name}-${APP_DB_SERVICE_KEY}-${environment_name} for DB credentials"
  export DATABASE_URL=$(echo $DBKEY | jq -r .uri)
}

export_environment() {
  export_app_storage_key
  export_service_key
}

setup() {
  if space_exists "${space_name}" ; then
    echo space "${space_name}" already created
  else
    cf create-space ${space_name} -o ${organization_name}
  fi

  if service_exists "${app_name}-${APP_DB_SERVICE}-${environment_name}" ; then
    echo ${app_name}-${APP_DB_SERVICE}-${environment_name} already created
  else
    cf create-service aws-rds ${RDSTYPE} ${app_name}-${APP_DB_SERVICE}-${environment_name}
  fi

if service_exists "${app_name}-${APP_STORAGE_SERVICE}-${environment_name}" ; then
    echo space "${app_name}-${APP_STORAGE_SERVICE}-${environment_name}" already created
  else
    cf create-service s3 "${S3BUCKETTYPE}" "${app_name}-${APP_STORAGE_SERVICE}-${environment_name}"
  fi

  setup_keys

  export_environment
  aws s3api put-bucket-versioning --bucket ${BUCKET_NAME} --versioning-configuration Status=Enabled

}

setup_keys() {
  if service_key_exists "${app_name}-${APP_DB_SERVICE}-${environment_name}" "${app_name}-${APP_DB_SERVICE_KEY}-${environment_name}" ; then
    echo ${app_name}-${APP_DB_SERVICE_KEY}-${environment_name} already created
  else
    echo "Creating ${app_name}-${APP_DB_SERVICE_KEY}-${environment_name}..."
    cf create-service-key "${app_name}-${APP_DB_SERVICE}-${environment_name}" "${app_name}-${APP_DB_SERVICE_KEY}-${environment_name}"
  fi

  if service_key_exists "${app_name}-${APP_STORAGE_SERVICE}-${environment_name}" "${app_name}-${APP_STORAGE_SERVICE}-${environment_name}" ; then
    echo "${app_name}-${APP_STORAGE_SERVICE_KEY}-${environment_name}" already created
  else
    echo "Creating "${app_name}-${APP_STORAGE_SERVICE}-${environment_name}"..."
    cf create-service-key "${app_name}-${APP_STORAGE_SERVICE}-${environment_name}" "${app_name}-${APP_STORAGE_SERVICE_KEY}-${environment_name}"
  fi

  echo "To see service keys, execute './deployment/manage.sh'"
}

update_keys() {
  if service_key_exists "${app_name}-${APP_DB_SERVICE}-${environment_name}" "${app_name}-${APP_DB_SERVICE_KEY}-${environment_name}" ; then
      echo ${APP_DB_SERVICE_KEY}-${environment_name} exists, deleting and recreating
      cf delete-service-key ${app_name}-${APP_DB_SERVICE}-${environment_name} ${app_name}-${APP_DB_SERVICE_KEY}-${environment_name}
      cf create-service-key ${app_name}-${APP_DB_SERVICE}-${environment_name} ${app_name}-${APP_DB_SERVICE_KEY}-${environment_name}
  else
      echo {app_name}-${APP_DB_SERVICE}-${environment_name} does not exist
  fi

  if service_key_exists "${APP_STORAGE_SERVICE}" "${APP_STORAGE_SERVICE_KEY}" ; then
      echo ${app_name}-${APP_STORAGE_SERVICE_KEY}-${environment_name} exists, deleting and recreating
      cf delete-service-key ${app_name}-${APP_STORAGE_SERVICE}-${environment_name} ${app_name}-${APP_STORAGE_SERVICE_KEY}-${environment_name}
      cf create-service-key ${app_name}-${APP_STORAGE_SERVICE}-${environment_name} ${app_name}-${APP_STORAGE_SERVICE_KEY}-${environment_name}
  else
      echo ${app_name}-${APP_STORAGE_SERVICE_KEY}-${environment_name} does not exist
  fi
}

print_db_details() {
  cf service-key ${app_name}-${APP_DB_SERVICE}-${environment_name} ${app_name}-${APP_DB_SERVICE_KEY}-${environment_name}
}

print_bucket_details() {
  export_app_storage_key
  aws s3api get-bucket-encryption --bucket $BUCKET_NAME
  aws s3api get-bucket-versioning --bucket $BUCKET_NAME
}

print_terraform_storage_key() {
  cf service-key ${app_name}-${APP_STORAGE_SERVICE}-${environment_name} ${app_name}-${APP_STORAGE_SERVICE_KEY}-${environment_name}
}

show() {
  print_db_details
  print_terraform_storage_key
  print_bucket_details
}

deploy() {
  export_environment

  echo Deploying database bootstraping task
  cf push ${app_name}-db-bootstrap-${environment_name} \
            -f db_manifest.yml \
            --health-check-type none \
            --no-route \
            --var app_name=${app_name} \
            --var environment_name=${environment_name} \
            --var default_memory=4G \
            --var default_disk=1G

  echo Restore from backup
  cf run-task ${app_name}-db-bootstrap-${environment_name} \
            "/usr/local/bin/s3restore" \
            --name ${app_name}-db-${environment_name}-backup-$(date '+%Y%m%d%H%M%S')

  echo Waiting for 5 minutes
  #sleep 120

  config_data=$(jinja2 docker/vuls/config.toml -D app_name=${app_name} -D environment_name=${environment_name} | base64)

  echo Deploy application stack
  cf push -f manifest.yml \
        --var app_name=${app_name} \
        --var environment_name=${environment_name}  \
        --var default_memory=256M \
        --var default_disk=1G \
        --var default_instances=1 \
        --var config_data="${config_data}" \
        --var config_local_path=/tmp/config.toml

  echo Deployment complete, removing databootstrap container.
  cf delete -f ${app_name}-db-bootstrap-${environment_name}
}

rotate() {
  cat << EOF


You need to update CI/CD github secrets with ./manage.sh show
EOF
}

while [ "$1" != "" ]; do
  case $1 in
    rotate | setup | show | export | deploy )  operation=$1
                                ;;
    -o | --organization )       shift
                                organization_name=$1
                                ;;
    -s | --space )              shift
                                space_name=$1
                                ;;
    -e | --environment )        shift
                                environment_name=$1
                                ;;
    -a | --application )        shift
                                app_name=$1
                                ;;
    -h | --help )               usage
                                exit
                                ;;
    * )                         usage
                                exit 1
  esac
  shift
done

validate_parameters

# Target all operations to the provided organization/space pair.
cf target -o ${organization_name} -s ${space_name}

case $operation in
  rotate )                        rotate 
                                  ;;
  setup )                         setup
                                  ;;
  show )                          show
                                  ;;
  export )                        export_environment
                                  ;;
  deploy )                        deploy
                                  ;;
  * )                             usage
                                  exit 1
esac
