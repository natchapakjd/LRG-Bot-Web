"""
Master data API endpoints – CRUD for all t_master_* lookup tables.
Tables: t_master_role, t_master_mode, t_master_step_type
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List
from sqlalchemy import select, delete

from app.core.database import async_session_maker
from app.models.master import MasterRole, MasterMode, MasterStepType

router = APIRouter(prefix="/api/v1/master", tags=["Master Data"])


# ── Pydantic schemas ──────────────────────────────────────────────────────

class MasterRoleCreate(BaseModel):
    code: str
    display_name: str
    description: Optional[str] = None
    is_active: Optional[bool] = True
    sort_order: Optional[int] = 0


class MasterRoleUpdate(BaseModel):
    display_name: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[bool] = None
    sort_order: Optional[int] = None


class MasterModeCreate(BaseModel):
    code: str
    display_name: str
    description: Optional[str] = None
    icon: Optional[str] = None
    is_active: Optional[bool] = True
    sort_order: Optional[int] = 0


class MasterModeUpdate(BaseModel):
    display_name: Optional[str] = None
    description: Optional[str] = None
    icon: Optional[str] = None
    is_active: Optional[bool] = None
    sort_order: Optional[int] = None


class MasterStepTypeCreate(BaseModel):
    code: str
    display_name: str
    description: Optional[str] = None
    category: Optional[str] = "action"
    icon: Optional[str] = None
    is_active: Optional[bool] = True
    sort_order: Optional[int] = 0


class MasterStepTypeUpdate(BaseModel):
    display_name: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    icon: Optional[str] = None
    is_active: Optional[bool] = None
    sort_order: Optional[int] = None


# ── Helper ────────────────────────────────────────────────────────────────

def _apply_update(obj, data: dict):
    """Apply non-None fields from dict to ORM object."""
    for key, value in data.items():
        if value is not None:
            setattr(obj, key, value)


# ── t_master_role endpoints ───────────────────────────────────────────────

@router.get("/roles")
async def list_roles():
    async with async_session_maker() as session:
        result = await session.execute(select(MasterRole).order_by(MasterRole.sort_order, MasterRole.id))
        return {"success": True, "data": [r.to_dict() for r in result.scalars().all()]}


@router.post("/roles")
async def create_role(body: MasterRoleCreate):
    async with async_session_maker() as session:
        existing = await session.execute(select(MasterRole).where(MasterRole.code == body.code))
        if existing.scalar_one_or_none():
            raise HTTPException(status_code=409, detail=f"Role code '{body.code}' already exists")
        obj = MasterRole(**body.model_dump())
        session.add(obj)
        await session.commit()
        await session.refresh(obj)
        return {"success": True, "data": obj.to_dict()}


@router.put("/roles/{role_id}")
async def update_role(role_id: int, body: MasterRoleUpdate):
    async with async_session_maker() as session:
        result = await session.execute(select(MasterRole).where(MasterRole.id == role_id))
        obj = result.scalar_one_or_none()
        if not obj:
            raise HTTPException(status_code=404, detail="Role not found")
        _apply_update(obj, {k: v for k, v in body.model_dump().items() if v is not None})
        await session.commit()
        await session.refresh(obj)
        return {"success": True, "data": obj.to_dict()}


@router.delete("/roles/{role_id}")
async def delete_role(role_id: int):
    async with async_session_maker() as session:
        result = await session.execute(select(MasterRole).where(MasterRole.id == role_id))
        if not result.scalar_one_or_none():
            raise HTTPException(status_code=404, detail="Role not found")
        await session.execute(delete(MasterRole).where(MasterRole.id == role_id))
        await session.commit()
        return {"success": True, "message": f"Role {role_id} deleted"}


# ── t_master_mode endpoints ───────────────────────────────────────────────

@router.get("/modes")
async def list_modes(active_only: bool = False):
    async with async_session_maker() as session:
        q = select(MasterMode).order_by(MasterMode.sort_order, MasterMode.id)
        if active_only:
            q = q.where(MasterMode.is_active == True)
        result = await session.execute(q)
        return {"success": True, "data": [r.to_dict() for r in result.scalars().all()]}


@router.post("/modes")
async def create_mode(body: MasterModeCreate):
    async with async_session_maker() as session:
        existing = await session.execute(select(MasterMode).where(MasterMode.code == body.code))
        if existing.scalar_one_or_none():
            raise HTTPException(status_code=409, detail=f"Mode code '{body.code}' already exists")
        obj = MasterMode(**body.model_dump())
        session.add(obj)
        await session.commit()
        await session.refresh(obj)
        return {"success": True, "data": obj.to_dict()}


@router.put("/modes/{mode_id}")
async def update_mode(mode_id: int, body: MasterModeUpdate):
    async with async_session_maker() as session:
        result = await session.execute(select(MasterMode).where(MasterMode.id == mode_id))
        obj = result.scalar_one_or_none()
        if not obj:
            raise HTTPException(status_code=404, detail="Mode not found")
        _apply_update(obj, {k: v for k, v in body.model_dump().items() if v is not None})
        await session.commit()
        await session.refresh(obj)
        return {"success": True, "data": obj.to_dict()}


@router.delete("/modes/{mode_id}")
async def delete_mode(mode_id: int):
    async with async_session_maker() as session:
        result = await session.execute(select(MasterMode).where(MasterMode.id == mode_id))
        if not result.scalar_one_or_none():
            raise HTTPException(status_code=404, detail="Mode not found")
        await session.execute(delete(MasterMode).where(MasterMode.id == mode_id))
        await session.commit()
        return {"success": True, "message": f"Mode {mode_id} deleted"}


# ── t_master_step_type endpoints ──────────────────────────────────────────

@router.get("/step-types")
async def list_step_types(category: Optional[str] = None, active_only: bool = False):
    async with async_session_maker() as session:
        q = select(MasterStepType).order_by(MasterStepType.sort_order, MasterStepType.id)
        if category:
            q = q.where(MasterStepType.category == category)
        if active_only:
            q = q.where(MasterStepType.is_active == True)
        result = await session.execute(q)
        return {"success": True, "data": [r.to_dict() for r in result.scalars().all()]}


@router.post("/step-types")
async def create_step_type(body: MasterStepTypeCreate):
    async with async_session_maker() as session:
        existing = await session.execute(select(MasterStepType).where(MasterStepType.code == body.code))
        if existing.scalar_one_or_none():
            raise HTTPException(status_code=409, detail=f"Step type code '{body.code}' already exists")
        obj = MasterStepType(**body.model_dump())
        session.add(obj)
        await session.commit()
        await session.refresh(obj)
        return {"success": True, "data": obj.to_dict()}


@router.put("/step-types/{step_type_id}")
async def update_step_type(step_type_id: int, body: MasterStepTypeUpdate):
    async with async_session_maker() as session:
        result = await session.execute(select(MasterStepType).where(MasterStepType.id == step_type_id))
        obj = result.scalar_one_or_none()
        if not obj:
            raise HTTPException(status_code=404, detail="Step type not found")
        _apply_update(obj, {k: v for k, v in body.model_dump().items() if v is not None})
        await session.commit()
        await session.refresh(obj)
        return {"success": True, "data": obj.to_dict()}


@router.delete("/step-types/{step_type_id}")
async def delete_step_type(step_type_id: int):
    async with async_session_maker() as session:
        result = await session.execute(select(MasterStepType).where(MasterStepType.id == step_type_id))
        if not result.scalar_one_or_none():
            raise HTTPException(status_code=404, detail="Step type not found")
        await session.execute(delete(MasterStepType).where(MasterStepType.id == step_type_id))
        await session.commit()
        return {"success": True, "message": f"Step type {step_type_id} deleted"}
