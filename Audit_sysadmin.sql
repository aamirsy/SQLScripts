USE master
GO

SELECT  @@SERVERNAME as ServerName,
		p.name AS [loginname] ,
        p.type_desc, 
		CASE s.sysadmin
		WHEN '1' THEN 'sysadmin'
		ELSE  'other'
		END AS isSysAdmin,
		CASE is_fixed_role
		WHEN '0' THEN 'SERVER_ROLE'
		ELSE 'other' 
		END AS RoleType
       
FROM    sys.server_principals p
        JOIN sys.syslogins s ON p.sid = s.sid
WHERE   p.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
        -- Logins that are not process logins
        AND p.name NOT LIKE '##%'
        -- Logins that are sysadmins
        AND s.sysadmin = 1
GO
