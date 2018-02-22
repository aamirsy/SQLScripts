select * from sys.configurations
WHERE Name IN ('show advanced options','fill factor (%)',
'backup compression default','cost threshold for parallelism','max degree of parallelism',
'optimize for ad hoc workloads', 'Database Mail XPs', 'max server memory (MB)',
'min server memory (MB)','optimize for ad hoc workloads','remote admin connections' )
order by name
