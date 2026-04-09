"""
Run MySQL migration scripts without needing mysql CLI.

Usage:
    python scripts/run_mysql_migration.py

Reads DB config from .env (DB_HOST, DB_PORT, DB_USER, DB_PASSWORD).
Runs:
    db/mysql/01_schema.sql
    db/mysql/02_stored_procedures.sql
    db/mysql/03_data_from_sqlite.sql
"""
from __future__ import annotations

import os
from pathlib import Path

import pymysql
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent.parent
SQL_FILES = [
    ROOT / "db" / "mysql" / "01_schema.sql",
    ROOT / "db" / "mysql" / "02_stored_procedures.sql",
    ROOT / "db" / "mysql" / "03_data_from_sqlite.sql",
]


def _iter_sql_statements(sql_text: str):
    delimiter = ";"
    buffer: list[str] = []

    for raw_line in sql_text.splitlines():
        line = raw_line.rstrip()
        stripped = line.strip()

        if not stripped:
            continue
        if stripped.startswith("--"):
            continue

        upper = stripped.upper()
        if upper.startswith("DELIMITER "):
            parts = stripped.split(maxsplit=1)
            delimiter = parts[1]
            continue

        buffer.append(line)
        joined = "\n".join(buffer)

        if joined.endswith(delimiter):
            statement = joined[: -len(delimiter)].strip()
            if statement:
                yield statement
            buffer = []

    tail = "\n".join(buffer).strip()
    if tail:
        yield tail


def run_file(cursor, file_path: Path):
    sql_text = file_path.read_text(encoding="utf-8")
    count = 0

    for stmt in _iter_sql_statements(sql_text):
        cursor.execute(stmt)
        count += 1

    return count


def main() -> None:
    load_dotenv(ROOT / ".env")

    host = os.getenv("DB_HOST", "localhost")
    port = int(os.getenv("DB_PORT", "51579"))
    user = os.getenv("DB_USER", "root")
    password = os.getenv("DB_PASSWORD", "root")

    conn = pymysql.connect(
        host=host,
        port=port,
        user=user,
        password=password,
        charset="utf8mb4",
        autocommit=True,
    )

    try:
        with conn.cursor() as cursor:
            total = 0
            for sql_file in SQL_FILES:
                if not sql_file.exists():
                    raise FileNotFoundError(f"Missing SQL file: {sql_file}")
                executed = run_file(cursor, sql_file)
                total += executed
                print(f"[OK] {sql_file.name} -> {executed} statements")

            print(f"Migration complete. Total statements executed: {total}")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
