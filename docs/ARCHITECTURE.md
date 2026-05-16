# System Architecture

## High-Level Flow

```text
Browser / Angular SPA
        |
        | HTTP /api/v1 and WebSocket /ws
        v
FastAPI app (app/main.py)
        |
        +-- Auth, license, master-data, workflow, template-set, remote, bot APIs
        |
        +-- SQLAlchemy async sessions
        |       |
        |       v
        |   MySQL database
        |
        +-- Automation services
                |
                +-- ADB device commands and screenshots
                +-- OpenCV template matching
                +-- Tesseract OCR
                +-- Account XML push/pull and queue management
```

## Backend Layers

`app/main.py` is the composition root. It configures CORS, global rate limiting, router dependencies, startup database initialization, default admin creation, and static frontend serving.

`app/api/v1/` contains HTTP and WebSocket adapters. These modules validate request payloads, enforce dependencies, call services, and return API response objects.

`app/services/` contains the business and integration logic. It owns ADB interaction, daily login automation, multi-device queue processing, workflow execution, template matching, OCR, license operations, auth operations, and ngrok tunneling.

`app/models/` contains SQLAlchemy ORM tables. Models are imported during app startup so `Base.metadata.create_all` can create missing tables.

`app/core/` contains shared infrastructure: async database setup and the basic bot lifecycle loop.

`app/schemas/` contains Pydantic response/state models used by the API and lifecycle state.

## Frontend Layers

`frontend-angular/src/app/app.routes.ts` defines the Angular routes. Most routes require `authGuard`; admin screens require `adminGuard`.

`frontend-angular/src/app/services/` provides browser-side services for API calls, token handling, auth interception, WebSocket connection, bot commands, and license checks.

`frontend-angular/src/app/components/` contains standalone UI surfaces:

- Dashboard and live previews.
- Device manager.
- Daily login workflow and account operations.
- Workflow builder.
- Template set manager.
- Mode configuration.
- Settings and remote tunnel controls.
- License and admin license screens.
- Master data administration.

## Authentication and Authorization

Backend auth uses passlib bcrypt hashes, JWT access tokens, and dependency functions in `app/services/auth_service.py`. `app/main.py` applies `require_user` to normal bot/workflow/device routers and `require_admin` to master data routes. License admin endpoints also require admin dependencies inside `app/api/v1/license.py`.

The frontend stores the access token in browser storage through `AuthService`, adds it to API requests, protects routes with guards, and connects the WebSocket with a token query parameter.

## Persistence

The app uses SQLAlchemy async engine creation in `app/core/database.py`. `app/config.py` builds `DATABASE_URL` from environment variables, defaulting to MySQL through `mysql+aiomysql`.

Core tables include:

- `t_users`
- `t_licenses`
- `t_workflows`
- `t_workflow_steps`
- `t_workflow_templates`
- `t_workflow_template_sets`
- `t_template_set_workflow_assoc`
- `t_mode_configurations`
- `t_master_role`
- `t_master_mode`
- `t_master_step_type`

SQL migration files under `db/mysql/` provide full, incremental, data export, rename, and master table setup paths. `MYSQL_MIGRATION.md` has the detailed migration workflow.

## Automation Execution

ADB operations are centralized in `AdbService`. Automation services call ADB to list devices, capture screenshots, tap, swipe, press keys, restart Line Rangers, push/pull account XML, and run privileged shell commands when needed.

Image matching uses `TemplateService` and OpenCV. `WorkflowService` loads workflow steps from the database, normalizes legacy template paths into the current project root, and executes each step against a selected device.

Daily login automation is managed by `DailyLoginService` for single-device work. `MultiDeviceOrchestrator` combines multiple device-specific workers with a shared account queue so account XML files can be processed in parallel.

## Packaging Architecture

`build.py` builds Angular, copies the browser bundle to `frontend/`, and creates a PyInstaller one-directory app around `launcher.py`.

`build_nuitka.py` builds Angular, copies the browser bundle, and compiles a standalone Nuitka package. The runtime launcher sets `IS_PRODUCTION_BUILD=true`, starts Uvicorn locally, and opens the browser.
