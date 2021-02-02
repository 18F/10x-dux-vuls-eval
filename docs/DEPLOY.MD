# Deployment Instructions

These are the instructions for deployment the 10x Dependency Upgrades prototype infrastructure for vuls.

# Prerequisites

The following need to be installed with the macOS brew CLI.

- cf
- docker
- golang 1.15.x or newer
- jq
- jinja2-cli
- python3
- pipenv

# Steps

## Build Docker Container

The current public release of the integrated container with all vuls binaries and assorted shell scripts is `ohsh6o/vuls-combined:0.1.0`, or `ohsh6o/vuls-combined:latest` at this time.

To rebuild or build from scratch.

```sh
cd path/to/this/repo/10x-dux-vuls-eval
docker build -t ohsh6o/vuls-combined:0.1.x -t ohsh6o/vuls-combined:latest -f docker/Dockerfile .
docker push ohsh6o/vuls-combined:0.1.x
docker push ohsh6o/vuls-combined:latest
```

## Bootstrap the database environment

Bootstrap the environment from the creation of the necessary RDS database and S3 storage for database backup and restore staging area.

```sh
cd path/to/this/repo/10x-dux-vuls-eval
./scripts/manage.sh setup -o gsa-10x-prototyping -s 10x-dependency-upgrades -a 10x-dux-vuls -e dev
```

Build the scratch db-bootstrap app to perform a preliminary ETL job or the APIs will not load the main micro-services without empty database tables.

```sh
cd path/to/this/repo/10x-dux-vuls-eval
cf push 10x-dux-vuls-db-bootstrap-dev \
        -f db_manifest.yml \
        --health-check-type none \
        --no-route \
        --var app_name=10x-dux-vuls \
        --var environment_name=dev \
        --var default_memory=4G \
        --var default_disk=1G

# This will potentially take 10 minutes to 90 minutes.
cf run-task 10x-dux-vuls-db-bootstrap-dev \
            "/usr/local/bin/etl $DATABASE_URL" \
            --name 10x-dux-vuls-db-dev-setup-$(date '+%Y%m%d%H%M%S')
```

When this is complete, you can use the [cf-service-connect](https://github.com/cloud-gov/cf-service-connect) plugin for the `cf` CLI for a SSH tunnel to validate data.

If validate, you can delete this app.

```sh
cd path/to/this/repo/10x-dux-vuls-eval
cf delete -f 10x-dux-vuls-db-bootstrap-dev 
```

## Deploy the Application

Now, with the backing database, you can deploy the application.

```sh
cd path/to/this/repo/10x-dux-vuls-eval
./scripts/manage.sh deploy -o gsa-10x-prototyping -s 10x-dependency-upgrades -a 10x-dux-vuls -e dev
```

## Backup the Application Data Before or Between Deployments

```sh
cd path/to/this/repo/10x-dux-vuls-eval
cf push 10x-dux-vuls-db-bootstrap-dev \
        -f db_manifest.yml \
        --health-check-type none \
        --no-route \
        --var app_name=10x-dux-vuls \
        --var environment_name=dev \
        --var default_memory=4G \
        --var default_disk=1G

cf run-task 10x-dux-vuls-db-bootstrap-dev \
            "/usr/local/bin/s3backup" \
            --name 10x-dux-vuls-db-dev-setup-$(date '+%Y%m%d%H%M%S')

cf delete -f 10x-dux-vuls-db-bootstrap-dev 
```

## Restore the Application Data

```sh
cd path/to/this/repo/10x-dux-vuls-eval
cf push 10x-dux-vuls-db-bootstrap-dev \
        -f db_manifest.yml \
        --health-check-type none \
        --no-route \
        --var app_name=10x-dux-vuls \
        --var environment_name=dev \
        --var default_memory=4G \
        --var default_disk=1G

cf run-task 10x-dux-vuls-db-bootstrap-dev \
            "/usr/local/bin/s3restore" \
            --name 10x-dux-vuls-db-dev-setup-$(date '+%Y%m%d%H%M%S')

cf delete -f 10x-dux-vuls-db-bootstrap-dev 
```
