#!/bin/bash

docker_process_sql < /tmp/files/000.create_db.sql

for file in `ls /tmp/files`; do
  if [ "$file" = "000.create_db.sql" ] || [ "$file" = "999.init_data.sql" ]; then
    continue
  fi

  docker_process_sql < "/tmp/files/$file"
  docker_process_sql --database=test_db_local < "/tmp/files/$file"
done

docker_process_sql < /tmp/files/999.init_data.sql
