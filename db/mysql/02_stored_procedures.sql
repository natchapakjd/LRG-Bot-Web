-- Stored procedures for Line Ranger Automation
USE lineranger_automation;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_create_license $$
CREATE PROCEDURE sp_create_license(
    IN p_customer_name VARCHAR(100),
    IN p_duration_days INT,
    OUT p_license_key VARCHAR(32)
)
BEGIN
    IF p_duration_days < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'duration_days must be >= 1';
    END IF;

    SET p_license_key = CONCAT(
        'LRG-',
        UPPER(SUBSTRING(REPLACE(UUID(), '-', ''), 1, 4)), '-',
        UPPER(SUBSTRING(REPLACE(UUID(), '-', ''), 5, 4)), '-',
        UPPER(SUBSTRING(REPLACE(UUID(), '-', ''), 9, 4))
    );

    INSERT INTO t_licenses (license_key, customer_name, duration_days, is_active)
    VALUES (p_license_key, p_customer_name, p_duration_days, 1);
END $$

DROP PROCEDURE IF EXISTS sp_activate_license $$
CREATE PROCEDURE sp_activate_license(
    IN p_license_key VARCHAR(32),
    IN p_hardware_id VARCHAR(64),
    OUT p_success TINYINT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_id INT;
    DECLARE v_is_active TINYINT;
    DECLARE v_hardware_id VARCHAR(64);
    DECLARE v_activated_at DATETIME;
    DECLARE v_duration_days INT;

    SET p_success = 0;
    SET p_message = 'Unknown error';

    SELECT id, is_active, hardware_id, activated_at, duration_days
      INTO v_id, v_is_active, v_hardware_id, v_activated_at, v_duration_days
      FROM t_licenses
     WHERE license_key = p_license_key
     LIMIT 1;

    IF v_id IS NULL THEN
        SET p_message = 'Invalid license key';
    ELSEIF v_is_active = 0 THEN
        SET p_message = 'License has been revoked';
    ELSEIF v_hardware_id IS NOT NULL AND v_hardware_id <> p_hardware_id THEN
        SET p_message = 'License already activated on another device';
    ELSEIF v_activated_at IS NOT NULL AND DATE_ADD(v_activated_at, INTERVAL v_duration_days DAY) < UTC_TIMESTAMP() THEN
        SET p_message = 'License expired';
    ELSE
        IF v_hardware_id IS NULL THEN
            UPDATE t_licenses
               SET hardware_id = p_hardware_id,
                   activated_at = UTC_TIMESTAMP()
             WHERE id = v_id;
            SET p_message = 'License activated';
        ELSE
            SET p_message = 'License already active on this device';
        END IF;
        SET p_success = 1;
    END IF;
END $$

DROP PROCEDURE IF EXISTS sp_validate_license $$
CREATE PROCEDURE sp_validate_license(
    IN p_license_key VARCHAR(32),
    IN p_hardware_id VARCHAR(64),
    OUT p_is_valid TINYINT,
    OUT p_message VARCHAR(255),
    OUT p_days_remaining INT
)
BEGIN
    DECLARE v_id INT;
    DECLARE v_is_active TINYINT;
    DECLARE v_db_hardware_id VARCHAR(64);
    DECLARE v_activated_at DATETIME;
    DECLARE v_duration_days INT;
    DECLARE v_expiry DATETIME;

    SET p_is_valid = 0;
    SET p_days_remaining = 0;
    SET p_message = 'Unknown error';

    SELECT id, is_active, hardware_id, activated_at, duration_days
      INTO v_id, v_is_active, v_db_hardware_id, v_activated_at, v_duration_days
      FROM t_licenses
     WHERE license_key = p_license_key
     LIMIT 1;

    IF v_id IS NULL THEN
        SET p_message = 'Invalid license key';
    ELSEIF v_is_active = 0 THEN
        SET p_message = 'License has been revoked';
    ELSEIF v_db_hardware_id IS NULL THEN
        SET p_message = 'License not activated';
    ELSEIF v_db_hardware_id <> p_hardware_id THEN
        SET p_message = 'License bound to different device';
    ELSE
        SET v_expiry = DATE_ADD(v_activated_at, INTERVAL v_duration_days DAY);
        IF v_expiry < UTC_TIMESTAMP() THEN
            SET p_message = 'License expired';
        ELSE
            SET p_days_remaining = GREATEST(TIMESTAMPDIFF(DAY, UTC_TIMESTAMP(), v_expiry), 0);
            SET p_is_valid = 1;
            SET p_message = CONCAT('Valid (', p_days_remaining, ' days remaining)');
        END IF;
    END IF;
END $$

DROP PROCEDURE IF EXISTS sp_revoke_license $$
CREATE PROCEDURE sp_revoke_license(
    IN p_license_key VARCHAR(32),
    OUT p_success TINYINT
)
BEGIN
    UPDATE t_licenses
       SET is_active = 0
     WHERE license_key = p_license_key;

    IF ROW_COUNT() > 0 THEN
        SET p_success = 1;
    ELSE
        SET p_success = 0;
    END IF;
END $$

DROP PROCEDURE IF EXISTS sp_reset_license_hardware $$
CREATE PROCEDURE sp_reset_license_hardware(
    IN p_license_key VARCHAR(32),
    OUT p_success TINYINT
)
BEGIN
    UPDATE t_licenses
       SET hardware_id = NULL,
           activated_at = NULL
     WHERE license_key = p_license_key;

    IF ROW_COUNT() > 0 THEN
        SET p_success = 1;
    ELSE
        SET p_success = 0;
    END IF;
END $$

DROP PROCEDURE IF EXISTS sp_set_master_workflow $$
CREATE PROCEDURE sp_set_master_workflow(
    IN p_workflow_id INT,
    OUT p_success TINYINT
)
BEGIN
    UPDATE t_workflows SET is_master = 0;
    UPDATE t_workflows SET is_master = 1 WHERE id = p_workflow_id;

    IF ROW_COUNT() > 0 THEN
        SET p_success = 1;
    ELSE
        SET p_success = 0;
    END IF;
END $$

DROP PROCEDURE IF EXISTS sp_upsert_mode_configuration $$
CREATE PROCEDURE sp_upsert_mode_configuration(
    IN p_mode_name VARCHAR(100),
    IN p_month_year VARCHAR(7),
    IN p_template_set_id INT,
    IN p_is_active TINYINT,
    IN p_priority INT
)
BEGIN
    DECLARE v_id INT;

    SELECT id
      INTO v_id
      FROM t_mode_configurations
     WHERE mode_name = p_mode_name
       AND month_year = p_month_year
     LIMIT 1;

    IF v_id IS NULL THEN
        INSERT INTO t_mode_configurations (mode_name, month_year, template_set_id, is_active, priority)
        VALUES (p_mode_name, p_month_year, p_template_set_id, p_is_active, p_priority);
    ELSE
        UPDATE t_mode_configurations
           SET template_set_id = p_template_set_id,
               is_active = p_is_active,
               priority = p_priority,
               updated_at = CURRENT_TIMESTAMP
         WHERE id = v_id;
    END IF;
END $$

DELIMITER ;
