"""
Run incremental (no-drop) migration with automatic backup.

Steps:
1) Backup current MySQL database.
2) Apply incremental schema SQL.
3) Apply stored procedures.
4) Apply UPSERT data from SQLite.

Usage:
  python scripts/run_mysql_incremental_migration.py
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

import pymysql
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from scripts.mysql_backup_restore import backup as backup_mysql
from scripts.export_sqlite_to_mysql_upserts import export as export_upserts

SQL_FILES = [
    ROOT / "db" / "mysql" / "11_schema_incremental.sql",
    ROOT / "db" / "mysql" / "02_stored_procedures.sql",
    ROOT / "db" / "mysql" / "13_data_upsert_from_sqlite.sql",
]

REQUIRED_COLUMNS: dict[str, list[str]] = {
    "t_users": [
        "email VARCHAR(100) NULL",
        "role VARCHAR(20) NOT NULL DEFAULT 'user'",
        "is_active TINYINT(1) NOT NULL DEFAULT 1",
        "created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP",
    ],
    "t_licenses": [
        "hardware_id VARCHAR(64) NULL",
        "activated_at DATETIME NULL",
        "is_active TINYINT(1) NOT NULL DEFAULT 1",
        "created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP",
    ],
    "t_workflows": [
        "mode_name VARCHAR(100) NULL",
        "month_year VARCHAR(7) NULL",
        "is_master TINYINT(1) NOT NULL DEFAULT 0",
        "created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP",
        "updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP",
    ],
    "t_workflow_steps": [
        "skip_if_not_found TINYINT(1) NOT NULL DEFAULT 0",
        "max_wait_seconds INT NOT NULL DEFAULT 10",
        "max_retries INT NULL",
        "retry_interval FLOAT NOT NULL DEFAULT 1.0",
        "group_name VARCHAR(100) NULL",
        "max_iterations INT NOT NULL DEFAULT 20",
        "not_found_threshold INT NOT NULL DEFAULT 3",
        "click_delay FLOAT NOT NULL DEFAULT 1.5",
        "retry_delay FLOAT NOT NULL DEFAULT 2.0",
        "expected_color JSON NULL",
        "tolerance INT NOT NULL DEFAULT 30",
        "check_interval FLOAT NOT NULL DEFAULT 1.0",
        "loop_group_name VARCHAR(100) NULL",
        "stop_template_path VARCHAR(500) NULL",
        "stop_on_not_found TINYINT(1) NOT NULL DEFAULT 1",
        "loop_max_iterations INT NOT NULL DEFAULT 100",
        "ocr_region JSON NULL",
        "target_characters JSON NULL",
        "gacha_save_folder VARCHAR(500) NULL",
    ],
    "t_mode_configurations": [
        "priority INT NOT NULL DEFAULT 0",
        "is_active TINYINT(1) NOT NULL DEFAULT 1",
        "created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP",
        "updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP",
    ],
}


def iter_sql_statements(sql_text: str):
    delimiter = ";"
    buff: list[str] = []

    for raw_line in sql_text.splitlines():
        line = raw_line.rstrip()
        stripped = line.strip()

        if not stripped or stripped.startswith("--"):
            continue

        upper = stripped.upper()
        if upper.startswith("DELIMITER "):
            delimiter = stripped.split(maxsplit=1)[1]
            continue

        buff.append(line)
        joined = "\n".join(buff)

        if joined.endswith(delimiter):
            stmt = joined[: -len(delimiter)].strip()
            if stmt:
                yield stmt
            buff = []

    tail = "\n".join(buff).strip()
    if tail:
        yield tail


def run_file(cursor, file_path: Path) -> int:
    sql_text = file_path.read_text(encoding="utf-8")
    count = 0
    for stmt in iter_sql_statements(sql_text):
        cursor.execute(stmt)
        count += 1
    return count


def ensure_required_columns(cursor, db_name: str) -> int:
    added = 0
    for table_name, definitions in REQUIRED_COLUMNS.items():
        for definition in definitions:
            col_name = definition.split(" ", 1)[0]
            cursor.execute(
                """
                SELECT COUNT(*)
                FROM information_schema.columns
                WHERE table_schema=%s AND table_name=%s AND column_name=%s
                """,
                (db_name, table_name, col_name),
            )
            exists = cursor.fetchone()[0] > 0
            if not exists:
                cursor.execute(f"ALTER TABLE {table_name} ADD COLUMN {definition}")
                added += 1
    return added


def main() -> None:
    load_dotenv(ROOT / ".env")

    backup_file = backup_mysql()
    print(f"[1/4] Backup created: {backup_file}")

    upsert_file = export_upserts()
    print(f"[2/4] SQLite export prepared: {upsert_file}")

    db_name = os.getenv("DB_NAME", "lineranger_automation")

    conn = pymysql.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "51579")),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", "root"),
        charset="utf8mb4",
        autocommit=True,
    )

    try:
        with conn.cursor() as cur:
            total = 0
            for idx, sql_file in enumerate(SQL_FILES, start=3):
                if not sql_file.exists():
                    raise FileNotFoundError(f"Missing SQL file: {sql_file}")
                executed = run_file(cur, sql_file)
                total += executed
                print(f"[{idx}/4] Applied {sql_file.name}: {executed} statements")

            added_cols = ensure_required_columns(cur, db_name)
            print(f"[4/4] Column reconciliation complete: {added_cols} columns added")

            print(f"Incremental migration complete. Total executed: {total}")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
