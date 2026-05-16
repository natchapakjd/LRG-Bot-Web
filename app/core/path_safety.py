"""
Helpers for validating local filesystem paths used by API endpoints.
"""
from pathlib import Path
from typing import Iterable

from app.config import FILE_OPERATION_ROOTS


def _resolve(path: str | Path) -> Path:
    return Path(path).expanduser().resolve(strict=False)


def _is_relative_to(path: Path, root: Path) -> bool:
    try:
        path.relative_to(root)
        return True
    except ValueError:
        return False


def is_allowed_path(path: str | Path, roots: Iterable[Path] | None = None) -> bool:
    resolved = _resolve(path)
    allowed_roots = list(roots or FILE_OPERATION_ROOTS)
    return any(_is_relative_to(resolved, root) for root in allowed_roots)


def require_allowed_path(path: str | Path) -> Path:
    resolved = _resolve(path)
    if not is_allowed_path(resolved):
        roots = ", ".join(str(root) for root in FILE_OPERATION_ROOTS)
        raise ValueError(f"Path is outside allowed file roots: {resolved}. Allowed roots: {roots}")
    return resolved


def require_safe_filename(filename: str, suffix: str | None = None) -> str:
    clean = filename.strip()
    if suffix and clean.lower().endswith(suffix.lower()):
        clean = clean[: -len(suffix)]
    if not clean:
        raise ValueError("Filename is required")
    if Path(clean).name != clean or any(sep in clean for sep in ("/", "\\")):
        raise ValueError("Filename must not contain path separators")
    if clean in {".", ".."}:
        raise ValueError("Invalid filename")
    return f"{clean}{suffix or ''}"


def safe_relative_folder(label: str) -> Path:
    clean = label.strip()
    if not clean:
        return Path()

    candidate = Path(clean)
    if candidate.is_absolute() or any(part in {"", ".", ".."} for part in candidate.parts):
        raise ValueError("Folder label must be a safe relative path")
    return candidate
