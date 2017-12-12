use msdb
go

-- D = Full, I = Differential and L = Log.
-- There are other types of backups too but those are the primary ones.
SELECT backupset.database_name, 
    MAX(CASE WHEN backupset.type = 'D' THEN backupset.backup_finish_date ELSE NULL END) AS LastFullBackup,
    MAX(CASE WHEN backupset.type = 'I' THEN backupset.backup_finish_date ELSE NULL END) AS LastDifferential,
    MAX(CASE WHEN backupset.type = 'L' THEN backupset.backup_finish_date ELSE NULL END) AS LastLog
FROM backupset
GROUP BY backupset.database_name
ORDER BY backupset.database_name DESC
