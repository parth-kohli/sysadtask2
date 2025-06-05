DB_HOST="localhost"
DB_USER="root"
DB_PASS="parthsarth9541"
DB_NAME="blogdb"
until mysqladmin ping -h "$DB_HOST" --silent; do
  echo "Waiting for MySQL..."
  sleep 2
done
insert_users_from_group() {
  local group="$1"
  local group_type="$2"
  local gid=$(getent group "$group" | cut -d: -f3)
  local primary_users=$(getent passwd | awk -F: -v gid="$gid" '$4 == gid { print $1 }')
  local secondary_users=$(getent group "$group" | cut -d: -f4 | tr ',' ' ')
  local users=$(echo -e "$primary_users\n$secondary_users" | sort -u)

  for user in $users; do
    if [[ -n "$user" ]]; then
      echo "Inserting $user from $group_type"
      mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" <<EOF
INSERT INTO users (username, group_type)
VALUES ('$user', '$group_type')
ON DUPLICATE KEY UPDATE group_type=VALUES(group_type);
EOF
    fi
  done
}
insert_users_from_group "g_admin"  "g_admin"
insert_users_from_group "g_mod"  "g_mod"
insert_users_from_group "g_user"   "g_user"
insert_users_from_group "g_author" "g_author"
