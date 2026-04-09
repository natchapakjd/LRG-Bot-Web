# Linerangers-bot-v2

## MySQL Migration

This project has a full MySQL migration package (schema + stored procedures + data export from SQLite).

See `MYSQL_MIGRATION.md` for complete instructions.

Quick run:

```powershell
& ".\.venv\Scripts\python.exe" scripts/run_mysql_migration.py
```

Incremental (no-drop + auto-backup) run:

```powershell
& ".\.venv\Scripts\python.exe" scripts/run_mysql_incremental_migration.py
```
