"""
scripts/run_rename_migration.py
--------------------------------
Handles the transition from un-prefixed tables to t_ prefixed tables.

Steps:
  1. Auto-backup
  2. Drop the newly-created empty t_ data tables (created by the incremental schema run)
  3. RENAME the old data tables to their t_ counterparts
  4. Apply master seed data (21_master_tables.sql)

Safe to run only once. Will detect if rename already happened and skip gracefully.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

import pymysql
from scripts.mysql_backup_restore import backup

DB_CFG = dict(host="localhost", port=51579, user="root", password="root",
               database="lineranger_automation", charset="utf8mb4")

# Mapping: old name → new t_ name
RENAME_MAP = {
    "users":                          "t_users",
    "licenses":                       "t_licenses",
    "workflows":                      "t_workflows",
    "workflow_templates":             "t_workflow_templates",
    "workflow_template_sets":         "t_workflow_template_sets",
    "workflow_steps":                 "t_workflow_steps",
    "template_set_workflow_association": "t_template_set_workflow_assoc",
    "mode_configurations":            "t_mode_configurations",
}

# Empty t_ tables to drop before renaming (created by IF NOT EXISTS runs)
EMPTY_T_TABLES = list(RENAME_MAP.values())


def get_tables(conn) -> list[str]:
    with conn.cursor() as cur:
        cur.execute("SHOW TABLES")
        return [r[0] for r in cur.fetchall()]


def run():
    print("=== Rename Migration: un-prefixed → t_ ===\n")

    # 1. Backup
    backup_path = backup()
    print(f"[1/4] Backup: {backup_path}\n")

    conn = pymysql.connect(**DB_CFG)
    try:
        conn.autocommit = False
        tables = get_tables(conn)

        # Check if rename already done
        old_present = [t for t in RENAME_MAP.keys() if t in tables]
        if not old_present:
            print("[!] Old table names not found – rename may already be complete.")
            print("    Current tables:", [t for t in tables if t.startswith("t_")])
            return

        print(f"[2/4] Found {len(old_present)} old tables to rename: {old_present}")

        with conn.cursor() as cur:
            conn.autocommit = True
            cur.execute("SET FOREIGN_KEY_CHECKS = 0")

            # Drop empty t_ data tables (not master tables) that were created by IF NOT EXISTS
            for t_ in EMPTY_T_TABLES:
                if t_ in tables:
                    cur.execute(f"DROP TABLE `{t_}`")
                    print(f"  Dropped empty table: {t_}")

        # Build RENAME TABLE ... TO ... statement
        pairs = []
        for old, new in RENAME_MAP.items():
            if old in old_present:
                pairs.append(f"`{old}` TO `{new}`")

        if pairs:
            rename_sql = "RENAME TABLE " + ", ".join(pairs)
            with conn.cursor() as cur:
                print(f"\n[3/4] Renaming {len(pairs)} tables...")
                cur.execute(rename_sql)
                print("  RENAME TABLE executed successfully.")

        # Re-enable FK checks
        with conn.cursor() as cur:
            cur.execute("SET FOREIGN_KEY_CHECKS = 1")

        print("\n[4/4] Applying master seed data (21_master_tables.sql)...")
        _apply_sql_file(conn, ROOT / "db" / "mysql" / "21_master_tables.sql")

        tables_after = get_tables(conn)
        t_tables = [t for t in tables_after if t.startswith("t_")]
        print(f"\nDone. t_ tables in DB ({len(t_tables)}): {t_tables}")

    finally:
        conn.close()


def _apply_sql_file(conn, path: Path):
    sql = path.read_text(encoding="utf-8")
    # Split at semicolons (simple statements only - no stored procedures here)
    statements = [s.strip() for s in sql.split(";") if s.strip() and not s.strip().startswith("--")]
    count = 0
    with conn.cursor() as cur:
        for stmt in statements:
            try:
                cur.execute(stmt)
                count += 1
            except Exception as e:
                print(f"  [warn] Skipped: {e} | SQL: {stmt[:80]}")
    conn.commit()
    print(f"  Applied {count} statements from {path.name}")


if __name__ == "__main__":
    run()
