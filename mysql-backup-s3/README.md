# mysql-backup-s3

Periodically dump one or more MySQL/MariaDB databases and upload the dumps to S3 (or any S3-compatible service, e.g. [MinIO](https://minio.io)), using AWS CLI v2. Also includes a `restore.sh` script to pull a dump back down and import it.

Based on [schickling/dockerfiles](https://github.com/schickling/dockerfiles) and [f213/mysql-backup-s3](https://github.com/f213/mysql-backup-s3/tree/master).

## Basic usage

```sh
$ docker run \
    -e DATABASE_HOST=localhost \
    -e DATABASE_USER=user \
    -e DATABASE_PASSWORD=password \
    -e S3_ACCESS_KEY_ID=key \
    -e S3_SECRET_ACCESS_KEY=secret \
    -e S3_BUCKET=my-bucket \
    -e S3_PREFIX=backup \
    dzangolab/mysql-backup-s3
```

This dumps every database on the server (the default for `DATABASES`) and uploads one gzip-compressed file per database to S3.

## How backups are stored

For each database `<db>` being backed up, `backup.sh` uploads to:

```
s3://<S3_BUCKET>/<S3_PREFIX>/<db>/<year>/<month>/<db>[.<DATABASE_VERSION>].<timestamp>.sql.gz[.enc]
```

- `<timestamp>` is an ISO-8601-like timestamp (`%Y-%m-%dT%H:%M:%SZ`), so keys sort chronologically.
- The `.enc` suffix is appended only if `ENCRYPTION_PASSWORD` is set.

`restore.sh` relies on this naming convention to find the most recent backup for a database (see below).

## Environment variables

### Database connection

- `DATABASE_HOST` the database host *(required)*
- `DATABASE_PORT` the database port (default: `3306`)
- `DATABASE_USER` the database user *(required)*
- `DATABASE_PASSWORD` the database password *(required)*
- `DATABASE_PASSWORD_FILE` path to a file containing the database password; alternative to `DATABASE_PASSWORD` (Docker secret support)
- `DATABASES` comma-separated list of databases to back up, or `ALL` to back up every database except `information_schema`, `performance_schema`, `mysql`, `sys` and `innodb` (default: `ALL`)
- `DATABASE_VERSION` optional tag inserted into the backup filename, useful when running the same backup job against multiple schema versions

### S3 / object storage

- `S3_BUCKET` the S3 bucket to upload backups to / restore from *(required)*
- `S3_PREFIX` key prefix under the bucket (optional)
- `S3_REGION` the AWS region (default: `us-west-1`)
- `S3_ENDPOINT` a custom S3 endpoint URL, for S3-compatible services such as [MinIO](https://minio.io) (optional)
- `S3_S3V4` set to `yes` to enable AWS Signature Version 4, required by some S3-compatible servers such as [MinIO](https://minio.io) (default: `no`)
- `S3_IAMROLE` set to `true` to use the container's IAM role instead of access keys (default: `false`)
- `S3_ACCESS_KEY_ID` your AWS access key; required unless `S3_IAMROLE=true`
- `S3_ACCESS_KEY_ID_FILE` path to a file containing your AWS access key; alternative to `S3_ACCESS_KEY_ID`
- `S3_SECRET_ACCESS_KEY` your AWS secret key; required unless `S3_IAMROLE=true`
- `S3_SECRET_ACCESS_KEY_FILE` path to a file containing your AWS secret key; alternative to `S3_SECRET_ACCESS_KEY`

Any environment variable can be provided as a `_FILE` variant (e.g. `DATABASE_PASSWORD_FILE`) pointing to a file under `/run/secrets/`, in line with the [`dzangolab/docker-secrets`](https://github.com/dzangolab/dockerfiles/tree/main/docker-secrets) convention used by this image.

### Encryption

- `ENCRYPTION_PASSWORD` if set, each dump is encrypted with `openssl enc -aes-256-cbc` before upload, using this password. The same password is required to decrypt during restore.

### Scheduling

- `SCHEDULE` cron-style schedule (e.g. `@daily`) to run backups automatically. If unset, the backup runs once and the container exits.

More information about the scheduling format can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

## Restoring a backup

Run `restore.sh` inside a container based on this image (it needs the same `DATABASE_*` and `S3_*` environment variables as the backup). It takes a single argument:

- If the argument ends in `.sql`, `.sql.gz`, `.sql.enc` or `.sql.gz.enc`, it is treated as the exact S3 key of the backup to restore (including any `S3_PREFIX`). The `.enc` suffix indicates the backup was encrypted with `ENCRYPTION_PASSWORD`.
- Otherwise, the argument is treated as a database name, and the script looks up the most recent backup for that database under `s3://<S3_BUCKET>/<S3_PREFIX>/<database>/`.

In both cases, the target database to restore into is derived from the backup's path (the first path segment after the prefix), so the database does not need to be passed separately.

```sh
# restore the most recent backup of "my_database"
$ docker exec <container> bash restore.sh my_database

# restore a specific backup file
$ docker exec <container> bash restore.sh backup/my_database/2026/06/my_database.2026-06-20T03:00:00Z.sql.gz
```

The script downloads the dump to a temporary directory, decrypts it if it ends in `.enc` (requires `ENCRYPTION_PASSWORD`), decompresses it if it ends in `.gz`, then imports it with `mysql`. The temporary file is removed afterwards regardless of outcome.

## Docker Compose example

```yaml
services:
  mysql-backup:
    image: dzangolab/mysql-backup-s3:latest
    environment:
      - DATABASE_HOST=mariadb
      - DATABASE_USER=root
      - DATABASE_PASSWORD=${DATABASE_PASSWORD}
      - S3_ACCESS_KEY_ID=${S3_ACCESS_KEY_ID}
      - S3_SECRET_ACCESS_KEY=${S3_SECRET_ACCESS_KEY}
      - S3_BUCKET=my-bucket
      - S3_PREFIX=mariadb
      - S3_REGION=eu-central-1
      - S3_ENDPOINT=https://s3.eu-central-1.wasabisys.com
      - S3_S3V4=yes
      - SCHEDULE=@daily
```
