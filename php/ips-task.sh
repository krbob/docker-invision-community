#!/bin/bash
set -euo pipefail

CONFIG_FILE="$WWW_DIRECTORY/conf_global.php"
TASK_FILE="$WWW_DIRECTORY/applications/core/interface/task/task.php"
SQL_QUERY="SELECT conf_value FROM core_sys_conf_settings WHERE conf_key = 'task_cron_key'"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file $CONFIG_FILE does not exist." >&2
    exit 1
fi

if [ ! -f "$TASK_FILE" ]; then
    echo "Task file $TASK_FILE does not exist." >&2
    exit 1
fi

eval "$(php -r "
include '$CONFIG_FILE';
printf(\"DB_HOST=%s\n\", escapeshellarg(\$INFO['sql_host'] ?? ''));
printf(\"DB_NAME=%s\n\", escapeshellarg(\$INFO['sql_database'] ?? ''));
printf(\"DB_USER=%s\n\", escapeshellarg(\$INFO['sql_user'] ?? ''));
printf(\"DB_PASS=%s\n\", escapeshellarg(\$INFO['sql_pass'] ?? ''));
printf(\"DB_PORT=%s\n\", escapeshellarg(\$INFO['sql_port'] ?? ''));
" 2>/dev/null)"

if [ -z "$DB_HOST" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ]; then
    echo "Failed to retrieve configuration data from file $CONFIG_FILE." >&2
    exit 1
fi

TASK_KEY=$(DB_HOST="$DB_HOST" DB_USER="$DB_USER" DB_PASS="$DB_PASS" DB_NAME="$DB_NAME" DB_PORT="$DB_PORT" SQL_QUERY="$SQL_QUERY" php -r "
try {
    \$port = getenv('DB_PORT') ?: 3306;
    \$mysqli = new mysqli(getenv('DB_HOST'), getenv('DB_USER'), getenv('DB_PASS'), getenv('DB_NAME'), (int) \$port);
    if (\$mysqli->connect_error) {
        throw new Exception('Database connection error: ' . \$mysqli->connect_error);
    }
    \$result = \$mysqli->query(getenv('SQL_QUERY'));
    if (!\$result) {
        throw new Exception('Database query error: ' . \$mysqli->error);
    }
    \$row = \$result->fetch_assoc();
    if (!\$row) {
        throw new Exception('No result found for task_cron_key in the database.');
    }
    echo \$row['conf_value'];
    \$mysqli->close();
} catch (Exception \$e) {
    echo 'ERROR: ' . \$e->getMessage();
    exit(1);
}
" 2>&1)

if [[ "$TASK_KEY" == ERROR:* ]]; then
    echo "${TASK_KEY#ERROR: }" >&2
    exit 1
elif [ -z "$TASK_KEY" ]; then
    echo "Failed to retrieve task_cron_key from the database." >&2
    exit 1
fi

if ! php -d memory_limit=-1 -d max_execution_time=0 "$TASK_FILE" "$TASK_KEY" 2>&1; then
    echo "Failed to execute PHP task." >&2
    exit 1
fi
