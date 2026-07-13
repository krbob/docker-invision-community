# Operations

## Routine checks

```bash
docker compose ps
docker compose logs -f --tail=100
docker exec restic restic snapshots
```

The health checks cover Apache, PHP-FPM, MariaDB, and Redis. Cron writes job
output and exit status to `${LOGS_DIRECTORY}/cron/cron.log`.

## Scheduled jobs

| Schedule | Job |
| --- | --- |
| Every minute | Invision scheduled task. |
| Daily 03:00 | Log rotation. |
| Weekly Sunday 04:00 | Let's Encrypt renewal. |
| Weekly Sunday 04:05 | Graceful Apache reload. |
| Daily 05:00 | Database dump, application archive, and Restic upload. |
| Weekly Sunday 06:00 | Restic retention prune. |
| Monthly, day 1 at 06:30 | Restic integrity check against a rotating 5% data subset. |

The job wrapper prevents overlapping runs and logs a non-zero exit status.
Investigate failed entries before assuming a backup is recoverable.

## Update the stack

1. Verify a recent Restic snapshot and keep an application maintenance window.
2. Pull the reviewed image digests and rebuild:

   ```bash
   ./update-stack.sh
   docker compose ps
   ```

`update-stack.sh` runs `docker image prune -f`, so it removes dangling images.
It does not remove named volumes.

## Restore a backup

Perform restore drills in an isolated environment at least quarterly. For a
real incident, first enable Invision maintenance mode or stop the application
services:

```bash
docker compose stop apache php cron
docker exec restic restic snapshots
docker exec restic restic restore <snapshot_id> --target / \
  --include /var/backup/db/ips.sql \
  --include /var/backup/www/ips.tar
docker exec mariadb restore-backup.sh
docker exec apache restore-backup.sh
docker compose start php apache cron
```

The database and Redis remain available while the application is stopped.
Confirm the restored application and database before reopening the service.

## Certificate lifecycle

Before the first certificate request, ensure that the apex and `www` records
resolve to the host and ports 80/443 are reachable from the Internet:

```bash
docker exec certbot certbot.sh certonly
docker compose restart apache
```

Cron renews the certificate weekly. Review the Cron log if renewal fails; do
not wait for the certificate expiry date.

## Troubleshooting

| Symptom | First checks |
| --- | --- |
| A service is unhealthy | `docker compose ps`, then `docker compose logs <service> --tail=100`. |
| Invision tasks do not run | Review `${LOGS_DIRECTORY}/cron/cron.log`; verify `php`, `mariadb`, and `socket-proxy` are running. |
| Certificate request fails | Check DNS, public port 80, the `DOMAIN_NAME` value, and Apache logs. |
| Backup fails | Verify `docker exec restic restic snapshots`, credentials, repository reachability, and free space in `BACKUP_DIRECTORY`. |
| Client IPs are wrong | Leave `TRUSTED_PROXY_CIDRS` empty unless traffic is exclusively proxied through the listed CIDRs. |
