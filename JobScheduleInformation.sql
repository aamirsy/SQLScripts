SELECT		JobId			= JOB.job_id,
			ScheduleId		= SSCH.schedule_uid,
			JobName			= JOB.name, 
			JobDescription	= JOB.description,
			JobEnabled		= CASE JOB.enabled WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' END,
			JobScheduled	= CASE WHEN SSCH.schedule_uid IS NULL THEN 'No' ELSE 'Yes' END,
			JobScheduleName	= SSCH.name,
			JobEnvironment	= CASE SUBSTRING(@@SERVERNAME,16,1) WHEN 'D' THEN 'DV' WHEN 'Q' THEN 'QA' WHEN 'P' THEN 'PD' END
INTO		dbo.#JobInfo
FROM		msdb.dbo.sysjobs				AS JOB
LEFT JOIN	msdb.sys.servers				AS SVR		ON JOB.originating_server_id = SVR.server_id
LEFT JOIN	msdb.dbo.syscategories			AS CAT		ON JOB.category_id = CAT.category_id
LEFT JOIN	msdb.dbo.sysjobsteps			AS STP		ON JOB.job_id = STP.job_id AND JOB.start_step_id = STP.step_id
LEFT JOIN	msdb.sys.database_principals	AS DBP		ON JOB.owner_sid = DBP.sid
LEFT JOIN	msdb.dbo.sysjobschedules		AS JSCH		ON JOB.job_id = JSCH.job_id
LEFT JOIN	msdb.dbo.sysschedules			AS SSCH		ON JSCH.schedule_id = SSCH.schedule_id


