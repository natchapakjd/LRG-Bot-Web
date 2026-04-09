-- Backup for lineranger_automation generated at 20260409_190034
CREATE DATABASE IF NOT EXISTS lineranger_automation CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE lineranger_automation;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS t_licenses;
CREATE TABLE `t_licenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `license_key` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `customer_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `duration_days` int(11) NOT NULL,
  `hardware_id` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `license_key` (`license_key`),
  KEY `idx_licenses_license_key` (`license_key`),
  KEY `idx_licenses_hardware_id` (`hardware_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS t_master_mode;
CREATE TABLE `t_master_mode` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(100) NOT NULL,
  `display_name` varchar(150) NOT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `icon` varchar(10) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_t_master_mode_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS t_master_role;
CREATE TABLE `t_master_role` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_t_master_role_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS t_master_step_type;
CREATE TABLE `t_master_step_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL,
  `display_name` varchar(150) NOT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `category` varchar(50) NOT NULL,
  `icon` varchar(10) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_t_master_step_type_code` (`code`),
  KEY `ix_t_master_step_type_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS t_mode_configurations;
CREATE TABLE `t_mode_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mode_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `month_year` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_set_id` int(11) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `priority` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_mode_configs_template_set` (`template_set_id`),
  KEY `idx_mode_configurations_mode_name` (`mode_name`),
  KEY `idx_mode_configurations_month_year` (`month_year`),
  KEY `idx_mode_configurations_active_priority` (`is_active`,`priority`),
  CONSTRAINT `fk_mode_configs_template_set` FOREIGN KEY (`template_set_id`) REFERENCES `t_workflow_template_sets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS t_template_set_workflow_assoc;
CREATE TABLE `t_template_set_workflow_assoc` (
  `template_set_id` int(11) NOT NULL,
  `workflow_id` int(11) NOT NULL,
  `order_index` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`template_set_id`,`workflow_id`),
  KEY `idx_tswa_workflow_id` (`workflow_id`),
  CONSTRAINT `fk_tswa_template_set` FOREIGN KEY (`template_set_id`) REFERENCES `t_workflow_template_sets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tswa_workflow` FOREIGN KEY (`workflow_id`) REFERENCES `t_workflows` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS t_users;
CREATE TABLE `t_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hashed_password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_users_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS t_workflow_steps;
CREATE TABLE `t_workflow_steps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `workflow_id` int(11) NOT NULL,
  `order_index` int(11) NOT NULL,
  `step_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `x` int(11) DEFAULT NULL,
  `y` int(11) DEFAULT NULL,
  `end_x` int(11) DEFAULT NULL,
  `end_y` int(11) DEFAULT NULL,
  `swipe_duration_ms` int(11) NOT NULL DEFAULT '300',
  `wait_duration_ms` int(11) DEFAULT NULL,
  `template_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `template_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `threshold` float NOT NULL DEFAULT '0.8',
  `match_all` tinyint(1) NOT NULL DEFAULT '0',
  `skip_if_not_found` tinyint(1) NOT NULL DEFAULT '0',
  `max_wait_seconds` int(11) NOT NULL DEFAULT '10',
  `max_retries` int(11) DEFAULT NULL,
  `retry_interval` float NOT NULL DEFAULT '1',
  `on_match_action` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'click',
  `condition_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `goto_step_on_true` int(11) DEFAULT NULL,
  `goto_step_on_false` int(11) DEFAULT NULL,
  `description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `group_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `max_iterations` int(11) NOT NULL DEFAULT '20',
  `not_found_threshold` int(11) NOT NULL DEFAULT '3',
  `click_delay` float NOT NULL DEFAULT '1.5',
  `retry_delay` float NOT NULL DEFAULT '2',
  `expected_color` json DEFAULT NULL,
  `tolerance` int(11) NOT NULL DEFAULT '30',
  `check_interval` float NOT NULL DEFAULT '1',
  `loop_group_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stop_template_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stop_on_not_found` tinyint(1) NOT NULL DEFAULT '1',
  `loop_max_iterations` int(11) NOT NULL DEFAULT '100',
  `ocr_region` json DEFAULT NULL,
  `target_characters` json DEFAULT NULL,
  `gacha_save_folder` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_workflow_steps_workflow_id` (`workflow_id`),
  KEY `idx_workflow_steps_group_name` (`group_name`),
  CONSTRAINT `fk_workflow_steps_workflow` FOREIGN KEY (`workflow_id`) REFERENCES `t_workflows` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS t_workflow_template_sets;
CREATE TABLE `t_workflow_template_sets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_workflow_template_sets_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS t_workflow_templates;
CREATE TABLE `t_workflow_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `region_x` int(11) DEFAULT NULL,
  `region_y` int(11) DEFAULT NULL,
  `region_width` int(11) DEFAULT NULL,
  `region_height` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS t_workflows;
CREATE TABLE `t_workflows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `screen_width` int(11) NOT NULL DEFAULT '960',
  `screen_height` int(11) NOT NULL DEFAULT '540',
  `valid_from` datetime DEFAULT NULL,
  `valid_until` datetime DEFAULT NULL,
  `is_master` tinyint(1) NOT NULL DEFAULT '0',
  `mode_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `month_year` varchar(7) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_workflows_mode_name` (`mode_name`),
  KEY `idx_workflows_month_year` (`month_year`),
  KEY `idx_workflows_is_master` (`is_master`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO t_master_mode (id, code, display_name, description, icon, is_active, sort_order, created_at, updated_at) VALUES (1, 'daily-login', 'Daily Login', 'Automated daily login and reward collection', NULL, NULL, 0, NULL, NULL);
INSERT INTO t_master_mode (id, code, display_name, description, icon, is_active, sort_order, created_at, updated_at) VALUES (2, 're-id', 'Re-ID', 'Account re-identification workflow', NULL, NULL, 1, NULL, NULL);
INSERT INTO t_master_mode (id, code, display_name, description, icon, is_active, sort_order, created_at, updated_at) VALUES (3, 'stage-farm', 'Stage Farm', 'Automated stage grinding / resource farming', NULL, NULL, 2, NULL, NULL);
INSERT INTO t_master_mode (id, code, display_name, description, icon, is_active, sort_order, created_at, updated_at) VALUES (4, 'gacha', 'Gacha', 'Automated gacha / summon workflow', NULL, NULL, 3, NULL, NULL);
INSERT INTO t_master_mode (id, code, display_name, description, icon, is_active, sort_order, created_at, updated_at) VALUES (5, 'pvp', 'PvP', 'Player-versus-player automated battles', NULL, NULL, 4, NULL, NULL);
INSERT INTO t_master_mode (id, code, display_name, description, icon, is_active, sort_order, created_at, updated_at) VALUES (6, 'guild-raid', 'Guild Raid', 'Guild raid participation automation', NULL, NULL, 5, NULL, NULL);
INSERT INTO t_master_mode (id, code, display_name, description, icon, is_active, sort_order, created_at, updated_at) VALUES (7, 'event', 'Event', 'Time-limited event automation', NULL, NULL, 6, NULL, NULL);
INSERT INTO t_master_mode (id, code, display_name, description, icon, is_active, sort_order, created_at, updated_at) VALUES (8, 'custom', 'Custom', 'User-defined custom workflow mode', NULL, NULL, 7, NULL, NULL);

INSERT INTO t_master_role (id, code, display_name, description, is_active, sort_order, created_at, updated_at) VALUES (1, 'admin', 'Administrator', 'Full access to all features including license and user management', NULL, 0, NULL, NULL);
INSERT INTO t_master_role (id, code, display_name, description, is_active, sort_order, created_at, updated_at) VALUES (2, 'user', 'User', 'Standard access to bot features', NULL, 1, NULL, NULL);

INSERT INTO t_master_step_type (id, code, display_name, description, category, icon, is_active, sort_order, created_at, updated_at) VALUES (1, 'click', 'Click', 'Tap/click at a specific coordinate', 'action', NULL, NULL, 0, NULL, NULL);
INSERT INTO t_master_step_type (id, code, display_name, description, category, icon, is_active, sort_order, created_at, updated_at) VALUES (2, 'swipe', 'Swipe', 'Swipe from one coordinate to another', 'action', NULL, NULL, 1, NULL, NULL);
INSERT INTO t_master_step_type (id, code, display_name, description, category, icon, is_active, sort_order, created_at, updated_at) VALUES (3, 'wait', 'Wait', 'Pause execution for a set duration', 'action', NULL, NULL, 2, NULL, NULL);
INSERT INTO t_master_step_type (id, code, display_name, description, category, icon, is_active, sort_order, created_at, updated_at) VALUES (4, 'image_match', 'Image Match', 'Wait for a template image to appear on screen then act', 'detection', NULL, NULL, 10, NULL, NULL);
INSERT INTO t_master_step_type (id, code, display_name, description, category, icon, is_active, sort_order, created_at, updated_at) VALUES (5, 'find_all_click', 'Find All & Click', 'Find all occurrences of a template and click each one', 'detection', NULL, NULL, 11, NULL, NULL);
INSERT INTO t_master_step_type (id, code, display_name, description, category, icon, is_active, sort_order, created_at, updated_at) VALUES (6, 'wait_for_color', 'Wait for Color', 'Wait until a specific pixel color is present', 'detection', NULL, NULL, 12, NULL, NULL);
INSERT INTO t_master_step_type (id, code, display_name, description, category, icon, is_active, sort_order, created_at, updated_at) VALUES (7, 'gacha_check', 'Gacha Check', 'OCR-based gacha result detection and decision', 'detection', NULL, NULL, 13, NULL, NULL);
INSERT INTO t_master_step_type (id, code, display_name, description, category, icon, is_active, sort_order, created_at, updated_at) VALUES (8, 'conditional', 'Conditional', 'Branch execution based on a condition result', 'control', NULL, NULL, 20, NULL, NULL);
INSERT INTO t_master_step_type (id, code, display_name, description, category, icon, is_active, sort_order, created_at, updated_at) VALUES (9, 'loop_click', 'Loop Click', 'Repeatedly click template matches up to a limit', 'loop', NULL, NULL, 30, NULL, NULL);
INSERT INTO t_master_step_type (id, code, display_name, description, category, icon, is_active, sort_order, created_at, updated_at) VALUES (10, 'repeat_group', 'Repeat Group', 'Repeat a named step group until a stop condition is met', 'loop', NULL, NULL, 31, NULL, NULL);

INSERT INTO t_users (id, username, email, hashed_password, role, is_active, created_at) VALUES (1, 'natchapakj', NULL, '$2b$12$yK9VxwCMKXk73G.7ldXbV.UY49KdMZOPOkTxkBax9r1eQ910Xgd/O', 'admin', 1, '2025-12-14 08:31:59');
INSERT INTO t_users (id, username, email, hashed_password, role, is_active, created_at) VALUES (2, 'user', 'test@gmail.com', '$2b$12$vtWeewqxHGqgkMdwD7H.NuF0WaSHA2z713NkFYP5kRcBUfZGP7YbW', 'user', 1, '2025-12-17 12:31:21');

INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (1, 1, 0, 'start_game', NULL, NULL, NULL, NULL, 300, NULL, NULL, NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Start game', NULL, 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (2, 1, 1, 'wait', NULL, NULL, NULL, NULL, 300, 30000, NULL, NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Wait 1000ms', NULL, 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (3, 1, 2, 'loop_click', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\close_popup_20251215_200327.png', NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Loop click until not found', NULL, 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (4, 1, 3, 'wait', NULL, NULL, NULL, NULL, 300, 60, NULL, NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Wait 1000ms', NULL, 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (5, 1, 4, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\gift_20251215_205428.png', NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Image match', NULL, 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (6, 1, 5, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Accecpt_all_gift_20251221_015736.png', NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Image match', NULL, 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (7, 1, 6, 'loop_click', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\close_popup_20251215_200327.png', NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Image match', NULL, 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (8, 1, 7, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Gacha_ok_btn_20251221_014514.png', NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Image match', NULL, 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (9, 1, 8, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Gacha_20251221_014426.png', NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Image match', NULL, 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (10, 1, 9, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Gacha_ok_btn_20251221_014514.png', NULL, 0.8, 0, 1, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Image match', NULL, 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (11, 1, 10, 'wait', NULL, NULL, NULL, NULL, 300, 30000, NULL, NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Wait 1000ms', NULL, 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (12, 2, 0, 'start_game', NULL, NULL, NULL, NULL, 300, NULL, NULL, NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Start game', NULL, 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (13, 2, 1, 'wait', 91, 399, NULL, NULL, 300, 30000, NULL, NULL, 0.8, 0, 0, 60, NULL, 1.0, 'click', NULL, NULL, NULL, 'Wait 30000ms', 'daily-login', 20, 3, 1.5, 2.0, '[41, 89, 156]', 30, 3.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (14, 2, 2, 'loop_click', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\close_popup_20251215_200327.png', NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Image match', 'daily-login', 40, 5, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (15, 2, 3, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\gift_20251215_205428.png', NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Image match', 'daily-login', 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (16, 2, 4, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Accecpt_all_gift_20251221_015736.png', NULL, 0.8, 0, 0, 30, 2, 1.0, 'click', NULL, NULL, NULL, 'Image match', 'daily-login', 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (17, 2, 5, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Gift_ok_20251221_143031.png', NULL, 0.8, 0, 0, 30, 2, 1.0, 'click', NULL, NULL, NULL, 'Image match', 'daily-login', 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (18, 2, 6, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Gift_ok_20251221_143031.png', NULL, 0.8, 0, 0, 30, 2, 1.0, 'click', NULL, NULL, NULL, 'Image match', 'daily-login', 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (19, 2, 7, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\close_popup_20251215_200327.png', NULL, 0.8, 0, 0, 30, 2, 1.0, 'click', NULL, NULL, NULL, 'Image match', 'daily-login', 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (20, 2, 8, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Gacha_20251221_014426.png', NULL, 0.8, 0, 0, 30, 2, 1.0, 'click', NULL, NULL, NULL, 'Image match', 'gacha', 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (21, 2, 9, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Gift_ok_20251221_143031.png', NULL, 0.8, 0, 1, 30, 2, 3.0, 'click', NULL, NULL, NULL, 'Image match', 'gacha', 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (22, 2, 10, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\open_gacha2_20251221_170029.png', NULL, 0.8, 0, 0, 30, 4, 1.0, 'click', NULL, NULL, NULL, 'Image match', 'gacha', 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (23, 2, 11, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Gift_ok_20251221_143031.png', NULL, 0.8, 0, 0, 30, 2, 1.0, 'click', NULL, NULL, NULL, 'Image match', 'gacha', 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (24, 2, 12, 'wait_for_color', 630, 431, NULL, NULL, 300, 1500, NULL, NULL, 0.8, 0, 0, 60, NULL, 1.0, 'click', NULL, NULL, NULL, 'Image match', 'gacha', 20, 3, 1.5, 2.0, '[206, 186, 8]', 30, 10.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (25, 2, 13, 'gacha_check', NULL, NULL, NULL, NULL, 300, NULL, NULL, NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Image match', 'gacha', 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, '{"x": 320, "y": 140, "width": 320, "height": 60}', '["Fairy Cony", "Mail Carrier PEW"]', 'C:/Users/welcome/Desktop/Linerangers-20250912T142019Z-1-001/Linerangers/id_for_sells/re-id');
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (26, 2, 14, 'image_match', NULL, NULL, NULL, NULL, 300, NULL, 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Gift_ok_20251221_143031.png', NULL, 0.8, 0, 0, 30, 2, 1.0, 'click', NULL, NULL, NULL, 'Image match', 'gacha', 20, 3, 1.5, 2.0, NULL, 30, 1.0, NULL, NULL, 1, 100, NULL, NULL, NULL);
INSERT INTO t_workflow_steps (id, workflow_id, order_index, step_type, x, y, end_x, end_y, swipe_duration_ms, wait_duration_ms, template_path, template_name, threshold, match_all, skip_if_not_found, max_wait_seconds, max_retries, retry_interval, on_match_action, condition_type, goto_step_on_true, goto_step_on_false, description, group_name, max_iterations, not_found_threshold, click_delay, retry_delay, expected_color, tolerance, check_interval, loop_group_name, stop_template_path, stop_on_not_found, loop_max_iterations, ocr_region, target_characters, gacha_save_folder) VALUES (27, 2, 15, 'repeat_group', NULL, NULL, NULL, NULL, 300, NULL, NULL, NULL, 0.8, 0, 0, 10, NULL, 1.0, 'click', NULL, NULL, NULL, 'Image match', 'gacha', 20, 3, 1.5, 2.0, NULL, 30, 1.0, 'gacha', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\gacha_ruby_20251221_173006.png', 1, 100, NULL, NULL, NULL);

INSERT INTO t_workflow_templates (id, name, file_path, description, region_x, region_y, region_width, region_height, created_at) VALUES (1, 'close_pop_up', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\close_pop_up_20251215_200157.png', '', 797, 53, 30, 28, '2025-12-15 13:01:57');
INSERT INTO t_workflow_templates (id, name, file_path, description, region_x, region_y, region_width, region_height, created_at) VALUES (2, 'close_popup', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\close_popup_20251215_200327.png', '', 788, 41, 48, 47, '2025-12-15 13:03:27');
INSERT INTO t_workflow_templates (id, name, file_path, description, region_x, region_y, region_width, region_height, created_at) VALUES (3, 's', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\s_20251215_200548.png', '', 790, 44, 44, 39, '2025-12-15 13:05:49');
INSERT INTO t_workflow_templates (id, name, file_path, description, region_x, region_y, region_width, region_height, created_at) VALUES (4, 'รรร', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\รรร_20251215_202218.png', '', 788, 41, 48, 45, '2025-12-15 13:22:19');
INSERT INTO t_workflow_templates (id, name, file_path, description, region_x, region_y, region_width, region_height, created_at) VALUES (5, 'gift', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\gift_20251215_205428.png', '', 726, 451, 75, 64, '2025-12-15 13:54:29');
INSERT INTO t_workflow_templates (id, name, file_path, description, region_x, region_y, region_width, region_height, created_at) VALUES (6, 'Gacha', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Gacha_20251221_014426.png', '', 616, 139, 99, 28, '2025-12-20 18:44:27');
INSERT INTO t_workflow_templates (id, name, file_path, description, region_x, region_y, region_width, region_height, created_at) VALUES (7, 'Gacha_ok_btn', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Gacha_ok_btn_20251221_014514.png', '', 417, 388, 128, 37, '2025-12-20 18:45:14');
INSERT INTO t_workflow_templates (id, name, file_path, description, region_x, region_y, region_width, region_height, created_at) VALUES (8, 'open_gacha_btn', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\open_gacha_btn_20251221_014600.png', '', 180, 432, 176, 41, '2025-12-20 18:46:00');
INSERT INTO t_workflow_templates (id, name, file_path, description, region_x, region_y, region_width, region_height, created_at) VALUES (9, 'one_more_time_open', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\one_more_time_open_20251221_014746.png', '', 495, 418, 143, 40, '2025-12-20 18:47:46');
INSERT INTO t_workflow_templates (id, name, file_path, description, region_x, region_y, region_width, region_height, created_at) VALUES (10, 'Accecpt_all_gift', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Accecpt_all_gift_20251221_015736.png', '', 618, 451, 163, 34, '2025-12-20 18:57:37');
INSERT INTO t_workflow_templates (id, name, file_path, description, region_x, region_y, region_width, region_height, created_at) VALUES (11, 'Gift_ok', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\Gift_ok_20251221_143031.png', '', 494, 342, 120, 28, '2025-12-21 07:30:32');
INSERT INTO t_workflow_templates (id, name, file_path, description, region_x, region_y, region_width, region_height, created_at) VALUES (12, 'open_gacha2', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\open_gacha2_20251221_170029.png', '', 187, 431, 170, 43, '2025-12-21 10:00:29');
INSERT INTO t_workflow_templates (id, name, file_path, description, region_x, region_y, region_width, region_height, created_at) VALUES (13, 'gacha_ruby', 'C:\\Users\\welcome\\Desktop\\Project\\lrg-bot\\app\\services\\..\\..\\workflow_templates\\gacha_ruby_20251221_173006.png', '', 183, 433, 174, 44, '2025-12-21 10:30:07');

INSERT INTO t_workflows (id, name, description, screen_width, screen_height, valid_from, valid_until, is_master, mode_name, month_year, created_at, updated_at) VALUES (1, 'daily-login', '', 960, 540, NULL, NULL, 0, 'daily-login', '2025-12', '2025-12-14 08:32:15', '2025-12-21 12:48:17');
INSERT INTO t_workflows (id, name, description, screen_width, screen_height, valid_from, valid_until, is_master, mode_name, month_year, created_at, updated_at) VALUES (2, 'new-work-flow', '', 960, 540, NULL, NULL, 1, 'daily-login', '2025-12', '2025-12-21 06:41:32', '2025-12-21 12:48:17');

SET FOREIGN_KEY_CHECKS = 1;