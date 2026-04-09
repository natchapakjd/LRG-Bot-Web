"""
Master / lookup table models.
Tables: t_master_role, t_master_mode, t_master_step_type
"""
from datetime import datetime
from sqlalchemy import Column, Integer, String, Boolean, DateTime
from app.core.database import Base


class MasterRole(Base):
    """Lookup table for user roles (admin, user)."""
    __tablename__ = "t_master_role"

    id = Column(Integer, primary_key=True, autoincrement=True)
    code = Column(String(50), nullable=False, unique=True, index=True)
    display_name = Column(String(100), nullable=False)
    description = Column(String(500), nullable=True)
    is_active = Column(Boolean, default=True)
    sort_order = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "code": self.code,
            "display_name": self.display_name,
            "description": self.description,
            "is_active": self.is_active,
            "sort_order": self.sort_order,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }


class MasterMode(Base):
    """Lookup table for game / operation modes (daily-login, gacha, etc.)."""
    __tablename__ = "t_master_mode"

    id = Column(Integer, primary_key=True, autoincrement=True)
    code = Column(String(100), nullable=False, unique=True, index=True)
    display_name = Column(String(150), nullable=False)
    description = Column(String(1000), nullable=True)
    icon = Column(String(10), nullable=True)
    is_active = Column(Boolean, default=True)
    sort_order = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "code": self.code,
            "display_name": self.display_name,
            "description": self.description,
            "icon": self.icon,
            "is_active": self.is_active,
            "sort_order": self.sort_order,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }


class MasterStepType(Base):
    """Lookup table for workflow step types (click, swipe, image_match, etc.)."""
    __tablename__ = "t_master_step_type"

    id = Column(Integer, primary_key=True, autoincrement=True)
    code = Column(String(50), nullable=False, unique=True, index=True)
    display_name = Column(String(150), nullable=False)
    description = Column(String(1000), nullable=True)
    category = Column(String(50), nullable=False, default="action", index=True)
    icon = Column(String(10), nullable=True)
    is_active = Column(Boolean, default=True)
    sort_order = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self) -> dict:
        return {
            "id": self.id,
            "code": self.code,
            "display_name": self.display_name,
            "description": self.description,
            "category": self.category,
            "icon": self.icon,
            "is_active": self.is_active,
            "sort_order": self.sort_order,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
