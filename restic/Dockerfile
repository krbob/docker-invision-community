FROM restic/restic:0.17.0

COPY publish-backups.sh restore-latest-backups.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/publish-backups.sh \
    && chmod +x /usr/local/bin/restore-latest-backups.sh

ENTRYPOINT ["tail", "-f", "/dev/null"]