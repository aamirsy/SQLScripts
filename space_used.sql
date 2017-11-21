if object_id('tempdb.dbo.#results') is not null
     drop table dbo.#results

create table dbo.#results
(    dbname        varchar(500)  not null,
	 filesizeinmb  decimal(12,2) null,
     spaceusedinmb decimal(12,2) null,
     freespaceinmb decimal(12,2) null,
     dblogicalname varchar(500)  not null,
     filename      nvarchar(260) not null )

execute master..sp_MSforeachdb
'USE [?]
     insert into dbo.#Results
     select    db_name(),
			   filesizeinmb  = convert(decimal(12,2),round(a.size/128.000,2)),
               spaceusedinmb = convert(decimal(12,2),round(fileproperty(a.name,''SpaceUsed'')/128.000,2)),
               freespaceinmb = convert(decimal(12,2),round((a.size-fileproperty(a.name,''SpaceUsed''))/128.000,2)),
               databasename  = a.name,
               filename      = a.filename
     from      dbo.sysfiles a'

select    *
from      dbo.#results
order by  dbname
