
USE MyDB2017
GO
DROP PROCEDURE IF EXISTS [dbo].[MoveIndexToFileGroup]  
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MoveIndexToFileGroup]') AND type in (N'P', N'PC'))
	BEGIN
		DROP PROCEDURE [dbo].[MoveIndexToFileGroup]
	END
GO

CREATE PROC [dbo].[MoveIndexToFileGroup] (        
	@DBName sysname,   
	@SchemaName sysname = 'dbo',       
	@ObjectNameList Varchar(Max),        
	@IndexName sysname = null,  
	@FileGroupName varchar(100)  
) WITH RECOMPILE

AS        
  
BEGIN  
     
	SET NOCOUNT ON;
  
	DECLARE @IndexSQL NVarchar(Max)  
	DECLARE @IndexKeySQL NVarchar(Max)  
	DECLARE @IncludeColSQL NVarchar(Max)  
	DECLARE @FinalSQL NVarchar(Max)  
  
	DECLARE @CurLoopCount Int  
	DECLARE @MaxLoopCount Int  
	DECLARE @StartPos Int  
	DECLARE @EndPos Int  
  
	DECLARE @ObjectName sysname  
	DECLARE @IndName sysname  
	DECLARE @IsUnique Varchar(10)  
	DECLARE @Type Varchar(25)  
	DECLARE @IsPadded Varchar(5)  
	DECLARE @IgnoreDupKey Varchar(5) 
	DECLARE @AllowRowLocks Varchar(5)  
	DECLARE @AllowPageLocks Varchar(5) 
	DECLARE @FillFactor Int  
	DECLARE @ExistingFGName Varchar(Max) 
	DECLARE @FilterDef NVarchar(Max)
  
	DECLARE @ErrorMessage NVARCHAR(4000)  
	DECLARE @SQL nvarchar(4000)  
	DECLARE @RetVal Bit  
  
	DECLARE @ObjectList Table(Id Int Identity(1,1),ObjectName sysname)  
  
	DECLARE @WholeIndexData TABLE (
		ObjectName SYSNAME
		,IndexName SYSNAME
		,Is_Unique BIT
		,Type_Desc VARCHAR(25)
		,Is_Padded BIT
		,[Ignore_Dup_Key] BIT
		,[Allow_Row_Locks] BIT
		,[Allow_Page_Locks] BIT
		,Fill_Factor INT
		,Is_Descending_Key BIT
		,ColumnName SYSNAME
		,Is_Included_Column BIT
		,FileGroupName VARCHAR(MAX)
		,Has_Filter BIT
		,Filter_Definition NVARCHAR(MAX)
		,key_ordinal TINYINT
	)

	DECLARE @DistinctIndexData TABLE (
		Id INT IDENTITY(1, 1)
		,ObjectName SYSNAME
		,IndexName SYSNAME
		,Is_Unique BIT
		,Type_Desc VARCHAR(25)
		,Is_Padded BIT
		,[Ignore_Dup_Key] BIT
		,[Allow_Row_Locks] BIT
		,[Allow_Page_Locks] BIT
		,Fill_Factor INT
		,FileGroupName VARCHAR(Max)
		,Has_Filter BIT
		,Filter_Definition NVARCHAR(Max)
	)
  
