-- List all users and their emails in nested groups. Tested with Confluence 5.6.5 and PostgreSQL and MSSQL databases
SELECT DISTINCT u.user_name, e.email_address
FROM cwd_membership a 
JOIN cwd_user u ON a.child_user_id = u.id
JOIN cwd_user e ON a.child_user_id = e.id
JOIN cwd_directory d ON u.directory_id = d.id
WHERE d.active = 'T'
AND u.active = 'T'
AND a.parent_id IN 
(
SELECT m.child_group_id 
FROM cwd_membership m 
JOIN cwd_group g ON m.parent_id = g.id 
WHERE child_group_id 
IS NOT NULL
AND g.group_name IN 
(
SELECT PERMGROUPNAME
FROM SPACEPERMISSIONS 
WHERE PERMTYPE = 'USECONFLUENCE'))
AND u.lower_user_name NOT IN
(
  SELECT DISTINCT (u.lower_user_name)
  FROM cwd_user u
  JOIN cwd_directory d ON u.directory_id = d.id
  JOIN cwd_membership m ON u.id = m.child_user_id
  JOIN cwd_group g ON g.id = m.parent_id
  JOIN cwd_app_dir_mapping o ON d.id=o.directory_id
  JOIN SPACEPERMISSIONS sp ON g.group_name=sp.PERMGROUPNAME
  WHERE PERMTYPE='USECONFLUENCE'
  AND d.active = 'T'
  AND u.active = 'T'
);
