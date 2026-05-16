# Project Overview

LRG Bot is a desktop-local automation system for Line Rangers. The backend exposes a web API, controls Android devices through ADB, captures screenshots, uses OpenCV templates and optional OCR to decide what to tap, and stores workflows plus admin data in MySQL. The frontend is an Angular single-page app for monitoring devices, building workflows, managing daily-login account batches, configuring modes, and administering licenses.

## Primary Capabilities

- User authentication with JWT bearer tokens and role checks.
- License activation, hardware binding, admin license creation, revoke, and reset operations.
- Single-device bot lifecycle controls: start, stop, pause, resume, and status.
- Daily login automation for account XML files, including scan, progress tracking, duplicate finding, copying, exporting, and optional reward claiming.
- Multi-device orchestration where several ADB devices process a shared account queue.
- Visual workflow builder with click, swipe, wait, image matching, repeat group, color wait, restart game, press back, and OCR-based gacha checks.
- Template capture and reusable workflow template sets.
- Master data management for roles, game modes, and workflow step types.
- Remote access tunnel management through ngrok with QR code generation.
- Angular dashboard, device manager, daily-login panel, workflow builder, settings, admin, and license screens.

## Runtime Shape

The main backend entry point is `app/main.py`. It creates the FastAPI application, registers routers, applies CORS and rate limiting, initializes the database on startup, ensures a default admin exists, and serves a built Angular frontend when packaged.

The development frontend lives in `frontend-angular/`. In development it runs separately with `npm start` and proxies backend traffic through `proxy.conf.json`. In a packaged build, `build.py` or `build_nuitka.py` builds Angular and copies the static bundle into a `frontend/` folder that the backend can serve.

## Data and Assets

- `workflow_templates/` stores captured or curated workflow image templates used by visual workflow steps.
- `templates/daily-claims/` stores static template images for daily reward claiming.
- `templates/re-id/` stores static reference images for re-id related flows.
- `db/mysql/` stores MySQL schema, stored procedures, exported data, and incremental migration scripts.
- `backups/mysql/` stores existing SQL backup snapshots.
- `licenses.db` appears to be a local runtime license database artifact and was left in place.

## Important External Dependencies

- Android Debug Bridge (`adb`) must be available for device discovery, screenshots, taps, swipes, file push/pull, and shell commands.
- MySQL is the default database target through `mysql+aiomysql`.
- Tesseract OCR is needed only for OCR/gacha workflows.
- Node.js and npm are needed to run or build the Angular frontend.
- ngrok is used through `pyngrok` for remote access.