-------------Validate arguments----------------------   
  
	IF(@DBName IS NULL)  
		BEGIN  
			SELECT @ErrorMessage = 'Database Name must be supplied.'   
			GOTO ABEND  
		END  
  
	IF(@ObjectNameList IS NULL)  
		BEGIN  
			SELECT @ErrorMessage = 'Table or View Name(s) must be supplied.'   
			GOTO ABEND  
		END  
  
	IF(@FileGroupName IS NULL)  
		BEGIN  
			SELECT @ErrorMessage = 'FileGroup Name must be supplied.'   
			GOTO ABEND  
		END  
  
	--Check for the existence of the Database  
	IF NOT EXISTS(SELECT Name FROM sys.databases where Name = @DBName) 
		BEGIN 
			SET @ErrorMessage = 'The specified Database does not exist' 
			GOTO ABEND
		END
  
	--Check for the existence of the Schema  
	IF (upper(@SchemaName) <> 'DBO')
		BEGIN
			SET @SQL = 'SELECT @RetVal = COUNT(*) FROM ' + QUOTENAME(@DBName) + '.sys.schemas WHERE name = ''' + @SchemaName + ''''

			BEGIN TRY
				EXEC sp_executesql @SQL, N'@RetVal Bit OUTPUT', @RetVal OUTPUT
			END TRY
			BEGIN CATCH
				SELECT @ErrorMessage = ERROR_MESSAGE()
				GOTO ABEND
			END CATCH

			IF (@RetVal = 0)
				BEGIN
					SELECT @ErrorMessage = 'No Schema with the name ' + @SchemaName + ' exists in the Database ' + @DBName
					GOTO ABEND
				END
		END 
  
	--CHECK FOR THE EXISTENCE OF THE FILEGROUP  
	SET @SQL = 'SELECT @RetVal=COUNT(*) FROM ' + QUOTENAME(@DBName) + '.sys.filegroups WHERE name = ''' + @FileGroupName + ''''  
	BEGIN TRY  
		EXEC sp_executesql @SQL,N'@RetVal Bit OUTPUT',@RetVal OUTPUT  
	END TRY  
	BEGIN CATCH  
		SELECT @ErrorMessage = ERROR_MESSAGE()   
		GOTO ABEND  
	END CATCH  
  
	IF(@RetVal = 0)  
		BEGIN  
			SELECT @ErrorMessage = 'No FileGroup with the name ' + @FileGroupName + ' exists in the Database ' + @DBName   
			GOTO ABEND  
		END  
  
----------Get the objects from the concatenated list----------------------------------------------------  
  
SET @StartPos = 0  
SET @EndPos = 0  
  
WHILE(@EndPos >= 0)  
BEGIN  
  
 SELECT @EndPos = CHARINDEX(',',@ObjectNameList,@StartPos)  
 IF(@EndPos = 0) --Means, separator is not found  
 BEGIN  
  INSERT INTO @ObjectList  
  SELECT SUBSTRING(@ObjectNameList,@StartPos,(LEN(@ObjectNameList) - @StartPos)+1)   
     
  BREAK  
 END  
   
 INSERT INTO @ObjectList  
 SELECT SUBSTRING(@ObjectNameList,@StartPos,(@EndPos - @StartPos))  
    
 SET @StartPos = @EndPos + 1  
   
END  
  
-------------Check for the validity of all the Objects----------------------  
  
SET @StartPos = 1  
SELECT @EndPos = COUNT(*) FROM @ObjectList  
  
WHILE(@StartPos <= @EndPos)  
BEGIN  
  
 SELECT @ObjectName = ObjectName FROM @ObjectList WHERE Id = @StartPos  
  
 --CHECK FOR EXISTENCE OF THE OBJECT  
 SET @SQL = 'SELECT @RetVal=COUNT(*) FROM ' + QUOTENAME(@DBName) + '.sys.Objects WHERE type IN (''U'',''V'') AND name = ''' + @ObjectName + ''''  
 BEGIN TRY  
  EXEC sp_executesql @SQL,N'@RetVal Int OUTPUT',@RetVal OUTPUT  
 END TRY  
 BEGIN CATCH  
  SELECT @ErrorMessage = ERROR_MESSAGE()   
  GOTO ABEND  
 END CATCH  
  
 IF(@RetVal = 0)  
 BEGIN  
  SELECT @ErrorMessage = 'No Table or View with the name ' + @ObjectName + ' exists in the Database ' + @DBName   
  GOTO ABEND  
 END   
  
 --Check for existence of Index  
 IF(@IndexName IS NOT NULL)  
 BEGIN  
  SET @SQL = 'SELECT @RetVal=COUNT(*) FROM ' + QUOTENAME(@DBName) + '.sys.Indexes si INNER JOIN ' + QUOTENAME(@DBName) + '.sys.Objects so '  
  SET @SQL = @SQL + ' ON si.Object_Id = so.Object_Id WHERE so.Schema_id = ' + CAST(Schema_Id(@Schemaname) as varchar(25))   
  SET @SQL = @SQL + ' AND so.name = ''' + @ObjectName + ''' AND si.name = ''' + @IndexName + ''''   
  
  BEGIN TRY  
   EXEC sp_executesql @SQL,N'@RetVal Int OUTPUT',@RetVal OUTPUT  
  END TRY  
  BEGIN CATCH  
   SELECT @ErrorMessage = ERROR_MESSAGE()   
   GOTO ABEND  
  END CATCH  
  
  IF(@RetVal = 0)  
  BEGIN  
   SELECT @ErrorMessage = 'No Index with the name ' + @IndexName + ' exists on the Object ' + @ObjectName   
   GOTO ABEND  
  END  
 END  
   
 SET @StartPos = @StartPos + 1  
END  
  
-------------Loop till all the Objects are processed----------------------  
  
SET @StartPos = 1  
SELECT @EndPos = COUNT(*) FROM @ObjectList  
  
WHILE(@StartPos <= @EndPos)  
BEGIN  
  
 SELECT @ObjectName = ObjectName FROM @ObjectList WHERE Id = @StartPos  
 
 -------------Build the SQL to get the index data based on the inputs provided----------------------   
  


 SET @IndexSQL =   
 'SELECT so.Name as ObjectName, si.Name as IndexName,si.Is_Unique,si.Type_Desc'  
 + ',si.Is_Padded,si.Ignore_Dup_Key,si.Allow_Row_Locks,si.Allow_Page_Locks,si.Fill_Factor,sic.Is_Descending_Key'  
 + ',sc.Name as ColumnName,sic.Is_Included_Column,sf.Name as FileGroupName,'+ CASE WHEN @@VERSION LIKE '%Server 2005%' THEN '0 as Has_Filter, N'''' as Filter_Definition' ELSE 'si.Has_Filter,si.Filter_Definition' END +',sic.Key_Ordinal FROM '
 + QUOTENAME(@DBName) + '.sys.Objects so INNER JOIN ' + QUOTENAME(@DBName) + '.sys.Indexes si ON so.Object_Id = si.Object_id INNER JOIN '  
 + QUOTENAME(@DBName) + '.sys.FileGroups sf ON sf.Data_Space_Id = si.Data_Space_Id INNER JOIN '   
 + QUOTENAME(@DBName) + '.sys.Index_columns sic ON si.Object_Id = sic.Object_Id AND si.Index_id = sic.Index_id INNER JOIN '  
 + QUOTENAME(@DBName) + '.sys.Columns sc ON sic.Column_Id = sc.Column_Id and sc.Object_Id = sic.Object_Id '  
 + ' WHERE so.Name = ''' + @ObjectName  + ''''  
 + ' AND so.Schema_id = ' + CAST(Schema_Id(@Schemaname) as varchar(25)) + ' AND si.Type_Desc = ''NONCLUSTERED'' '  
  
 IF(@IndexName IS NOT NULL)  
 BEGIN  
  SET @IndexSQL = @IndexSQL + ' AND si.Name = ''' + @IndexName + ''''  
 END  
  
 SET @IndexSQL = @IndexSQL + ' ORDER BY ObjectName, IndexName, sic.Key_Ordinal'  
  
 --PRINT @IndexSQL  
  
 -------------INSERT THE INDEX DATA INTO A VARIABLE----------------------   
  
	BEGIN TRY  
		INSERT INTO @WholeIndexData
		EXEC sp_executesql @IndexSQL
	END TRY  
	BEGIN CATCH  
		SELECT @ErrorMessage = ERROR_MESSAGE()   
		GOTO ABEND  
	END CATCH  
  
 --Check if any indexes are there on the object. Otherwise exit  
 IF (SELECT COUNT(*) FROM @WholeIndexData) = 0  
 BEGIN  
  SELECT 'Object does not have any nonclustered indexes to move'   
  GOTO FINAL   
 END  
    
 -------------Get the distinct index rows in to a variable----------------------   
  
INSERT INTO @DistinctIndexData
SELECT DISTINCT  
	 ObjectName
	,IndexName
	,Is_Unique
	,Type_Desc
	,Is_Padded
	,[Ignore_Dup_Key]
	,[Allow_Row_Locks]
	,[Allow_Page_Locks]
	,Fill_Factor
	,FileGroupName
	,Has_Filter
	,Filter_Definition
FROM @WholeIndexData
WHERE ObjectName = @ObjectName;
  
 SELECT @CurLoopCount = Min(Id), @MaxLoopCount = Max(Id) FROM @DistinctIndexData WHERE ObjectName = @ObjectName
  
 --SELECT @CurLoopCount, @MaxLoopCount  
  
 -------------Loop till all the indexes are processed----------------------   
  
 WHILE(@CurLoopCount <= @MaxLoopCount)  
 BEGIN  
  
  SET @IndexKeySQL = ''  
  SET @IncludeColSQL = ''  
  
  -------------Get the current index row to be processed----------------------  
  SELECT   
   @IndName   = IndexName  
   ,@Type   = Type_Desc
   ,@ExistingFGName = FileGroupName
   ,@IsUnique  = CASE WHEN Is_Unique = 1 THEN 'UNIQUE ' ELSE '' END  
   ,@IsPadded  = CASE WHEN Is_Padded = 0 THEN 'OFF,' ELSE 'ON,'  END  
   ,@IgnoreDupKey = CASE WHEN Ignore_Dup_Key = 0 THEN 'OFF,' ELSE 'ON,' END  
   ,@AllowRowLocks = CASE WHEN Allow_Row_Locks = 0 THEN 'OFF,' ELSE 'ON,' END 
   ,@AllowPageLocks = CASE WHEN Allow_Page_Locks = 0 THEN 'OFF,' ELSE 'ON,' END  
   ,@FillFactor  = CASE WHEN Fill_Factor = 0 THEN 100 ELSE Fill_Factor END  
   ,@FilterDef  = CASE WHEN Has_Filter = 1 THEN (' WHERE ' + Filter_Definition) ELSE '' END  
  FROM @DistinctIndexData   
  WHERE Id = @CurLoopCount  
    
  -------------Check if the index is already not part of that FileGroup----------------------  
  
  IF(@ExistingFGName = @FileGroupName)  
  BEGIN  
   PRINT 'Index ' +  @IndName + ' is NOT moved as it is already part of the FileGroup ' + @FileGroupName + '.'  
   SET @CurLoopCount = @CurLoopCount + 1  
   CONTINUE  
  END  
  
  ------- Construct the Index key string along with the direction--------------------  
	SELECT @IndexKeySQL = CASE 
			WHEN @IndexKeySQL = ''
				THEN (
						@IndexKeySQL + QUOTENAME(ColumnName) + CASE 
							WHEN Is_Descending_Key = 0
								THEN ' ASC'
							ELSE ' DESC'
							END
						)
			ELSE (
					@IndexKeySQL + ',' + QUOTENAME(ColumnName) + CASE 
						WHEN Is_Descending_Key = 0
							THEN ' ASC'
						ELSE ' DESC'
						END
					)
			END
	FROM @WholeIndexData
	WHERE ObjectName = @ObjectName
		AND IndexName = @IndName
		AND Is_Included_Column = 0
	ORDER BY key_ordinal ASC

    
  --PRINT @IndexKeySQL   
    
  ------ Construct the Included Column string --------------------------------------  
  SELECT   
   @IncludeColSQL =   
   CASE  
   WHEN @IncludeColSQL = '' THEN (@IncludeColSQL + QUOTENAME(ColumnName))   
   ELSE (@IncludeColSQL + ',' + QUOTENAME(ColumnName))   
   END   
  FROM @WholeIndexData  
  WHERE ObjectName = @ObjectName   
  AND IndexName = @IndName   
  AND Is_Included_Column = 1
  ORDER BY key_ordinal ASC  
    
  --PRINT @IncludeColSQL  
  
  -------------Construct the final Create Index statement----------------------  
  SELECT 
  @FinalSQL = 'CREATE ' + @IsUnique + @Type + ' INDEX ' + QUOTENAME(@IndName) 
  + ' ON ' + QUOTENAME(@DBName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName)  
  + '(' + @IndexKeySQL + ') '   
  + CASE WHEN LEN(@IncludeColSQL) <> 0 THEN  'INCLUDE(' + @IncludeColSQL + ') ' ELSE '' END
  + @FilterDef  
  + ' WITH ('   
  + 'PAD_INDEX = ' + @IsPadded   
  + 'IGNORE_DUP_KEY = ' + @IgnoreDupKey  
  + 'ALLOW_ROW_LOCKS  = ' + @AllowRowLocks   
  + 'ALLOW_PAGE_LOCKS  = ' + @AllowPageLocks   
  + 'SORT_IN_TEMPDB = OFF,'   
  + 'DROP_EXISTING = ON,'   
  + 'ONLINE = OFF,'  
  + 'FILLFACTOR = ' + CAST(@FillFactor AS Varchar(3))  
  + ') ON ' + QUOTENAME(@FileGroupName)  
  
  --PRINT @FinalSQL  
  
  -------------Execute the Create Index statement to move to the specified filegroup----------------------  
  BEGIN TRY  
   EXEC sp_executesql @FinalSQL  
  END TRY  
  BEGIN CATCH  
   SELECT @ErrorMessage = ERROR_MESSAGE()   
   GOTO ABEND  
  END CATCH   
  PRINT 'Index ' +  @IndName + ' on Object ' + @ObjectName + ' is moved successfully.'   
    
  SET @CurLoopCount = @CurLoopCount + 1  
  
 END  
   
 SET @StartPos = @StartPos + 1  
END  
 SELECT 'The procedure completed successfully.'  
 RETURN  
  
ABEND:  
 RAISERROR (@ErrorMessage, 16, 1);
  
FINAL:  
 RETURN    
END 
GO
--------------------------------------------------------------------
--ساخت بانک اطلاعاتی
--پروسیجر هم ساخته شود
USE master
GO
IF DB_ID('MyDB2017')>0
BEGIN
	ALTER DATABASE MyDB2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE MyDB2017
END
GO
CREATE DATABASE MyDB2017 
	ON  PRIMARY
	(
		NAME=MyDB2017,FILENAME='C:\Temp\MyDB2017.mdf'
	),
	FILEGROUP FG_Stock
	(
		NAME=Data_Stock,FILENAME='C:\Temp\Data_Stock.ndf'
	),
	FILEGROUP FG_Index
	(
		NAME=Data_Index,FILENAME='C:\Temp\Data_Index.ndf'
	)
	LOG ON
	(
		NAME=MyDB2017_log1,FILENAME='C:\Temp\MyDB2017_log.LDF'
	)
GO
USE MyDB2017
GO
--مشاهده فایل های مربوط به بانک اطلاعاتی
SP_HELPFILE
SELECT * FROM sys.database_files
GO
--سوال : اندازه و نحوه رشد این بانک اطلاعاتی بر چه اساسی ایجاد شده است
GO
--مشاهده فایل گروه های مربوط به بانک اطلاعاتی
SP_HELPFILEGROUP
SELECT * FROM SYS.filegroups
GO
DROP TABLE IF EXISTS Stock_Table
GO
--ایجاد جدول
CREATE TABLE Stock_Table
(
	ID INT PRIMARY KEY,
	Info1 CHAR(7000) DEFAULT 'Stock_Table_Test',
	Info2 CHAR(500)
) ON FG_Stock
GO
--بررسی فایل گروه جدول
SP_HELP Stock_Table
GO
--ایجاد جدول
CREATE NONCLUSTERED INDEX IX01 ON 
	Stock_Table (Info2) 
GO
--بررسی ایندکس های جدول
SP_HELPINDEX Stock_Table
GO
--های تخصیص داده شده به هر کدام از فایل هاExtent بررسی وضعیت 
DBCC SHOWFILESTATS
GO
--بررسی وضعیت حجم هر کدام از فایل ها
SELECT 
	DB_NAME() AS [DatabaseName],
	 Name, file_id, 
	 physical_name,
	(size * 8.0/1024) as Size,
	((size * 8.0/1024) - (FILEPROPERTY(name, 'SpaceUsed') * 8.0/1024)) As FreeSpace
From sys.database_files
GO
--درج داده های تستی در جدول
DECLARE @X INT=1
WHILE @X<=10000
BEGIN
	INSERT INTO Stock_Table(ID,Info2) VALUES (@X,'TEST'+CAST(@X AS varchar(10)))
	SET @X+=1
END
GO
SELECT * FROM Stock_Table
GO
--های تخصیص داده شده به هر کدام از فایل هاExtent بررسی وضعیت 
DBCC SHOWFILESTATS
GO
--بررسی وضعیت حجم هر کدام از فایل ها
SELECT 
	DB_NAME() AS [DatabaseName],
	 Name, file_id, 
	 physical_name,
	(size * 8.0/1024) as Size,
	((size * 8.0/1024) - (FILEPROPERTY(name, 'SpaceUsed') * 8.0/1024)) As FreeSpace
From sys.database_files
GO
EXEC MoveIndexToFileGroup   
	@DBName ='MyDB2017',   
	@SchemaName = 'dbo',       
	@ObjectNameList ='Stock_Table',        
	@IndexName  = null,  
	@FileGroupName ='FG_Index'
GO
--بررسی ایندکس های جدول
SP_HELPINDEX Stock_Table
GO