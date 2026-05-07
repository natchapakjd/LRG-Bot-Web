UPDATE t_workflow_templates
SET file_path = CONCAT(
    'E:\\Window backups\\Project\\Project\\lrg-bot\\workflow_templates\\',
    SUBSTRING_INDEX(file_path, '\\', -1)
)
WHERE LOCATE('workflow_templates', file_path) > 0;

UPDATE t_workflow_steps
SET template_path = CONCAT(
    'E:\\Window backups\\Project\\Project\\lrg-bot\\workflow_templates\\',
    SUBSTRING_INDEX(template_path, '\\', -1)
)
WHERE LOCATE('workflow_templates', template_path) > 0;

UPDATE t_workflow_steps
SET stop_template_path = CONCAT(
    'E:\\Window backups\\Project\\Project\\lrg-bot\\workflow_templates\\',
    SUBSTRING_INDEX(stop_template_path, '\\', -1)
)
WHERE LOCATE('workflow_templates', stop_template_path) > 0;

UPDATE t_workflow_steps
SET gacha_save_folder = 'E:/Window backups/Project/Project/lrg-bot'
WHERE gacha_save_folder LIKE '%/id_for_sells/re-id';
