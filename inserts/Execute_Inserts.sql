USE Coffee_Time
GO


----------------------------------------------
/* Configures advanced options for cmdshell */
----------------------------------------------
EXEC master.dbo.sp_configure 'show advanced options', 1
RECONFIGURE WITH OVERRIDE
GO


------------------------------------------------
/* Allows using command shell from sql server */
------------------------------------------------
EXEC master.dbo.sp_configure 'xp_cmdshell', 1
RECONFIGURE WITH OVERRIDE
GO


--------------------------------------
/* Create a folder "Backups" in disk D
used temporary table to hide output */
--------------------------------------
DECLARE @tmpNewValue TABLE(newvalue nvarchar(max))
INSERT INTO @tmpNewValue 
EXEC xp_cmdshell 'MD D:\Backups'
GO


---------------------------------------
/* Inserts in table using a csv file */
---------------------------------------
CREATE PROCEDURE Insert_Using_Bulk (
	@user NVARCHAR(30),
	@tableName NVARCHAR(30),
	@fileName NVARCHAR(30)
)
AS
	DECLARE @filePath AS VARCHAR(100) = CONCAT('C:\Users\', @user, '\Desktop\coffee-bd\inserts\', @fileName)
	DECLARE @SQL_BULK VARCHAR(MAX)
	SET @SQL_BULK = ('
		BULK INSERT ' + @tableName + ' 
		FROM''' + @filePath + '''
		WITH (FIRSTROW = 1,
			FIELDTERMINATOR = '','',
			ROWTERMINATOR = ''\n'',
			BATCHSIZE = 100000,
			MAXERRORS = 2)'
			);
	PRINT @SQL_BULK
	EXEC (@SQL_BULK)
GO


EXEC Insert_Using_Bulk 'asus', 'Employers', 'insertEmployers.csv'
GO



