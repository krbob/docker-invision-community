#!/bin/bash

CONFIG_FILE="$WWW_DIRECTORY/conf_global.php"
TASK_FILE="$WWW_DIRECTORY/applications/core/interface/task/task.php"
SQL_QUERY="SELECT conf_value FROM core_sys_conf_settings WHERE conf_key = 'task_cron_key'"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file $CONFIG_FILE does not exist." >&2
    exit 1
fi

eval $(php -r "
include '$CONFIG_FILE';
printf('DB_HOST=%s ', escapeshellarg(\$INFO['sql_host']));
printf('DB_NAME=%s ', escapeshellarg(\$INFO['sql_database']));
printf('DB_USER=%s ', escapeshellarg(\$INFO['sql_user']));
printf('DB_PASS=%s ', escapeshellarg(\$INFO['sql_pass']));
printf('DB_PORT=%s ', escapeshellarg(\$INFO['sql_port']));
" 2>/dev/null)

DB_HOST=$(echo $DB_HOST | sed "s/^'//;s/'$//")
DB_NAME=$(echo $DB_NAME | sed "s/^'//;s/'$//")
DB_USER=$(echo $DB_USER | sed "s/^'//;s/'$//")
DB_PASS=$(echo $DB_PASS | sed "s/^'//;s/'$//")
DB_PORT=$(echo $DB_PORT | sed "s/^'//;s/'$//")

if [ -z "$DB_HOST" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ]; then
    echo "Failed to retrieve configuration data from file $CONFIG_FILE." >&2
    exit 1
fi

TASK_KEY=$(php -r "
try {
    \$mysqli = new mysqli('$DB_HOST', '$DB_USER', '$DB_PASS', '$DB_NAME', $DB_PORT);
    if (\$mysqli->connect_error) {
        throw new Exception('Database connection error: ' . \$mysqli->connect_error);
    }
    \$result = \$mysqli->query(\"$SQL_QUERY\");
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

php -d memory_limit=-1 -d max_execution_time=0 ${TASK_FILE} "$TASK_KEY" 2>&1
if [ $? -ne 0 ]; then
    echo "Failed to execute PHP task." >&2
    exit 1
fi
