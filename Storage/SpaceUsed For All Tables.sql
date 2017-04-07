  IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[sp_spaceused_all]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE [dbo].[sp_spaceused_all]
  GO
  
  CREATE PROCEDURE sp_spaceused_all
  @SourceDB    VARCHAR(128)
  AS
  /*exec sp_spaceused_all 'mydb'*/
  SET NOCOUNT ON
  DECLARE @sql VARCHAR(500)    
  CREATE TABLE #tables(name VARCHAR(255))        
  SELECT @sql = 'insert #tables select TABLE_SCHEMA + ''.'' + TABLE_NAME from ' + @SourceDB + '.INFORMATION_SCHEMA.TABLES where TABLE_TYPE = ''BASE TABLE'''    
  EXEC (@sql) 
         
  CREATE TABLE #SpaceUsed (name VARCHAR(255), ROWS VARCHAR(11), reserved VARCHAR(18), DATA VARCHAR(18), index_size VARCHAR(18), unused VARCHAR(18))
      
  DECLARE @name VARCHAR(128)    
  SELECT @name = ''    
  WHILE EXISTS (SELECT * FROM #tables WHERE name > @name)    
  BEGIN        
  
  SELECT @name = MIN(name) FROM #tables WHERE name > @name        
  SELECT @sql = 'exec ' + @SourceDB + '..sp_executesql N''insert #SpaceUsed exec sp_spaceused ' + '''''' + @name + '''' + ''''''
  EXEC (@sql)
  PRINT @sql    
  END    
  SELECT [NAME], 
         [ROWS], 
         [RESERVED IN KB] = replace(reserved, ' KB', ''), 
         [DATA IN KB] = replace(data, ' KB', ''), 
         [INDEX IN KB] = replace(index_size, ' KB', ''), 
         [UNUSED IN KB] = replace(unused, ' KB', '')
  FROM #SpaceUsed    
  DROP TABLE #tables    
  DROP TABLE #SpaceUsed
  GO
  
  EXEC sp_spaceused_all 'JDE_PRODUCTION_REP'
  
  IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[sp_spaceused_all]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  DROP PROCEDURE [dbo].[sp_spaceused_all]
  GO

