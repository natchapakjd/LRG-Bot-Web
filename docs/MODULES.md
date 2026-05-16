# Module Catalog

## Root Files

- `app/main.py`: FastAPI application factory, router registration, startup/shutdown hooks, client license auth endpoint, and packaged frontend serving.
- `app/config.py`: Environment loading, project paths, ADB defaults, database URL construction, security settings, CORS, rate limits, license bypass, and production mode flag.
- `launcher.py`: Packaged-app launcher that starts Uvicorn on localhost and opens the browser.
- `build.py`: PyInstaller build pipeline for frontend plus backend package.
- `build_nuitka.py`: Nuitka build pipeline for standalone compiled distribution.
- `requirements.txt`: Python runtime and packaging dependencies.
- `database_schema.sql`, `mysql_schema.sql`: Legacy/root schema references kept for compatibility and migration context.

## `app/api/v1`

- `__init__.py`: Exports the primary routers used by `app/main.py`.
- `auth.py`: `/api/v1/auth` registration, login, current-user profile, and auth check endpoints.
- `endpoints.py`: Main bot controls, daily-login APIs, device APIs, multi-device APIs, duplicate/account copy/export helpers.
- `license.py`: Public license activation/status/hardware-id/check APIs and admin license management APIs.
- `master.py`: Admin CRUD for role, mode, and step type lookup tables.
- `remote.py`: ngrok tunnel start, stop, status, and QR code endpoints.
- `template_set.py`: Workflow template set CRUD and mode configuration endpoints.
- `websocket.py`: WebSocket connection manager, token authentication, and bidirectional command/status messages.
- `workflow.py`: Workflow CRUD, clone, set-master, execute, list templates, and capture-template APIs.

## `app/core`

- `database.py`: Async SQLAlchemy engine, session maker, declarative `Base`, database initialization, and session dependency.
- `lifecycle.py`: Basic bot state machine and background loop for start, stop, pause, resume, screenshot scanning, and log callbacks.

## `app/models`

- `user.py`: `t_users` model and role constants.
- `license.py`: `t_licenses` model with activation, expiry, remaining-days, and serialization helpers.
- `workflow.py`: `t_workflows`, `t_workflow_steps`, and `t_workflow_templates` models for the visual workflow builder.
- `workflow_template_set.py`: `t_workflow_template_sets`, many-to-many workflow association, and `t_mode_configurations`.
- `master.py`: Lookup models for roles, modes, and step types.
- `__init__.py`: Package marker.

## `app/schemas`

- `status.py`: `BotState`, `BotStatus`, and `CommandResponse` Pydantic models.
- `__init__.py`: Package marker.

## `app/services`

- `adb_service.py`: ADB integration for connect/disconnect, device commands, screenshots, taps, swipes, app launch/stop, shell, and file transfer.
- `auth_service.py`: Password hashing, JWT creation/verification, user registration/login, default admin creation, and FastAPI auth dependencies.
- `daily_login_service.py`: Single-device daily-login workflow, account folder scan, account XML push/pull, reward claiming, duplicate detection, copy/export helpers, and status tracking.
- `device_manager.py`: Device discovery, device status modeling, task assignment, running state, and per-device service tracking.
- `license_service.py`: License creation, activation, hardware-id generation/binding, status checks, revoke, and hardware reset.
- `multi_device_service.py`: Shared account queue and orchestrator for parallel multi-device account processing.
- `ngrok_service.py`: ngrok tunnel lifecycle, public URL state, QR generation, and status.
- `ocr_service.py`: Tesseract availability checks, image preprocessing, text extraction, and fuzzy target matching.
- `template_service.py`: OpenCV template loading/cache, single match, fast grayscale match, multi-match, and daily-claim template constants.
- `template_set_service.py`: Template set CRUD, workflow membership, mode configuration, and active configuration lookup.
- `vision_service.py`: Lower-level image/template recognition helper used by the generic bot lifecycle.
- `workflow_service.py`: Workflow CRUD, mode lookup, step creation, template path normalization, workflow execution, and template capture.
- `__init__.py`: Exports commonly used service classes/functions.

