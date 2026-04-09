"""
Export data from local SQLite database (licenses.db) into MySQL-compatible INSERT statements.

Usage:
    python scripts/export_sqlite_to_mysql_inserts.py

Output:
    db/mysql/03_data_from_sqlite.sql
"""
from __future__ import annotations

import json
import sqlite3
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parent.parent
SQLITE_DB = ROOT / "licenses.db"
OUTPUT_SQL = ROOT / "db" / "mysql" / "03_data_from_sqlite.sql"

TABLE_ORDER = [
    "users",
    "licenses",
    "workflows",
    "workflow_templates",
    "workflow_template_sets",
    "workflow_steps",
    "template_set_workflow_association",
    "mode_configurations",
]

MYSQL_TABLE_NAME = {
    "users": "t_users",
    "licenses": "t_licenses",
    "workflows": "t_workflows",
    "workflow_templates": "t_workflow_templates",
    "workflow_template_sets": "t_workflow_template_sets",
    "workflow_steps": "t_workflow_steps",
    "template_set_workflow_association": "t_template_set_workflow_assoc",
    "mode_configurations": "t_mode_configurations",
}

JSON_COLUMNS_BY_TABLE = {
    "workflow_steps": {"expected_color", "ocr_region", "target_characters"},
}


def sql_literal(value: Any, is_json_column: bool = False) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "1" if value else "0"
    if isinstance(value, (int, float)):
        return str(value)

    if isinstance(value, (dict, list)):
        value = json.dumps(value, ensure_ascii=False)

    text = str(value)
    if is_json_column and text.strip().lower() == "null":
        return "NULL"

    text = text.replace("\\", "\\\\").replace("'", "''")
    return f"'{text}'"


def get_columns(cursor: sqlite3.Cursor, table_name: str) -> list[str]:
    cursor.execute(f"PRAGMA table_info({table_name})")
    return [row[1] for row in cursor.fetchall()]


def export() -> None:
    if not SQLITE_DB.exists():
        raise FileNotFoundError(f"SQLite source DB not found: {SQLITE_DB}")

    OUTPUT_SQL.parent.mkdir(parents=True, exist_ok=True)

    conn = sqlite3.connect(str(SQLITE_DB))
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    lines: list[str] = []
    lines.append("-- Data migrated from SQLite licenses.db")
    lines.append("USE lineranger_automation;")
    lines.append("SET NAMES utf8mb4;")
    lines.append("SET FOREIGN_KEY_CHECKS = 0;")
    lines.append("")

    for table in TABLE_ORDER:
        mysql_table = MYSQL_TABLE_NAME.get(table, table)
        columns = get_columns(cur, table)
        col_csv = ", ".join(columns)

        cur.execute(f"SELECT * FROM {table}")
        rows = cur.fetchall()

        lines.append(f"-- {mysql_table}: {len(rows)} rows")
        if not rows:
            lines.append("")
            continue

        json_columns = JSON_COLUMNS_BY_TABLE.get(table, set())

        for row in rows:
            values = ", ".join(
                sql_literal(row[col], is_json_column=(col in json_columns)) for col in columns
            )
            lines.append(f"INSERT INTO {mysql_table} ({col_csv}) VALUES ({values});")

        lines.append("")

    lines.append("SET FOREIGN_KEY_CHECKS = 1;")
    lines.append("")

    OUTPUT_SQL.write_text("\n".join(lines), encoding="utf-8")
    conn.close()

    print(f"Export complete: {OUTPUT_SQL}")


if __name__ == "__main__":
    export()
