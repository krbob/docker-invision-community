FROM restic/restic:0.19.0

COPY publish-backups.sh restore-latest-backups.sh prune-backups.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/publish-backups.sh \
    && chmod +x /usr/local/bin/restore-latest-backups.sh \
    && chmod +x /usr/local/bin/prune-backups.sh

ENTRYPOINT ["tail", "-f", "/dev/null"]