## Frontend Angular Modules

- `src/app/app.component.ts`: Shell layout and application chrome.
- `src/app/app.routes.ts`: Route table and route guards.
- `src/app/guards/auth.guard.ts`: User/admin route protection.
- `src/app/services/auth.service.ts`: Token storage, login, current user, auth status, and request auth handling.
- `src/app/services/bot.service.ts`: Bot command wrapper and WebSocket status/log connection.
- `src/app/services/license.service.ts`: License-related browser-side calls.
- `src/app/models/bot.model.ts`: Frontend types for bot status and WebSocket messages.
- `components/dashboard`: Main dashboard and live device preview entry screen.
- `components/device-manager`: Connected ADB devices, assignment, screenshot, and per-device daily login controls.
- `components/daily-login`: Account folder scanning, multi-device processing, settings, screenshots, duplicates, copy, export, and status logs.
- `components/workflow-builder`: Workflow list/editor, screen capture, step configuration, template capture, execution, clone, and master assignment.
- `components/template-set-manager`: Template set CRUD and workflow membership.
- `components/mode-configuration`: Assigns workflows to mode/month selections.
- `components/master-data`: Admin lookup table management.
- `components/settings`: Remote tunnel controls, master workflow display, and settings/admin utilities.
- `components/license`: Client license activation and status.
- `components/admin-license`: Admin license list/create/revoke/reset.
- `components/login`: Admin/user login form.
- `components/control-panel`, `components/header`, `components/screen-preview`: Reusable UI sections.

## Database and Migration Files

- `db/mysql/00_full_migration.sql`: Entry point reference for full migration package.
- `db/mysql/01_schema.sql`: MySQL schema.
- `db/mysql/02_stored_procedures.sql`: Stored procedures.
- `db/mysql/03_data_from_sqlite.sql`: Exported SQLite data inserts.
- `db/mysql/11_schema_incremental.sql`: Incremental schema changes.
- `db/mysql/12_incremental_entrypoint.sql`: Incremental migration entry point.
- `db/mysql/13_data_upsert_from_sqlite.sql`: Upsert-based exported data.
- `db/mysql/14_fix_workflow_step_paths.sql`: Workflow path repair migration.
- `db/mysql/20_rename_tables.sql`: Table rename migration.
- `db/mysql/21_master_tables.sql`: Master lookup table migration/data.
- `scripts/run_mysql_migration.py`: Runs the full MySQL migration.
- `scripts/run_mysql_incremental_migration.py`: Runs no-drop incremental migration with backup.
- `scripts/run_rename_migration.py`: Runs table rename migration.
- `scripts/mysql_backup_restore.py`: Backup/restore utility.
- `scripts/export_sqlite_to_mysql_inserts.py`: Exports SQLite data as MySQL inserts.
- `scripts/export_sqlite_to_mysql_upserts.py`: Exports SQLite data as MySQL upserts.
- `scripts/check_db.py`, `fix_db.py`, `fix_db_placeholder.py`, `verify_fix.py`: Database inspection/repair utilities.
- `scripts/migrate_add_mode_fields.py`, `migrate_loop_color.py`, `check_wait_for_color.py`: Workflow schema/feature migration helpers.
- `scripts/test_game_functions.py`: Manual game automation smoke helper.

## Template and Asset Folders

- `workflow_templates/`: Images captured for workflow matching.
- `templates/daily-claims/`: Daily reward claim button templates.
- `templates/re-id/`: Re-id flow template images.
- `accounts/`: Local account working folder, currently empty in the tracked tree.
- `workflows/`: Local workflow working folder, currently empty in the tracked tree.
- `backups/mysql/`: Existing SQL backup snapshots.
