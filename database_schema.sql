-- Line Rangers Bot Database Schema
-- Database Type: SQLite

-- Table: users
-- Purpose: Stores user authentication and role information.
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- Table: licenses
-- Purpose: Manages customer licenses and hardware binding (HWID).
CREATE TABLE IF NOT EXISTS licenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    license_key VARCHAR(32) NOT NULL UNIQUE,
    customer_name VARCHAR(100) NOT NULL,
    duration_days INTEGER NOT NULL,
    hardware_id VARCHAR(64),
    activated_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT 1
);
CREATE INDEX IF NOT EXISTS idx_licenses_license_key ON licenses(license_key);

-- Table: workflows
-- Purpose: Defines automation sequences.
CREATE TABLE IF NOT EXISTS workflows (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT DEFAULT '',
    screen_width INTEGER DEFAULT 960,
    screen_height INTEGER DEFAULT 540,
    valid_from DATETIME,
    valid_until DATETIME,
    is_master BOOLEAN DEFAULT 0,
    mode_name VARCHAR(100),
    month_year VARCHAR(7),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_workflows_mode_name ON workflows(mode_name);
CREATE INDEX IF NOT EXISTS idx_workflows_month_year ON workflows(month_year);

-- Table: workflow_steps
-- Purpose: Individual actions within a workflow.
CREATE TABLE IF NOT EXISTS workflow_steps (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workflow_id INTEGER NOT NULL,
    order_index INTEGER NOT NULL,
    step_type VARCHAR(50) NOT NULL,
    x INTEGER,
    y INTEGER,
    end_x INTEGER,
    end_y INTEGER,
    swipe_duration_ms INTEGER DEFAULT 300,
    wait_duration_ms INTEGER,
    template_path VARCHAR(500),
    template_name VARCHAR(255),
    threshold FLOAT DEFAULT 0.8,
    match_all BOOLEAN DEFAULT 0,
    skip_if_not_found BOOLEAN DEFAULT 0,
    max_wait_seconds INTEGER DEFAULT 10,
    max_retries INTEGER,
    retry_interval FLOAT DEFAULT 1.0,
    on_match_action VARCHAR(50) DEFAULT 'click',
    condition_type VARCHAR(50),
    goto_step_on_true INTEGER,
    goto_step_on_false INTEGER,
    description VARCHAR(500) DEFAULT '',
    group_name VARCHAR(100),
    max_iterations INTEGER DEFAULT 20,
    not_found_threshold INTEGER DEFAULT 3,
    click_delay FLOAT DEFAULT 1.5,
    retry_delay FLOAT DEFAULT 2.0,
    expected_color JSON,
    tolerance INTEGER DEFAULT 30,
    check_interval FLOAT DEFAULT 1.0,
    loop_group_name VARCHAR(100),
    stop_template_path VARCHAR(500),
    stop_on_not_found BOOLEAN DEFAULT 1,
    loop_max_iterations INTEGER DEFAULT 100,
    ocr_region JSON,
    target_characters JSON,
    gacha_save_folder VARCHAR(500),
    FOREIGN KEY (workflow_id) REFERENCES workflows (id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_workflow_steps_group_name ON workflow_steps(group_name);

-- Table: workflow_templates
-- Purpose: Repository of image templates used for matching.
CREATE TABLE IF NOT EXISTS workflow_templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    description TEXT DEFAULT '',
    region_x INTEGER,
    region_y INTEGER,
    region_width INTEGER,
    region_height INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table: workflow_template_sets
-- Purpose: Groups of workflows for specific categories.
CREATE TABLE IF NOT EXISTS workflow_template_sets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(1000) DEFAULT '',
    category VARCHAR(100) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_workflow_template_sets_category ON workflow_template_sets(category);

-- Table: template_set_workflow_association
-- Purpose: Many-to-many relationship between template sets and workflows.
CREATE TABLE IF NOT EXISTS template_set_workflow_association (
    template_set_id INTEGER NOT NULL,
    workflow_id INTEGER NOT NULL,
    order_index INTEGER DEFAULT 0,
    PRIMARY KEY (template_set_id, workflow_id),
    FOREIGN KEY (template_set_id) REFERENCES workflow_template_sets (id) ON DELETE CASCADE,
    FOREIGN KEY (workflow_id) REFERENCES workflows (id) ON DELETE CASCADE
);

-- Table: mode_configurations
-- Purpose: Maps game modes and time periods to specific template sets.
CREATE TABLE IF NOT EXISTS mode_configurations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mode_name VARCHAR(100) NOT NULL,
    month_year VARCHAR(7) NOT NULL,
    template_set_id INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT 1,
    priority INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (template_set_id) REFERENCES workflow_template_sets (id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_mode_configurations_mode_name ON mode_configurations(mode_name);
CREATE INDEX IF NOT EXISTS idx_mode_configurations_month_year ON mode_configurations(month_year);
