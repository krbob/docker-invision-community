#!/usr/bin/env bash
set -euo pipefail

env_file=${1:-.env}
secrets_directory=${2:-secrets}

if [[ ! -r "$env_file" ]]; then
  printf 'Cannot read environment file: %s\n' "$env_file" >&2
  exit 1
fi

read_env_value() {
  local key=$1 line value

  line=$(awk -v key="$key" '
    $0 ~ "^[[:space:]]*" key "=" {
      value = $0
      sub("^[[:space:]]*" key "=", "", value)
    }
    END { print value }
  ' "$env_file")

  if [[ -z "$line" ]]; then
    printf 'Missing or empty %s in %s\n' "$key" "$env_file" >&2
    exit 1
  fi

  value=$line
  if [[ ${#value} -ge 2 && ( ${value:0:1} == '"' && ${value: -1} == '"' || ${value:0:1} == "'" && ${value: -1} == "'" ) ]]; then
    value=${value:1:-1}
  fi

  printf '%s' "$value"
}

if [[ -e "$secrets_directory" && ! -d "$secrets_directory" ]]; then
  printf 'Secrets path is not a directory: %s\n' "$secrets_directory" >&2
  exit 1
fi

for target_file in mariadb_root_password mariadb_password restic_password aws_credentials; do
  if [[ -e "$secrets_directory/$target_file" ]]; then
    printf 'Refusing to overwrite existing secret: %s\n' "$secrets_directory/$target_file" >&2
    exit 1
  fi
done

mariadb_root_password=$(read_env_value MARIADB_ROOT_PASSWORD)
mariadb_password=$(read_env_value MARIADB_PASSWORD)
restic_password=$(read_env_value RESTIC_PASSWORD)
aws_access_key_id=$(read_env_value AWS_ACCESS_KEY_ID)
aws_secret_access_key=$(read_env_value AWS_SECRET_ACCESS_KEY)

mkdir -p "$secrets_directory"
chmod 700 "$secrets_directory"

(umask 077; printf '%s' "$mariadb_root_password" > "$secrets_directory/mariadb_root_password")
(umask 077; printf '%s' "$mariadb_password" > "$secrets_directory/mariadb_password")
(umask 077; printf '%s' "$restic_password" > "$secrets_directory/restic_password")
(umask 077; {
  printf 'AWS_ACCESS_KEY_ID=%s\n' "$aws_access_key_id"
  printf 'AWS_SECRET_ACCESS_KEY=%s\n' "$aws_secret_access_key"
} > "$secrets_directory/aws_credentials")

if ! grep -Eq '^[[:space:]]*SECRETS_DIRECTORY=' "$env_file"; then
  compose_secrets_directory=$secrets_directory
  if [[ $compose_secrets_directory != /* && $compose_secrets_directory != ./* ]]; then
    compose_secrets_directory="./$compose_secrets_directory"
  fi
  printf '\nSECRETS_DIRECTORY=%s\n' "$compose_secrets_directory" >> "$env_file"
fi

printf 'Migrated secrets to %s. Remove plaintext secret entries from %s after verifying the deployment.\n' \
  "$secrets_directory" "$env_file"
