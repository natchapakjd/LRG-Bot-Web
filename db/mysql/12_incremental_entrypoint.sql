-- Incremental migration entrypoint (no table drops)
-- Run with:
-- mysql -h localhost -P 51579 -u root -proot < db/mysql/12_incremental_entrypoint.sql

SOURCE db/mysql/11_schema_incremental.sql;
SOURCE db/mysql/02_stored_procedures.sql;
SOURCE db/mysql/13_data_upsert_from_sqlite.sql;
