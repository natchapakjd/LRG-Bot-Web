"""
MySQL backup/restore utility (no external mysql CLI required).

Usage:
  python scripts/mysql_backup_restore.py backup
  python scripts/mysql_backup_restore.py restore --file backups/mysql/xxxx.sql
"""
from __future__ import annotations

import argparse
import datetime as dt
import os
from pathlib import Path
from typing import Any

import pymysql
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent.parent
BACKUP_DIR = ROOT / "backups" / "mysql"


def sql_literal(value: Any) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "1" if value else "0"
    if isinstance(value, (int, float)):
        return str(value)
    text = str(value).replace("\\", "\\\\").replace("'", "''")
    return f"'{text}'"


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


def get_conn(database: str | None = None):
    load_dotenv(ROOT / ".env")
    return pymysql.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "51579")),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", "root"),
        database=database or os.getenv("DB_NAME", "lineranger_automation"),
        charset="utf8mb4",
        autocommit=True,
    )


def backup() -> Path:
    db_name = os.getenv("DB_NAME", "lineranger_automation")
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)

    ts = dt.datetime.now().strftime("%Y%m%d_%H%M%S")
    out_file = BACKUP_DIR / f"{db_name}_backup_{ts}.sql"

    conn = get_conn(db_name)
    try:
        with conn.cursor() as cur:
            cur.execute("SHOW TABLES")
            tables = [r[0] for r in cur.fetchall()]

            lines: list[str] = []
            lines.append(f"-- Backup for {db_name} generated at {ts}")
            lines.append(f"CREATE DATABASE IF NOT EXISTS {db_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
            lines.append(f"USE {db_name};")
            lines.append("SET FOREIGN_KEY_CHECKS = 0;")
            lines.append("")

            for table in tables:
                cur.execute(f"SHOW CREATE TABLE {table}")
                create_sql = cur.fetchone()[1]
                lines.append(f"DROP TABLE IF EXISTS {table};")
                lines.append(f"{create_sql};")
                lines.append("")

            for table in tables:
                cur.execute(f"SELECT * FROM {table}")
                rows = cur.fetchall()
                if not rows:
                    continue

                cur.execute(f"SHOW COLUMNS FROM {table}")
                cols = [r[0] for r in cur.fetchall()]
                col_csv = ", ".join(cols)

                for row in rows:
                    values = ", ".join(sql_literal(v) for v in row)
                    lines.append(f"INSERT INTO {table} ({col_csv}) VALUES ({values});")

                lines.append("")

            lines.append("SET FOREIGN_KEY_CHECKS = 1;")
            out_file.write_text("\n".join(lines), encoding="utf-8")

    finally:
        conn.close()

    return out_file


def restore(file_path: Path) -> None:
    sql_text = file_path.read_text(encoding="utf-8")
    conn = get_conn(None)
    try:
        with conn.cursor() as cur:
            for stmt in iter_sql_statements(sql_text):
                cur.execute(stmt)
    finally:
        conn.close()


def main() -> None:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("backup")

    p_restore = sub.add_parser("restore")
    p_restore.add_argument("--file", required=True)

    args = parser.parse_args()

    if args.cmd == "backup":
        path = backup()
        print(f"Backup created: {path}")
    elif args.cmd == "restore":
        file_path = Path(args.file)
        if not file_path.exists():
            raise FileNotFoundError(f"Backup file not found: {file_path}")
        restore(file_path)
        print(f"Restore completed: {file_path}")


if __name__ == "__main__":
    main()
