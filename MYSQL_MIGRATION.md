# MySQL Migration Guide (Ready to Use)

## Target Database
- Host: `localhost`
- Port: `51579`
- User: `root`
- Password: `root`
- Database: `lineranger_automation`

## Files Created
- `db/mysql/01_schema.sql` -> Create DB + all tables + indexes + foreign keys
- `db/mysql/02_stored_procedures.sql` -> Stored procedures (license/workflow/mode-config ops)
- `db/mysql/03_data_from_sqlite.sql` -> Data exported from current `licenses.db`
- `db/mysql/00_full_migration.sql` -> Full entry script for mysql CLI
- `db/mysql/11_schema_incremental.sql` -> Incremental schema (no table drops)
- `db/mysql/12_incremental_entrypoint.sql` -> Incremental SQL entrypoint
- `db/mysql/13_data_upsert_from_sqlite.sql` -> Incremental UPSERT data
- `scripts/export_sqlite_to_mysql_inserts.py` -> Regenerate data INSERT SQL from SQLite
- `scripts/run_mysql_migration.py` -> Run migration without mysql CLI
- `scripts/export_sqlite_to_mysql_upserts.py` -> Regenerate UPSERT data for incremental migration
- `scripts/mysql_backup_restore.py` -> Automatic backup/restore utility
- `scripts/run_mysql_incremental_migration.py` -> Backup + incremental schema + procedures + UPSERT data

## One-Command Migration (Python Runner)
Run this from project root:

```powershell
& ".\.venv\Scripts\python.exe" scripts/run_mysql_migration.py
```

This executes all 3 SQL steps in order.

## Incremental / Zero-Downtime Migration (Recommended)
This flow does not drop tables and automatically creates backup first.

```powershell
& ".\.venv\Scripts\python.exe" scripts/run_mysql_incremental_migration.py
```

Manual SQL entrypoint alternative:

```powershell
mysql -h localhost -P 51579 -u root -proot < db/mysql/12_incremental_entrypoint.sql
```

## Backup / Restore

Create backup:

```powershell
& ".\.venv\Scripts\python.exe" scripts/mysql_backup_restore.py backup
```

Restore backup:

```powershell
& ".\.venv\Scripts\python.exe" scripts/mysql_backup_restore.py restore --file backups/mysql/<backup_file>.sql
```

## Alternative (mysql CLI)
If `mysql` command is available:

```powershell
mysql -h localhost -P 51579 -u root -proot < db/mysql/00_full_migration.sql
```

## Regenerate Data Export from SQLite
If SQLite data changes and you want fresh INSERT statements:

```powershell
& ".\.venv\Scripts\python.exe" scripts/export_sqlite_to_mysql_inserts.py
```

Then rerun migration.

## Stored Procedures Included
- `sp_create_license`
- `sp_activate_license`
- `sp_validate_license`
- `sp_revoke_license`
- `sp_reset_license_hardware`
- `sp_set_master_workflow`
- `sp_upsert_mode_configuration`

## Backend Config Already Updated
Application now reads MySQL config from `.env`:
- `DB_DRIVER=mysql+asyncmy`
- `DB_HOST=localhost`
- `DB_PORT=51579`
- `DB_USER=root`
- `DB_PASSWORD=root`
- `DB_NAME=lineranger_automation`

Main DB engine source: `app/core/database.py`
DB config source: `app/config.py`

## Quick Verification SQL
```sql
USE lineranger_automation;
SELECT COUNT(*) AS users FROM users;
SELECT COUNT(*) AS workflows FROM workflows;
SELECT COUNT(*) AS workflow_steps FROM workflow_steps;
```
