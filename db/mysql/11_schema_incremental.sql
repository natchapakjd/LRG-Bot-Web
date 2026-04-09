-- Incremental / zero-downtime friendly schema migration (v2 – t_ prefix)
-- This script does not drop tables.
-- Tables are renamed via 20_rename_tables.sql before this runs on an existing DB,
-- OR this script is run fresh on a new database.

CREATE DATABASE IF NOT EXISTS lineranger_automation
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE lineranger_automation;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ── Master / lookup tables ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS t_master_role (
    id           INT          AUTO_INCREMENT PRIMARY KEY,
    code         VARCHAR(50)  NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    description  VARCHAR(500) NULL,
    is_active    TINYINT(1)   NOT NULL DEFAULT 1,
    sort_order   INT          NOT NULL DEFAULT 0,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_master_role_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS t_master_mode (
    id           INT           AUTO_INCREMENT PRIMARY KEY,
    code         VARCHAR(100)  NOT NULL UNIQUE,
    display_name VARCHAR(150)  NOT NULL,
    description  VARCHAR(1000) NULL,
    icon         VARCHAR(10)   NULL,
    is_active    TINYINT(1)    NOT NULL DEFAULT 1,
    sort_order   INT           NOT NULL DEFAULT 0,
    created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_master_mode_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS t_master_step_type (
    id           INT          AUTO_INCREMENT PRIMARY KEY,
    code         VARCHAR(50)  NOT NULL UNIQUE,
    display_name VARCHAR(150) NOT NULL,
    description  VARCHAR(1000) NULL,
    category     VARCHAR(50)  NOT NULL DEFAULT 'action',
    icon         VARCHAR(10)  NULL,
    is_active    TINYINT(1)   NOT NULL DEFAULT 1,
    sort_order   INT          NOT NULL DEFAULT 0,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_master_step_type_code (code),
    INDEX idx_master_step_type_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Core tables ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS t_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_users_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS t_licenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    license_key VARCHAR(32) NOT NULL UNIQUE,
    customer_name VARCHAR(100) NOT NULL,
    duration_days INT NOT NULL,
    hardware_id VARCHAR(64) NULL,
    activated_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    INDEX idx_licenses_license_key (license_key),
    INDEX idx_licenses_hardware_id (hardware_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS t_workflows (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    screen_width INT NOT NULL DEFAULT 960,
    screen_height INT NOT NULL DEFAULT 540,
    valid_from DATETIME NULL,
    valid_until DATETIME NULL,
    is_master TINYINT(1) NOT NULL DEFAULT 0,
    mode_name VARCHAR(100) NULL,
    month_year VARCHAR(7) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_workflows_mode_name (mode_name),
    INDEX idx_workflows_month_year (month_year),
    INDEX idx_workflows_is_master (is_master)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS t_workflow_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    description TEXT NULL,
    region_x INT NULL,
    region_y INT NULL,
    region_width INT NULL,
    region_height INT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS t_workflow_template_sets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(1000) NULL,
    category VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_workflow_template_sets_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS t_workflow_steps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    workflow_id INT NOT NULL,
    order_index INT NOT NULL,
    step_type VARCHAR(50) NOT NULL,
    x INT NULL,
    y INT NULL,
    end_x INT NULL,
    end_y INT NULL,
    swipe_duration_ms INT NOT NULL DEFAULT 300,
    wait_duration_ms INT NULL,
    template_path VARCHAR(500) NULL,
    template_name VARCHAR(255) NULL,
    threshold FLOAT NOT NULL DEFAULT 0.8,
    match_all TINYINT(1) NOT NULL DEFAULT 0,
    skip_if_not_found TINYINT(1) NOT NULL DEFAULT 0,
    max_wait_seconds INT NOT NULL DEFAULT 10,
    max_retries INT NULL,
    retry_interval FLOAT NOT NULL DEFAULT 1.0,
    on_match_action VARCHAR(50) NOT NULL DEFAULT 'click',
    condition_type VARCHAR(50) NULL,
    goto_step_on_true INT NULL,
    goto_step_on_false INT NULL,
    description VARCHAR(500) NULL DEFAULT '',
    group_name VARCHAR(100) NULL,
    max_iterations INT NOT NULL DEFAULT 20,
    not_found_threshold INT NOT NULL DEFAULT 3,
    click_delay FLOAT NOT NULL DEFAULT 1.5,
    retry_delay FLOAT NOT NULL DEFAULT 2.0,
    expected_color JSON NULL,
    tolerance INT NOT NULL DEFAULT 30,
    check_interval FLOAT NOT NULL DEFAULT 1.0,
    loop_group_name VARCHAR(100) NULL,
    stop_template_path VARCHAR(500) NULL,
    stop_on_not_found TINYINT(1) NOT NULL DEFAULT 1,
    loop_max_iterations INT NOT NULL DEFAULT 100,
    ocr_region JSON NULL,
    target_characters JSON NULL,
    gacha_save_folder VARCHAR(500) NULL,
    CONSTRAINT fk_workflow_steps_workflow
      FOREIGN KEY (workflow_id) REFERENCES t_workflows (id)
      ON DELETE CASCADE,
    INDEX idx_workflow_steps_workflow_id (workflow_id),
    INDEX idx_workflow_steps_group_name (group_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS t_template_set_workflow_assoc (
    template_set_id INT NOT NULL,
    workflow_id INT NOT NULL,
    order_index INT NOT NULL DEFAULT 0,
    PRIMARY KEY (template_set_id, workflow_id),
    CONSTRAINT fk_tswa_template_set
      FOREIGN KEY (template_set_id) REFERENCES t_workflow_template_sets (id)
      ON DELETE CASCADE,
    CONSTRAINT fk_tswa_workflow
      FOREIGN KEY (workflow_id) REFERENCES t_workflows (id)
      ON DELETE CASCADE,
    INDEX idx_tswa_workflow_id (workflow_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS t_mode_configurations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mode_name VARCHAR(100) NOT NULL,
    month_year VARCHAR(7) NOT NULL,
    template_set_id INT NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    priority INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_mode_configs_template_set
      FOREIGN KEY (template_set_id) REFERENCES t_workflow_template_sets (id)
      ON DELETE CASCADE,
    INDEX idx_mode_configurations_mode_name (mode_name),
    INDEX idx_mode_configurations_month_year (month_year),
    INDEX idx_mode_configurations_active_priority (is_active, priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

