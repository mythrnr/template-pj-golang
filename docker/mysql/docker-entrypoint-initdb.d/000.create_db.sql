CREATE SCHEMA IF NOT EXISTS `db_local`      DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE SCHEMA IF NOT EXISTS `test_db_local` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

CREATE USER db_local@'%'      IDENTIFIED WITH mysql_native_password BY 'db_local_password';
CREATE USER test_db_local@'%' IDENTIFIED WITH mysql_native_password BY 'test_db_local_password';

REVOKE ALL PRIVILEGES, GRANT OPTION FROM db_local@'%';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM test_db_local@'%';

GRANT
  INSERT, SELECT, UPDATE, DELETE
  -- , CREATE, ALTER, REFERENCES, INDEX
ON db_local.* TO db_local@'%';

GRANT
  ALL PRIVILEGES
ON test_db_local.* TO test_db_local@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
