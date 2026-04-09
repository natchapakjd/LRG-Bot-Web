-- ============================================================
-- 21_master_tables.sql
-- Create master/lookup tables (t_master_ prefix) + seed data
-- Idempotent: uses CREATE TABLE IF NOT EXISTS
-- ============================================================

USE lineranger_automation;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------
-- t_master_role  – user roles
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS t_master_role (
    id          INT           AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(50)   NOT NULL UNIQUE COMMENT 'Internal key used in code (e.g. admin, user)',
    display_name VARCHAR(100) NOT NULL        COMMENT 'Human-readable label',
    description  VARCHAR(500) NULL,
    is_active    TINYINT(1)   NOT NULL DEFAULT 1,
    sort_order   INT          NOT NULL DEFAULT 0,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_master_role_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Lookup table for user roles';

INSERT INTO t_master_role (code, display_name, description, sort_order)
VALUES
    ('admin', 'Administrator', 'Full access to all features including license and user management', 0),
    ('user',  'User',          'Standard access to bot features', 1)
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    description  = VALUES(description);

-- -----------------------------------------------------------
-- t_master_mode  – game / operation modes
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS t_master_mode (
    id           INT           AUTO_INCREMENT PRIMARY KEY,
    code         VARCHAR(100)  NOT NULL UNIQUE COMMENT 'Internal key used in workflows and configs',
    display_name VARCHAR(150)  NOT NULL,
    description  VARCHAR(1000) NULL,
    icon         VARCHAR(10)   NULL COMMENT 'Emoji icon for UI display',
    is_active    TINYINT(1)    NOT NULL DEFAULT 1,
    sort_order   INT           NOT NULL DEFAULT 0,
    created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_master_mode_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Lookup table for bot operation modes / workflow categories';

INSERT INTO t_master_mode (code, display_name, description, icon, sort_order)
VALUES
    ('daily-login', 'Daily Login',   'Automated daily login and reward collection',        NULL, 0),
    ('re-id',       'Re-ID',         'Account re-identification workflow',                  NULL, 1),
    ('stage-farm',  'Stage Farm',    'Automated stage grinding / resource farming',         NULL, 2),
    ('gacha',       'Gacha',         'Automated gacha / summon workflow',                   NULL, 3),
    ('pvp',         'PvP',           'Player-versus-player automated battles',              NULL, 4),
    ('guild-raid',  'Guild Raid',    'Guild raid participation automation',                 NULL, 5),
    ('event',       'Event',         'Time-limited event automation',                       NULL, 6),
    ('custom',      'Custom',        'User-defined custom workflow mode',                   NULL, 7)
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    description  = VALUES(description);

-- -----------------------------------------------------------
-- t_master_step_type  – workflow step action types
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS t_master_step_type (
    id           INT          AUTO_INCREMENT PRIMARY KEY,
    code         VARCHAR(50)  NOT NULL UNIQUE COMMENT 'Internal key used in workflow_steps.step_type',
    display_name VARCHAR(150) NOT NULL,
    description  VARCHAR(1000) NULL,
    category     VARCHAR(50)  NOT NULL DEFAULT 'action' COMMENT 'action | control | detection | loop',
    icon         VARCHAR(10)  NULL,
    is_active    TINYINT(1)   NOT NULL DEFAULT 1,
    sort_order   INT          NOT NULL DEFAULT 0,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_master_step_type_code (code),
    INDEX idx_master_step_type_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Lookup table for workflow step types';

INSERT INTO t_master_step_type (code, display_name, description, category, icon, sort_order)
VALUES
    -- Actions
    ('click',          'Click',             'Tap/click at a specific coordinate',                          'action',    NULL,  0),
    ('swipe',          'Swipe',             'Swipe from one coordinate to another',                        'action',    NULL,  1),
    ('wait',           'Wait',              'Pause execution for a set duration',                          'action',    NULL,  2),
    -- Detection
    ('image_match',    'Image Match',       'Wait for a template image to appear on screen then act',     'detection', NULL, 10),
    ('find_all_click', 'Find All & Click',  'Find all occurrences of a template and click each one',      'detection', NULL, 11),
    ('wait_for_color', 'Wait for Color',    'Wait until a specific pixel color is present',               'detection', NULL, 12),
    ('gacha_check',    'Gacha Check',       'OCR-based gacha result detection and decision',              'detection', NULL, 13),
    -- Control flow
    ('conditional',    'Conditional',       'Branch execution based on a condition result',               'control',   NULL, 20),
    -- Loops
    ('loop_click',     'Loop Click',        'Repeatedly click template matches up to a limit',            'loop',      NULL, 30),
    ('repeat_group',   'Repeat Group',      'Repeat a named step group until a stop condition is met',    'loop',      NULL, 31)
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    description  = VALUES(description),
    category     = VALUES(category);

SET FOREIGN_KEY_CHECKS = 1;
