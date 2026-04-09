-- ============================================================
-- 20_rename_tables.sql
-- Rename all tables to use t_ prefix (and t_master_ for master tables)
-- Run once on an existing database that still has the old names.
-- Safe to run again only IF tables have already been renamed (RENAME TABLE
-- will error on already-renamed tables – run the guard script instead).
-- ============================================================

USE lineranger_automation;

SET FOREIGN_KEY_CHECKS = 0;

-- Core tables → t_ prefix
RENAME TABLE
    users                          TO t_users,
    licenses                       TO t_licenses,
    workflows                      TO t_workflows,
    workflow_templates             TO t_workflow_templates,
    workflow_template_sets         TO t_workflow_template_sets,
    workflow_steps                 TO t_workflow_steps,
    template_set_workflow_association TO t_template_set_workflow_assoc,
    mode_configurations            TO t_mode_configurations;

SET FOREIGN_KEY_CHECKS = 1;
