#!/bin/bash

TASK_KEY=$(
    cd ${WWW_DIRECTORY}
    php <<-'PHP_CODE' 2>/dev/null || exit 1
<?php
require 'conf_global.php';

if (!isset($INFO['sql_host'], $INFO['sql_user'], $INFO['sql_pass'], $INFO['sql_database'])) {
    fwrite(STDERR, "Missing configuration variables\n");
    exit(1);
}

$host = $INFO['sql_host'];
$user = $INFO['sql_user'];
$pass = $INFO['sql_pass'];
$db   = $INFO['sql_database'];
$port = isset($INFO['sql_port']) ? intval($INFO['sql_port']) : 3306;

$conn = new mysqli($host, $user, $pass, $db, $port);

if ($conn->connect_error) {
    fwrite(STDERR, "Database connection error: " . $conn->connect_error . "\n");
    exit(1);
}

$sql = "SELECT conf_value FROM core_sys_conf_settings WHERE conf_key = 'task_cron_key'";
$result = $conn->query($sql);

if (!$result) {
    fwrite(STDERR, "Query error: " . $conn->error . "\n");
    $conn->close();
    exit(1);
}

$row = $result->fetch_assoc();
$taskKey = $row['conf_value'] ?? '';

echo $taskKey;
$conn->close();
PHP_CODE
)

if [ -n "$TASK_KEY" ]; then
    php -d memory_limit=-1 -d max_execution_time=0 ${WWW_DIRECTORY}/applications/core/interface/task/task.php "$TASK_KEY"
else
    echo "Failed to retrieve the task key" >&2
    exit 1
fi
