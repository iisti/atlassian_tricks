# Retrieve Active users
## MSSQL
* Query active users from JIRA Server 6.3.13
~~~
SELECT DISTINCT u.lower_user_name,
                u.email_address,
                d.directory_name 
FROM   cwd_user u
       JOIN cwd_membership m 
         ON u.id = m.child_id 
            AND u.directory_id = m.directory_id 
       JOIN cwd_directory d 
         ON m.directory_id = d.id 
WHERE  d.active = 1 
       AND u.active = '1' 
ORDER  BY directory_name, 
          lower_user_name;
~~~
