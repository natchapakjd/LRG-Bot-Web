"""
Export SQLite data to MySQL UPSERT statements (incremental-safe).

Usage:
  python scripts/export_sqlite_to_mysql_upserts.py

Output:
  db/mysql/13_data_upsert_from_sqlite.sql
"""
from __future__ import annotations

import json
import sqlite3
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parent.parent
SQLITE_DB = ROOT / "licenses.db"
OUT = ROOT / "db" / "mysql" / "13_data_upsert_from_sqlite.sql"

# Maps SQLite table name → MySQL t_-prefixed table name
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
    "users":                            "t_users",
    "licenses":                         "t_licenses",
    "workflows":                        "t_workflows",
    "workflow_templates":               "t_workflow_templates",
    "workflow_template_sets":           "t_workflow_template_sets",
    "workflow_steps":                   "t_workflow_steps",
    "template_set_workflow_association": "t_template_set_workflow_assoc",
    "mode_configurations":              "t_mode_configurations",
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


def get_columns(cur: sqlite3.Cursor, table: str) -> list[str]:
    cur.execute(f"PRAGMA table_info({table})")
    return [r[1] for r in cur.fetchall()]


def get_pk_columns(cur: sqlite3.Cursor, table: str) -> list[str]:
    cur.execute(f"PRAGMA table_info({table})")
    rows = cur.fetchall()
    pks = [r[1] for r in rows if r[5] > 0]
    return pks


def export() -> Path:
    if not SQLITE_DB.exists():
        raise FileNotFoundError(f"SQLite DB not found: {SQLITE_DB}")

    OUT.parent.mkdir(parents=True, exist_ok=True)

    conn = sqlite3.connect(str(SQLITE_DB))
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    lines: list[str] = []
    lines.append("-- Incremental UPSERT data from SQLite")
    lines.append("USE lineranger_automation;")
    lines.append("SET NAMES utf8mb4;")
    lines.append("")

    for table in TABLE_ORDER:
        mysql_table = MYSQL_TABLE_NAME.get(table, table)
        cols = get_columns(cur, table)
        pks = get_pk_columns(cur, table)

        cur.execute(f"SELECT * FROM {table}")
        rows = cur.fetchall()

        lines.append(f"-- {mysql_table}: {len(rows)} rows")
        if not rows:
            lines.append("")
            continue

        non_pk = [c for c in cols if c not in pks]
        col_csv = ", ".join(cols)
        json_cols = JSON_COLUMNS_BY_TABLE.get(table, set())

        for row in rows:
            values = ", ".join(sql_literal(row[c], is_json_column=(c in json_cols)) for c in cols)
            if non_pk:
                update_csv = ", ".join(f"{c}=VALUES({c})" for c in non_pk)
                lines.append(
                    f"INSERT INTO {mysql_table} ({col_csv}) VALUES ({values}) ON DUPLICATE KEY UPDATE {update_csv};"
                )
            else:
                lines.append(f"INSERT IGNORE INTO {mysql_table} ({col_csv}) VALUES ({values});")

        lines.append("")

    OUT.write_text("\n".join(lines), encoding="utf-8")
    conn.close()
    return OUT


if __name__ == "__main__":
    output = export()
    print(f"UPSERT export complete: {output}")
