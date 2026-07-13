# renovate: datasource=docker depName=restic/restic
FROM restic/restic:0.19.0@sha256:7f44e0057b82348597568ea209360762d0b38f8e1dbc8ad859661ac1055e45f2

COPY restic-credentials.sh publish-backups.sh restore-latest-backups.sh prune-backups.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/restic-credentials.sh \
    && chmod +x /usr/local/bin/publish-backups.sh \
    && chmod +x /usr/local/bin/restore-latest-backups.sh \
    && chmod +x /usr/local/bin/prune-backups.sh

ENTRYPOINT ["tail", "-f", "/dev/null"]
