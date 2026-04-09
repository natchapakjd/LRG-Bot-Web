-- Full migration entrypoint for MySQL client
-- Run with:
-- mysql -h localhost -P 51579 -u root -proot < db/mysql/00_full_migration.sql

SOURCE db/mysql/01_schema.sql;
SOURCE db/mysql/02_stored_procedures.sql;
SOURCE db/mysql/03_data_from_sqlite.sql;
