USE MASTER 
GO

DROP DATABASE IF EXISTS [DB_najc_10_marzo]
GO

CREATE DATABASE DB_najc_10_marzo
GO

USE [DB_najc_10_marzo]
GO

ALTER DATABASE [DB_najc_10_marzo] ADD FILEGROUP [FG_ARCHIVO]
ALTER DATABASE [DB_najc_10_marzo] ADD FILEGROUP [FG_2011]
ALTER DATABASE [DB_najc_10_marzo] ADD FILEGROUP [FG_2012]
ALTER DATABASE [DB_najc_10_marzo] ADD FILEGROUP [FG_2013]
ALTER DATABASE [DB_najc_10_marzo] ADD FILEGROUP [FG_2014]
ALTER DATABASE [DB_najc_10_marzo] ADD FILEGROUP [FG_PRUEBA]

ALTER DATABASE [DB_najc_10_marzo]
ADD FILE (
	NAME ='examen_Archivo', 
	FILENAME = 'c:\DATA\examen_Archivo.ndf', 
	SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB )
	TO FILEGROUP [FG_ARCHIVO] 
GO
ALTER DATABASE [DB_najc_10_marzo]
ADD FILE (
	NAME ='examen_2011', 
	FILENAME = 'c:\DATA\examen_2011.ndf', 
	SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB )
	TO FILEGROUP [FG_2011] 
GO
ALTER DATABASE [DB_najc_10_marzo]
ADD FILE (
	NAME ='examen_2012', 
	FILENAME = 'c:\DATA\examen_2012.ndf', 
	SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB )
	TO FILEGROUP [FG_2012] 
GO
ALTER DATABASE [DB_najc_10_marzo]
ADD FILE (
	NAME ='examen_2013', 
	FILENAME = 'c:\DATA\examen_2013.ndf', 
	SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB )
	TO FILEGROUP [FG_2013] 
GO
ALTER DATABASE [DB_najc_10_marzo]
ADD FILE (
	NAME ='examen_2014', 
	FILENAME = 'c:\DATA\examen_2014.ndf', 
	SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB )
	TO FILEGROUP [FG_2014]
GO
ALTER DATABASE [DB_najc_10_marzo]
ADD FILE (
	NAME ='examen_PRUEBA', 
	FILENAME = 'c:\DATA\examen_PRUEBA.ndf', 
	SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB )
	TO FILEGROUP [FG_PRUEBA]
GO

DROP PARTITION FUNCTION FN_EXAMEN
GO
CREATE PARTITION FUNCTION FN_EXAMEN (datetime) 
AS RANGE RIGHT 
	FOR VALUES ('2012-01-01','2013-01-01')
GO

CREATE PARTITION SCHEME examen_schema 
AS PARTITION FN_EXAMEN 
	TO ([FG_2011],[FG_2012],[FG_2013],[FG_2014],FG_PRUEBA) 
GO

DROP TABLE IF EXISTS [dbo].[Table_najc_10_marzo]
GO

SELECT * 
INTO Table_najc_10_marzo
FROM AdventureWorks2017.Sales.SalesOrderHeader
GO

SELECT * 
FROM [dbo].[Table_najc_10_marzo]
order by OrderDate asc
GO

CREATE CLUSTERED INDEX examenIndex
        ON [dbo].[Table_najc_10_marzo]
        (OrderDate asc)
        ON examen_schema(OrderDate)
go



SELECT *,$Partition.FN_EXAMEN(OrderDate) AS Partition
FROM [dbo].[Table_najc_10_marzo]
GO

select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'FN_EXAMEN'
GO

select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'Table_najc_10_marzo' 
GO

DECLARE @TableName NVARCHAR(200) = N'Table_najc_10_marzo' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO


--------------------------------------------


---------SPLIT------



ALTER PARTITION FUNCTION FN_EXAMEN ()
	SPLIT RANGE ('2014-01-01'); 
GO


DECLARE @TableName NVARCHAR(200) = N'Table_najc_10_marzo' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'Table_najc_10_marzo' 
GO


---------------------------------------------

-----------------TRUNCATE--------------

TRUNCATE TABLE [dbo].[Table_najc_10_marzo]
	WITH (PARTITIONS (4));
go

DECLARE @TableName NVARCHAR(200) = N'Table_najc_10_marzo' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

-------------------------------------------------

-------PROCEDIMIENTO ALMACENADO


ALTER TABLE [dbo].[Table_najc_10_marzo]
ADD Nombreusuario VARCHAR(50)
GO
ALTER TABLE [dbo].[Table_najc_10_marzo]
ADD PASSWORD  VARCHAR(20)
GO

CREATE OR ALTER VIEW View_najc_10_marzo
AS SELECT * FROM [dbo].[Table_najc_10_marzo]
GO

SELECT * 
FROM [dbo].[View_najc_10_marzo]
GO

CREATE OR ALTER PROC examen_najc_10_marzo
	@Nombre varchar(50), @PASSWORD VARCHAR(20)
AS
IF EXISTS (SELECT *
			FROM View_najc_10_marzo
			WHERE Nombreusuario=@NOMBRE AND PASSWORD=@PASSWORD)
	
		BEGIN
					UPDATE View_najc_10_marzo
					SET [PASSWORD]='aaaaaa'
					WHERE [Nombreusuario]=@NOMBRE;
					SELECT TOP (5) [SalesOrderID],[Nombreusuario],[PASSWORD]
					FROM View_najc_10_marzo
				END
		ELSE
			BEGIN
				PRINT 'ACCESO PROHIBIDO'
			END

GO

select top (3)[SalesOrderID] from View_najc_10_marzo
go

--SalesOrderID
--43659
--43660
--43661

update View_najc_10_marzo 
	set [Nombreusuario] = 'pablo', [PASSWORD] = 'pablo'
	where [SalesOrderID] = 43659
GO
update View_najc_10_marzo 
	set [Nombreusuario] = 'pepe', [PASSWORD] = 'pepe'
	where [SalesOrderID] = 43660
GO
update View_najc_10_marzo 
	set [Nombreusuario] = 'mery', [PASSWORD] = 'mery'
	where [SalesOrderID] = 43661
GO

select top (3) [SalesOrderID],[Nombreusuario],[PASSWORD]
from View_najc_10_marzo
go


EXEC  examen_najc_10_marzo 'pepe','pepe'
go
EXEC  examen_najc_10_marzo 'pablo','pablo'
go
EXEC  examen_najc_10_marzo 'mery','mery'
go



---------------------------------------------------

