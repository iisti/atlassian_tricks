# List Confluence 5.6.5 users by last login date
* Modified from source: https://confluence.atlassian.com/confkb/how-to-identify-inactive-users-in-confluence-214335880.html

	~~~
	-- Tested with Confluence 5.6.5 and MSSQL database
	SELECT cu.user_name,
		   cw.email_address,
	       cd.directory_name,
	       li.SUCCESSDATE
	FROM logininfo li
	JOIN user_mapping um ON um.user_key = li.USERNAME
	JOIN cwd_user cu ON um.username = cu.user_name
	JOIN cwd_user cw ON um.username = cw.user_name
	JOIN cwd_directory cd ON cu.directory_id = cd.id
	ORDER BY SUCCESSDATE;
	~~~
