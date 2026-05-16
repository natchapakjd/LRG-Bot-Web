# Operations Guide

## Environment

Copy `.env.example` to `.env` and adjust values for the local machine. Important settings include:

- `DB_DRIVER`, `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, or direct `DATABASE_URL`.
- `SECRET_KEY` for JWT signing.
- `DEFAULT_ADMIN_USERNAME` and `DEFAULT_ADMIN_PASSWORD` for first startup.
- `ALLOWED_ORIGINS` for frontend origins.
- `LICENSE_BYPASS` for development license bypass behavior.
- `ADB_PATH` if `adb` is not on `PATH`.

`app/config.py` defaults to MySQL at `localhost:51579` with database `lineranger_automation`.

## Backend Development

```powershell
pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

The API docs are available at `http://localhost:8000/docs`.

On startup the backend creates missing tables from SQLAlchemy metadata and ensures the default admin user exists.

## Frontend Development

```powershell
cd frontend-angular
npm install
npm start
```

Angular runs on its dev server and proxies:

- `/api` to `http://localhost:8000`
- `/ws` to `ws://localhost:8000`

## Database Migration

For the full migration path:

```powershell
.\.venv\Scripts\python.exe scripts\run_mysql_migration.py
```

For incremental migration with backup:

```powershell
.\.venv\Scripts\python.exe scripts\run_mysql_incremental_migration.py
```

See `MYSQL_MIGRATION.md` for the full migration details.

## Device Requirements

ADB must be installed and available. Devices or emulators must appear in:

```powershell
adb devices
```

The backend uses ADB for screenshots, taps, swipes, back key, game restart, shell commands, and account XML transfer.

## OCR Requirements

OCR/gacha checks require Tesseract. If Tesseract is missing, non-OCR image matching workflows can still run, but OCR steps will report unavailable status.

## Packaging

PyInstaller:

```powershell
python build.py
```

Nuitka:

```powershell
python build_nuitka.py
```

Build outputs are generated and ignored. They can be deleted and regenerated.

## Smoke Checks

Useful manual checks after setup:

- `python -m compileall app scripts` to catch syntax errors.
- `python -m uvicorn app.main:app --host 127.0.0.1 --port 8000` to validate backend startup.
- `npm run build` inside `frontend-angular/` to validate the frontend.
- Open `/docs` and verify route registration.
- Use `/api/v1/devices` after connecting an emulator/device.
