SELECT DB_Name(Database_id) AS DBName, 
mirroring_state_desc, Mirroring_role_desc, mirroring_safety_level_desc, 
mirroring_partner_name, mirroring_partner_instance,
mirroring_failover_lsn, mirroring_connection_timeout	
 FROM sys.database_mirroring
WHERE Database_id > 4
