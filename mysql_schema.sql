-- Line Rangers Bot Database Schema
-- Database Type: MySQL (Version 5.7+ or 8.0+)

-- Create Database (Optional)
-- CREATE DATABASE IF NOT EXISTS lrg_bot_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE lrg_bot_db;

-- Table: users
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_users_username (username)
) ENGINE=InnoDB;

-- Table: licenses
CREATE TABLE IF NOT EXISTS licenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    license_key VARCHAR(32) NOT NULL UNIQUE,
    customer_name VARCHAR(100) NOT NULL,
    duration_days INT NOT NULL,
    hardware_id VARCHAR(64),
    activated_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT 1,
    INDEX idx_licenses_license_key (license_key)
) ENGINE=InnoDB;

-- Table: workflows
CREATE TABLE IF NOT EXISTS workflows (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    screen_width INT DEFAULT 960,
    screen_height INT DEFAULT 540,
    valid_from DATETIME,
    valid_until DATETIME,
    is_master BOOLEAN DEFAULT 0,
    mode_name VARCHAR(100),
    month_year VARCHAR(7),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_workflows_mode_name (mode_name),
    INDEX idx_workflows_month_year (month_year)
) ENGINE=InnoDB;

-- Table: workflow_steps
CREATE TABLE IF NOT EXISTS workflow_steps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    workflow_id INT NOT NULL,
    order_index INT NOT NULL,
    step_type VARCHAR(50) NOT NULL,
    x INT,
    y INT,
    end_x INT,
    end_y INT,
    swipe_duration_ms INT DEFAULT 300,
    wait_duration_ms INT,
    template_path VARCHAR(500),
    template_name VARCHAR(255),
    threshold FLOAT DEFAULT 0.8,
    match_all BOOLEAN DEFAULT 0,
    skip_if_not_found BOOLEAN DEFAULT 0,
    max_wait_seconds INT DEFAULT 10,
    max_retries INT,
    retry_interval FLOAT DEFAULT 1.0,
    on_match_action VARCHAR(50) DEFAULT 'click',
    condition_type VARCHAR(50),
    goto_step_on_true INT,
    goto_step_on_false INT,
    description VARCHAR(500),
    group_name VARCHAR(100),
    max_iterations INT DEFAULT 20,
    not_found_threshold INT DEFAULT 3,
    click_delay FLOAT DEFAULT 1.5,
    retry_delay FLOAT DEFAULT 2.0,
    expected_color JSON,
    tolerance INT DEFAULT 30,
    check_interval FLOAT DEFAULT 1.0,
    loop_group_name VARCHAR(100),
    stop_template_path VARCHAR(500),
    stop_on_not_found BOOLEAN DEFAULT 1,
    loop_max_iterations INT DEFAULT 100,
    ocr_region JSON,
    target_characters JSON,
    gacha_save_folder VARCHAR(500),
    CONSTRAINT fk_workflow_steps_workflow FOREIGN KEY (workflow_id) REFERENCES workflows (id) ON DELETE CASCADE,
    INDEX idx_workflow_steps_group_name (group_name)
) ENGINE=InnoDB;

-- Table: workflow_templates
CREATE TABLE IF NOT EXISTS workflow_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    description TEXT,
    region_x INT,
    region_y INT,
    region_width INT,
    region_height INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table: workflow_template_sets
CREATE TABLE IF NOT EXISTS workflow_template_sets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(1000),
    category VARCHAR(100) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_workflow_template_sets_category (category)
) ENGINE=InnoDB;

-- Table: template_set_workflow_association
CREATE TABLE IF NOT EXISTS template_set_workflow_association (
    template_set_id INT NOT NULL,
    workflow_id INT NOT NULL,
    order_index INT DEFAULT 0,
    PRIMARY KEY (template_set_id, workflow_id),
    CONSTRAINT fk_tswa_template_set FOREIGN KEY (template_set_id) REFERENCES workflow_template_sets (id) ON DELETE CASCADE,
    CONSTRAINT fk_tswa_workflow FOREIGN KEY (workflow_id) REFERENCES workflows (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table: mode_configurations
CREATE TABLE IF NOT EXISTS mode_configurations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mode_name VARCHAR(100) NOT NULL,
    month_year VARCHAR(7) NOT NULL,
    template_set_id INT NOT NULL,
    is_active BOOLEAN DEFAULT 1,
    priority INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_mode_configs_template_set FOREIGN KEY (template_set_id) REFERENCES workflow_template_sets (id) ON DELETE CASCADE,
    INDEX idx_mode_configurations_mode_name (mode_name),
    INDEX idx_mode_configurations_month_year (month_year)
) ENGINE=InnoDB;
