--Blocking Info
EXEC DBA.appviewer.sp__Monitor_GetBlockingInfo @StartDate = NULL  


--Deadlock Info
EXEC DBA.appviewer.sp__Monitor_GetDeadLockInfo @StartDate = NULL  

--Check Missing Indexes
EXEC DBA.appviewer.sp__Monitor_CheckMissingIndexes @Db = NULL  

--Check Unused Indexes
EXEC DBA.appviewer.sp__Monitor_CheckUnusedIndexes @Db = NULL  

--Index Fragmentation
EXEC DBA.appviewer.sp__Monitor_CheckIndexFragmentation  
@StartDate = NULL, 
 @Db = 'REUTERS'  


 --Worst Performing Queries
 /* o @StartDate = NULL checks from last index rebuild or from the specific @StartDate 

o @EndDate = NULL checks from last index rebuild or from the specific @EndDate 

o @SortOrder = Will order the results based on the weight of either Reads, CPU , Executions, Duration 

o @Db  = NULL checks all databases or the specific database passed 

o @IsServerWide = 1: Orders the query ranking for all the queries at  the Server level  

o @IsServerWide = 0: Orders the query ranking for all the queries at the Db level  
*/

 EXEC DBA.appviewer.[sp__Monitor_GetWorstPerformingSQL]  
@StartDate = '4 April 2017 15:00'  ,
@EndDate = '5 April 2017 15:10' 
,@SortOrder = 'CPU' --Reads, Executions, Duration 
,@Db = NULL 
,@IsServerWide = 1


