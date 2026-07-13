# Invision Community Docker Compose Stack

[![CI](https://github.com/krbob/docker-invision-community/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/krbob/docker-invision-community/actions/workflows/ci.yml)

A Docker Compose stack for self-hosting Invision Community with Apache, PHP-FPM,
MariaDB, Redis, Let's Encrypt certificates, Restic backups, and scheduled
maintenance.

This repository provides infrastructure only. It does not include Invision
Community application files or a licence; obtain both from Invision Community
and place the application files in `WWW_DIRECTORY` before starting the stack.
It is not an official Invision Community project.

## Requirements

- Docker Engine and Docker Compose v2, available to the deployment user.
- A hostname whose apex and `www` DNS records point at this host before issuing
  a certificate.
- Inbound TCP ports 80 and 443 available to Docker and to Let's Encrypt.
- Writable host directories selected for application files, logs, certificate
  challenges, and backups.
- A dedicated Restic repository location and credentials reachable from the host.

The stack uses fixed container names (`apache`, `php`, `mariadb`, and others),
so run only one instance on a Docker host.

## Quick start

1. Clone the repository and create private configuration files:

   ```bash
   git clone https://github.com/krbob/docker-invision-community.git
   cd docker-invision-community
   cp dotenv .env
   cp -R secrets.example secrets
   chmod 700 secrets
   chmod 600 secrets/*
   ```

2. Edit `.env`, put the Invision Community files in `WWW_DIRECTORY`, and replace
   every placeholder in `secrets/`. Do not commit either `.env` or `secrets/`.

3. Validate and start the stack:

   ```bash
   docker compose config --quiet
   docker compose up -d --build
   docker compose ps
   ```

   `apache`, `php`, `mariadb`, and `redis` should report `healthy`.

4. After DNS and ports are ready, issue the first certificate and initialize
   Restic. Both are required before relying on HTTPS and scheduled backups:

   ```bash
   docker exec certbot certbot.sh certonly
   docker compose restart apache
   docker exec restic restic init
   ```

For a deployment upgrading from plaintext `.env` secrets, run
`./migrate-secrets.sh` before the first `docker compose up`. It creates
restricted secret files and adds `SECRETS_DIRECTORY` when required. After a
successful deployment, remove the five plaintext secret entries from `.env`.

## Configuration

| Variable | Purpose |
| --- | --- |
| `DOMAIN_NAME` | Public domain; both it and `www.<domain>` are requested from Let's Encrypt. |
| `TRUSTED_PROXY_CIDRS` | Comma-separated trusted proxy CIDRs. Leave empty for direct access. |
| `SECRETS_DIRECTORY` | Directory with the four private secret files, normally `./secrets`. |
| `WWW_DIRECTORY` | Host directory containing the licensed Invision Community installation. |
| `LOGS_DIRECTORY` | Host directory for Apache, PHP, MariaDB, Redis, and Cron logs. |
| `CERTBOT_WWW_DIRECTORY` | Shared ACME webroot. |
| `BACKUP_DIRECTORY` | Host directory for database dumps and application archives before Restic uploads. |
| `MARIADB_DATABASE` / `MARIADB_USER` | Database name and non-root application user. |
| `RESTIC_REPOSITORY` | Dedicated Restic repository URL. |
| `AWS_DEFAULT_REGION` | Region used by the S3-compatible Restic backend. |
| `TIMEZONE` | IANA timezone used by containers and scheduled jobs. |

`secrets/` must contain these files, each with mode `0600`:

| File | Contents |
| --- | --- |
| `mariadb_root_password` | MariaDB root password. |
| `mariadb_password` | Password for `MARIADB_USER`. |
| `restic_password` | Restic repository password. |
| `aws_credentials` | `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` assignments. |

Set `TRUSTED_PROXY_CIDRS` only when the origin accepts traffic exclusively from
the listed proxies. Otherwise a client could spoof `CF-Connecting-IP`.

## Operations

- Inspect status and logs with `docker compose ps` and `docker compose logs -f`.
- Run `./update-stack.sh` to pull the reviewed, digest-pinned images and rebuild
  the stack. It also removes dangling Docker images; take a backup first.
- Run `./smoke-test.sh` after stack changes. It builds all images and verifies
  service entry points, Apache startup, secret handling, and database
  backup/restore.
- Scheduled backup, retention, recovery, and troubleshooting procedures are in
  [docs/operations.md](docs/operations.md).

## Architecture and security

See [docs/architecture.md](docs/architecture.md) for service boundaries,
networks, volumes, and the Docker socket proxy restriction. See
[SECURITY.md](SECURITY.md) for vulnerability reporting.

## Contributing

Report defects or ideas through the issue templates. Changes should pass
`./smoke-test.sh` before submission. This repository is licensed under the
[MIT License](LICENSE); that licence covers this repository only, not Invision
Community.
