# Invision Community Docker Compose Stack

This repository contains the complete Docker stack needed to run Invision Community 4.7.

## Installation

```bash
git clone https://github.com/krbob/docker-invision-community.git
cd docker-invision-community
```

Copy the `dotenv` file to `.env` and adjust the values in the `.env` file.
Run the containers:

```bash
docker-compose up -d
```

After the first run, you may also want to generate a certificate and initialize the repository for backups:

```bash
docker exec certbot certbot.sh certonly && docker-compose restart apache
docker exec restic /bin/sh -c 'restic -r $RESTIC_REPOSITORY init'
```

You might also want to enable memory-overcommit on the host to eliminate the Redis warning:

```bash
echo "vm.overcommit_memory = 1" | sudo tee /etc/sysctl.d/memory-overcommit.conf
```

## Detailed Configuration

### Apache 2.4
- The image includes PHP FPM and SSL configuration.
- A Snakeoil certificate is generated for localhost testing purposes.
- All traffic is redirected to HTTPS.
- Requests without a domain are forbidden.
- `acme-challenge` support is added.
- `RemoteIPHeader` support for Cloudflare is included.
- Scripts `create-backup.sh` and `restore-backup.sh` create and restore backups of www files, respectively.

### Certbot
- The `certbot.sh` script generates a new certificate or renews it using the webroot method, depending on the `certonly` and `renew` options.

### Cron
Periodically runs:
- IPS Task
- Logrotate
- Certificate renewal
- Creating and sending backups

### Logrotate
- By default, it retains 5 weeks of logs.

### Mariadb 10.11
- The default `innodb_buffer_pool_size` is 512 MB.
- Scripts `create-backup.sh` and `restore-backup.sh` create and restore database backups, respectively.

### PHP 8.1
- The image includes all extensions used by IPS.
- The default `pm.max_children` is 10.
- The default `memory_limit` is 256 MB, `upload_max_filesize` is 32 MB, and `post_max_size` is 64 MB.
- Default locales are defined in the `locale.gen` file (necessary for IPS translations).
- The `ips-task.sh` script retrieves the required key from the database and executes the IPS task.

### Redis 6.2
- The default maximum memory usage is 128 MB.

### Restic
- The `publish-backup.sh` and `restore-latest-backups.sh` scripts send and retrieve the latest backup files, respectively.
- To use a previous snapshot, you can use:

```bash
docker exec restic restic snapshots
docker exec restic restic restore <snapshot_id> --target / --include /var/backup/db/ips.sql
docker exec restic restic restore <snapshot_id> --target / --include /var/backup/www/ips.tar.gz
```

## Maintenance

The `update-stack.sh` script rebuilds the stack using the latest versions of the base images.

## Future Plans
- Configuration of a test instance
- Configuration of service monitoring on Grafana Cloud

---

Feel free to contribute to the project by submitting issues or pull requests. Any suggestions for improvements are welcome.