SELECT		ScheduleId			= schedule_uid,
			ScheduleName		= name,
			ScheduleEnabled		= CASE enabled WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' END,
			ScheduleType		= CASE	WHEN freq_type = 64				THEN 'Start automatically when SQL Server Agent starts' 
										WHEN freq_type = 128			THEN 'Start whenever the CPUs become idle' 
										WHEN freq_type IN (4,8,16,32)	THEN 'Recurring' 
										WHEN freq_type = 1		THEN 'One Time' END,
			 ScheduleOccurrence	= CASE freq_type	WHEN 1		THEN 'One Time' WHEN 4 THEN 'Daily' 
													WHEN 8		THEN 'Weekly' 
													WHEN 16		THEN 'Monthly' 
													WHEN 32		THEN 'Monthly - Relative to Frequency Interval' 
													WHEN 64		THEN 'Start automatically when SQL Server Agent starts' 
													WHEN 128	THEN 'Start whenever the CPUs become idle' END,
			ScheduleRecurrence	= CASE freq_type	WHEN 4		THEN 'Occurs every ' + CAST(freq_interval AS VARCHAR(3)) + ' day(s)' 
													WHEN 8		THEN 'Occurs every ' + CAST(freq_recurrence_factor AS VARCHAR(3)) + ' week(s) on ' + CASE WHEN freq_interval & 1 = 1 THEN 'Sunday' ELSE '' END + CASE WHEN freq_interval & 2 = 2 THEN ', Monday' ELSE '' END + CASE WHEN freq_interval & 4 = 4 THEN ', Tuesday' ELSE '' END + CASE WHEN freq_interval & 8 = 8 THEN ', Wednesday' ELSE '' END + CASE WHEN freq_interval & 16 = 16 THEN ', Thursday' ELSE '' END + CASE WHEN freq_interval & 32 = 32 THEN ', Friday' ELSE '' END + CASE WHEN freq_interval & 64 = 64 THEN ', Saturday' ELSE '' END 
													WHEN 16		THEN 'Occurs on Day ' + CAST(freq_interval AS VARCHAR(3))      + ' of every ' + CAST(freq_recurrence_factor AS VARCHAR(3)) + ' month(s)'
													WHEN 32		THEN 'Occurs on ' + CASE freq_relative_interval WHEN 1 THEN 'First' WHEN 2 THEN 'Second' WHEN 4 THEN 'Third' WHEN 8 THEN 'Fourth' 
													WHEN 16		THEN 'Last' END + ' ' + CASE freq_interval WHEN 1 THEN 'Sunday' WHEN 2 THEN 'Monday' WHEN 3 THEN 'Tuesday' WHEN 4 THEN 'Wednesday' WHEN 5 THEN 'Thursday' WHEN 6 THEN 'Friday' WHEN 7 THEN 'Saturday' WHEN 8 THEN 'Day' WHEN 9 THEN 'Weekday' WHEN 10 THEN 'Weekend day' END + ' of every ' + CAST(freq_recurrence_factor AS VARCHAR(3))  + ' month(s)' END,
			ScheduleFrequency	= CASE freq_subday_type WHEN 1 THEN 'Occurs once at ' + STUFF(STUFF(RIGHT('000000' + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
														WHEN 2 THEN 'Occurs every ' + CAST(freq_subday_interval AS VARCHAR(3)) + ' Second(s) between ' + STUFF(STUFF(RIGHT('000000' + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') + ' & ' + STUFF(STUFF(RIGHT('000000' + CAST(active_end_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
														WHEN 4 THEN 'Occurs every ' + CAST(freq_subday_interval AS VARCHAR(3)) + ' Minute(s) between ' + STUFF(STUFF(RIGHT('000000' + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') + ' & ' + STUFF(STUFF(RIGHT('000000' + CAST(active_end_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
														WHEN 8 THEN 'Occurs every ' + CAST(freq_subday_interval AS VARCHAR(3)) + ' Hour(s) between ' + STUFF(STUFF(RIGHT('000000' + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')+ ' & ' + STUFF(STUFF(RIGHT('000000' + CAST(active_end_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') END 
INTO		dbo.#ScheduleInfo
FROM		msdb.dbo.sysschedules

SELECT		JobId					= JOB.[job_id],JOB.[name] AS [JobName],
			LastRunDateTime			= CASE WHEN JHIS.[run_date] IS NULL OR JHIS.[run_time] IS NULL THEN NULL ELSE CAST(CAST(JHIS.[run_date] AS CHAR(8)) + ' ' + STUFF(STUFF(RIGHT('000000' + CAST(JHIS.[run_time] AS VARCHAR(6)),  6), 3, 0, ':'), 6, 0, ':') AS DATETIME) END,
			LastRunStatus			= CASE JHIS.[run_status]
										WHEN 0 THEN 'Failed'
										WHEN 1 THEN 'Succeeded'
										WHEN 2 THEN 'Retry'
										WHEN 3 THEN 'Canceled'
										WHEN 4 THEN 'Running'
									  END, 
			LastRunDuration			= STUFF(STUFF(RIGHT('000000' + CAST(JHIS.[run_duration] AS VARCHAR(6)),  6), 3, 0, ':'), 6, 0, ':'),
			LastRunStatusMessage	= JHIS.[message],
			NextRunDateTime			= CASE JSCH.[NextRunDate]
										WHEN 0 THEN NULL
										ELSE CAST(CAST(JSCH.[NextRunDate] AS CHAR(8)) + ' ' + STUFF(STUFF(RIGHT('000000' + CAST(JSCH.[NextRunTime] AS VARCHAR(6)),  6), 3, 0, ':'), 6, 0, ':') AS DATETIME) END
INTO		dbo.#JobRunInfo
FROM		[msdb].[dbo].[sysjobs] AS JOB
LEFT JOIN	(SELECT [job_id], MIN([next_run_date]) AS [NextRunDate], MIN([next_run_time]) AS [NextRunTime] FROM [msdb].[dbo].[sysjobschedules] GROUP BY [job_id] ) AS JSCH ON JOB.[job_id] = JSCH.[job_id]
LEFT JOIN	(SELECT [job_id], [run_date], [run_time], [run_status], [run_duration], [message], ROW_NUMBER() OVER (PARTITION BY [job_id] ORDER BY [run_date] DESC, [run_time] DESC) AS RowNumber FROM [msdb].[dbo].[sysjobhistory] WHERE [step_id] = 0 ) AS JHIS ON JOB.[job_id] = JHIS.[job_id] AND JHIS.[RowNumber] = 1
ORDER BY [JobName]


SELECT		A.JobEnvironment,
			A.JobName, 
			A.JobDescription,
			A.JobEnabled, 
			A.JobScheduled, 
			B.ScheduleName, 
			B.ScheduleRecurrence, 
			B.ScheduleFrequency, 
			B.ScheduleOccurrence, 
			B.ScheduleType,
			C.LastRunDateTime,
			C.LastRunDuration,
			C.LastRunStatus,
			C.NextRunDateTime,
			C.LastRunStatusMessage
FROM		dbo.#JobInfo		A 
INNER JOIN	dbo.#ScheduleInfo	B ON A.ScheduleID = B.ScheduleID
INNER JOIN  dbo.#JobRunInfo		C ON A.JobId = C.JobId
WHERE       A.JobName LIKE 'BACKUP:%'

DROP TABLE dbo.#JobInfo 
DROP TABLE dbo.#ScheduleInfo

