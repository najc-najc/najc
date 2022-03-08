USE master 
go
-- Vamos a usar la carpeta C:\Data

DROP DATABASE IF EXISTS [SalvamentoTest]
GO

CREATE DATABASE [SalvamentoTest]
	ON PRIMARY ( NAME = 'SalvamentoTest', 
		FILENAME = 'C:\Data\SalvamentoTest.mdf' , 
		SIZE = 15360KB , MAXSIZE = UNLIMITED, FILEGROWTH = 0) 
	LOG ON ( NAME = 'SalvamentoTest_log', 
		FILENAME = 'C:\Data\SalvamentoTest_log.ldf' , 
		SIZE = 10176KB , MAXSIZE = 2048GB , FILEGROWTH = 10%) 
GO

USE SalvamentoTest
GO
-- CREATE FILEGROUPS
ALTER DATABASE SalvamentoTest ADD FILEGROUP [FG_Archivo] 
GO 
ALTER DATABASE SalvamentoTest ADD FILEGROUP [FG_2020] 
GO 
ALTER DATABASE SalvamentoTest ADD FILEGROUP [FG_2021] 
GO 
ALTER DATABASE SalvamentoTest ADD FILEGROUP [FG_2022] 
GO


select * from sys.filegroups
GO

-- -Creamos los archivos

ALTER DATABASE SalvamentoTest ADD FILE ( NAME = 'Rescates_Archivo', FILENAME = 'c:\DATA\Rescates_Archivo.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [FG_Archivo] 
GO
ALTER DATABASE SalvamentoTest  ADD FILE ( NAME = 'rescates_2020', FILENAME = 'c:\DATA\rescates_2020.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [FG_2020] 
GO
ALTER DATABASE SalvamentoTest  ADD FILE ( NAME = 'rescates_2021', FILENAME = 'c:\DATA\rescates_2021.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [FG_2021] 
GO
ALTER DATABASE SalvamentoTest  ADD FILE ( NAME = 'rescates_2022', FILENAME = 'c:\DATA\rescates_2022.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) TO FILEGROUP [FG_2022] 
GO

--Vamos a listar las páginas asignadas a cada archivo
DBCC SHOWFILESTATS
GO

select * from sys.filegroups
GO

select * from sys.database_files
GO


-- VAMOS A CREAR LAS PARTITION FUNCTION, ESTAS SON LAS QUE DELIMITAN EL RANGO DE VALORES QUE QUERAMOS


CREATE PARTITION FUNCTION FN_rescates_fecha (datetime) 
AS RANGE RIGHT 
	FOR VALUES ('2020-01-01','2021-01-01','2022-01-01')
GO

--Si queremos borrar la función
--drop partition function FN_rescates_fecha


-- Vamos a crear el PARTITION SCHEME para la función que creamos antes

CREATE PARTITION SCHEME rescate_fecha 
AS PARTITION FN_rescates_fecha 
	TO (FG_Archivo,FG_2020,FG_2021,FG_2022) 
GO


DROP TABLE IF EXISTS Rescates
GO
CREATE TABLE Rescates
	( id_rescate int identity (1,1), 
	nombre varchar(20), 
	apellido varchar (20), 
	fecha_rescate datetime ) 
	ON  [rescate_fecha]-- partition scheme
		(fecha_rescate) -- the column to apply the function within the scheme
GO

--Insertamos valores en la taba

INSERT INTO [dbo].[Rescates] 
	Values ('Antonio','Ruiz','2020-01-01'), 
			('Lucas','García','2020-05-05'), 
			('Manuel','Sanchez','2020-08-11')
Go



SELECT *,$Partition.FN_rescates_fecha([fecha_rescate]) AS Partition
FROM [dbo].[Rescates]
GO

--id_alta	nombre	apellido	fecha_alta					Partition
--1			Antonio	Ruiz		2020-01-01 00:00:00.000		2
--2			Lucas	García		2020-05-05 00:00:00.000		2
--3			Manuel	Sanchez		2020-11-08 00:00:00.000		2


-- partition function
select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'FN_rescates_fecha'
GO

--name					create_date					value
--FN_rescates_fecha		2022-03-06 23:54:37.177		2020-01-01 00:00:00.000
--FN_rescates_fecha		2022-03-06 23:54:37.177		2021-01-01 00:00:00.000
--FN_rescates_fecha		2022-03-07 00:35:24.530		2022-01-01 00:00:00.000

select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'Rescates' 
GO

--partition_number	rows
--1	0
--2	3
--3	0

DECLARE @TableName NVARCHAR(200) = N'Rescates' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object		p#	filegroup	rows	pages	comparison	value						first_page
--dbo.Rescates	1	FG_Archivo	0		0		less than	2020-01-01 00:00:00.000		0:0
--dbo.Rescates	2	FG_2020		3		9		less than	2021-01-01 00:00:00.000		4:8
--dbo.Rescates	3	FG_2021		0		0		less than	NULL						0:0
--dbo.Rescates	4	FG_2022		0		0		less than	NULL						0:0
-------------------
INSERT INTO [dbo].[Rescates]
	VALUES  ('Laura','Muñoz','2021-01-02'), 
			('Rosa Maria','Leandro','2021-06-03'), 
			('Federico','Ramos','2021-07-06')
GO

SELECT *,$Partition.FN_rescates_fecha(fecha_rescate) 
FROM Rescates
GO

-- (3 rows affected)


select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'FN_rescates_fecha'
gO

--name				create_date				value
--FN_rescates_fecha	2022-03-06 23:54:37.177	2020-01-01 00:00:00.000
--FN_rescates_fecha	2022-03-06 23:54:37.177	2021-01-01 00:00:00.000
--FN_rescates_fecha	2022-03-07 00:35:24.530	2022-01-01 00:00:00.000

select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'Rescates' 
GO

--partition_number	rows
--1					0
--2					3
--3					3
--4					0


DECLARE @TableName NVARCHAR(200) = N'Rescates' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object		p#	filegroup	rows	pages	comparison	value						first_page
--dbo.Rescates	1	FG_Archivo	0		0		less than	2020-01-01 00:00:00.000		0:0
--dbo.Rescates	2	FG_2020		3		9		less than	2021-01-01 00:00:00.000		4:8
--dbo.Rescates	3	FG_2021		3		9		less than	2022-01-01 00:00:00.000		5:8
--dbo.Rescates	4	FG_2022		0		0		less than	NULL						0:0
--------------------
INSERT INTO [dbo].[Rescates] 
	VALUES ('Amanda','Smith','2022-01-02'), 
	('Adolfo','Muñiz','2022-01-04'), 
	('Rosario','Fuertes','2222-02-11')
GO



SELECT *,$Partition.[FN_rescates_fecha](fecha_rescate) as PARTITION
FROM Rescates
GO

--id_alta	nombre		apellido	fecha_alta					PARTITION
--1			Antonio		Ruiz		2020-01-01 00:00:00.000		2
--2			Lucas		García		2020-05-05 00:00:00.000		2
--3			Manuel		Sanchez		2020-11-08 00:00:00.000		2
--4			Laura		Muñoz		2021-02-01 00:00:00.000		3
--5			Rosa Maria	Leandro		2021-03-06 00:00:00.000		3
--6			Federico	Ramos		2021-06-07 00:00:00.000		3
--7		Amanda		Smith		2022-02-01 00:00:00.000		4
--8		Adolfo		Muñiz		2022-04-01 00:00:00.000		4
--9		Rosario		Fuertes		2022-11-02 00:00:00.000		4

select name, create_date, value from sys.partition_functions f 
inner join sys.partition_range_values rv 
on f.function_id=rv.function_id 
where f.name = 'FN_rescates_fecha'
gO

--name				create data				value
--FN_rescates_fecha	2022-03-07 00:35:24.530	2020-01-01 00:00:00.000
--FN_rescates_fecha	2022-03-07 00:35:24.530	2021-01-01 00:00:00.000
--FN_rescates_fecha	2022-03-07 00:35:24.530	2022-01-01 00:00:00.000

select p.partition_number, p.rows from sys.partitions p 
inner join sys.tables t 
on p.object_id=t.object_id and t.name = 'Rescates' 
GO

--Observamos que salvo la primra partición, todas las demás tienen datos

--partition_number	rows
--1					0
--2					3
--3					3
--4					3


DECLARE @TableName NVARCHAR(200) = N'Rescates' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO


--object		p#	filegroup	rows	pages	comparison	value						first_page
--dbo.Rescates	1	FG_Archivo	0		0		less than	2020-01-01 00:00:00.000		0:0
--dbo.Rescates	2	FG_2020		3		9		less than	2021-01-01 00:00:00.000		4:8
--dbo.Rescates	3	FG_2021		3		9		less than	2022-01-01 00:00:00.000		5:8
--dbo.Rescates	4	FG_2022		3		9		less than	NULL						6:8




-----------------------------------------------------------------------------------



-- PARTITIONS OPERATIONS



-- SPLIT

--Para probar esta funcionalidad, vamos a dividir nuestra partición
--vamos a preparar nuestra función para el año que viene y 
--"si alguien se equivoco" poniendo la fecha, lo sabremos.
ALTER PARTITION FUNCTION FN_rescates_fecha()
	SPLIT RANGE ('2023-01-01'); 
GO
--Msg 7710, Level 16, State 1, Line 249
--Advertencia: el esquema de partición 'rescate_fecha' no tiene ningún grupo de archivos usado a continuación. El esquema de partición no ha cambiado.

--Nos sale el error, debido a que no hay ningún lugar a donde se puedan mover esos datos
--Lo que hacemos es:   
--crear un filegroup,
ALTER DATABASE SalvamentoTest ADD FILEGROUP [FG_2022_New] 
GO
--un .ndf
ALTER DATABASE SalvamentoTest 
ADD FILE ( NAME = 'rescates_2022_New', FILENAME = 'c:\DATA\rescates_2022_new.ndf', SIZE = 5MB, MAXSIZE = 100MB, FILEGROWTH = 2MB ) 
TO FILEGROUP [FG_2022_New] 
GO
--Vamos a listar las páginas asignadas a cada archivo
DBCC SHOWFILESTATS
GO
--y le vamos a decir que lo use.
ALTER PARTITION SCHEME [rescate_fecha] NEXT USED [FG_2022_New]
GO

ALTER PARTITION FUNCTION FN_rescates_fecha() 
	SPLIT RANGE ('2023-01-01'); 
GO

SELECT *,$Partition.FN_rescates_fecha(fecha_rescate) as PARTITION
FROM Rescates
GO
--Vemos que se han cambiado de partición nuestros datos

DECLARE @TableName NVARCHAR(200) = N'Rescates' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--Aquí podemos observar como se han modificado los datos en las particiones 4 y 5

--object			p#	filegroup	rows	pages	comparison	value						first_page
--dbo.Rescates		1	FG_Archivo	0		0		less than	2020-01-01 00:00:00.000		0:0
--dbo.Rescates		2	FG_2020		3		9		less than	2021-01-01 00:00:00.000		4:8
--dbo.Rescates		3	FG_2021		3		9		less than	2022-01-01 00:00:00.000		5:8
--dbo.Rescates		4	FG_2022		2		9		less than	2023-01-01 00:00:00.000		6:8
--dbo.Rescates		5	FG_2022_New	1		9		less than	NULL						7:8				6:88


---------------------------------------------------------------------------------


-- MERGE


--Con merge lo que hacemos es quitar una de las particiones y la fucionamos con las restantes
--En nuestro caso van a la primera (1)
ALTER PARTITION FUNCTION FN_rescates_fecha()
 MERGE RANGE ('2020-01-01'); 
 GO

SELECT *,$Partition.FN_rescates_fecha(fecha_rescate) 
FROM Rescates
GO
DECLARE @TableName NVARCHAR(200) = N'Rescates' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object			p#	filegroup	rows	pages	comparison	value						first_page
--dbo.Rescates		1	FG_Archivo	3		9		less than	2021-01-01 00:00:00.000		3:8
--dbo.Rescates		2	FG_2021		3		9		less than	2022-01-01 00:00:00.000		5:8
--dbo.Rescates		3	FG_2022		3		9		less than	NULL						6:8



--Ahora que le hemos quitado los datos al archivo de 2020, lo podemos borrar.
USE master
GO
ALTER DATABASE [SalvamentoTest] REMOVE FILE Rescates_2020
go
--También podemos borrar el filegroup de 2020
ALTER DATABASE [SalvamentoTest] REMOVE FILEGROUP FG_2020
GO

USE [SalvamentoTest]
GO
select * from sys.filegroups
GO
select * from sys.database_files
GO



-------------------------------------------------------------------------------



-- SWITCH

--De la documentación de microsoft
--Modifica un bloqueo de datos de una de las formas siguientes:
    --Vuelve a asignar todos los datos de una tabla como una partición en una tabla con particiones ya existente.
    --Modifica una partición de una tabla con particiones a otra.
    --Vuelve a asignar todos los datos de una partición de una tabla con particiones a una tabla sin particiones ya existente.

USE [SalvamentoTest]
go

SELECT *,$Partition.FN_rescates_fecha([fecha_rescate]) 
FROM Rescates
GO
DECLARE @TableName NVARCHAR(200) = N'Rescates' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--object		p#	filegroup	rows	pages	comparison	value						first_page
--dbo.Rescates	1	FG_Archivo	3		9		less than	2021-01-01 00:00:00.000		3:8
--dbo.Rescates	2	FG_2021		3		9		less than	2022-01-01 00:00:00.000		5:8
--dbo.Rescates	3	FG_2022		3		9		less than	NULL						6:8

--Creamos la tabla(target) donde introduciremos los datos, tenemos que tener en 
--cuenta que tiene que ser igual a la otra(source)

CREATE TABLE Archivo_rescates 
( id_rescate int identity (1,1), 
nombre varchar(20), 
apellido varchar (20), 
fecha_rescate datetime ) 
ON FG_Archivo
go
--Como tenemos nuestra tabla con particiones, necesitamos decirle en cuál está
--para asignarle esos datos
ALTER TABLE Rescates
	SWITCH Partition 1 to Archivo_rescates
go

select * from rescates 
go

--Ya no vemos los datos que están en la partición 1, 
--que son los que antigüamente se encontraban en la partición 2
--perteneciente al año 2020 que hemos eliminado

--id_alta	nombre		apellido	fecha_alta
--4			Laura		Muñoz		2021-02-01 00:00:00.000
--5			Rosa Maria	Leandro		2021-03-06 00:00:00.000
--6			Federico	Ramos		2021-06-07 00:00:00.000
--7			Amanda		Smith		2022-02-01 00:00:00.000
--8			Adolfo		Muñiz		2022-04-01 00:00:00.000
--9			Rosario		Fuertes		2022-11-02 00:00:00.000


select * from Archivo_rescates 
go

--Comprobamos que lo que se ha pasado a nuestra nueva tabla 
--son los datos de la partición 1.

--id_alta	nombre	apellido	fecha_alta
--1			Antonio	Ruiz		2020-01-01 00:00:00.000
--2			Lucas	García		2020-05-05 00:00:00.000
--3			Manuel	Sanchez		2020-11-08 00:00:00.000



DECLARE @TableName NVARCHAR(200) = N'Rescates' SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows
, au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--Podemos ver que FG_Archivo se ha quedado vacío ya que hemos pasado 
--los datos a nuestra nueva tabla

--object			p#	filegroup	rows	pages	comparison	value						first_page
--dbo.Rescates	1	FG_Archivo		0		0		less than	2021-01-01 00:00:00.000		0:0
--dbo.Rescates	2	FG_2021			3		9		less than	2022-01-01 00:00:00.000		5:8
--dbo.Rescates	3	FG_2022			3		9		less than	NULL						6:8



-------------------------------------------------------------------------------------



-- TRUNCATE

--Con truncate vamos a eliminar los datos que se encuentren en una partición dentro de 
--una tabla con particiones

TRUNCATE TABLE [dbo].[Rescates]
	WITH (PARTITIONS (3));
go

select * from [dbo].[Rescates]
GO

--Vemos que ya no quedan datos de la partición 3

--id_alta	nombre		apellido	fecha_alta
--4			Laura		Muñoz		2021-02-01 00:00:00.000
--5			Rosa Maria	Leandro		2021-03-06 00:00:00.000
--6			Federico	Ramos		2021-06-07 00:00:00.000


DECLARE @TableName NVARCHAR(200) = N'Rescates' 
SELECT SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(i.object_id) AS [object] , p.partition_number AS [p#] , fg.name AS [filegroup] , p.rows , au.total_pages AS pages , CASE boundary_value_on_right WHEN 1 THEN 'less than' ELSE 'less than or equal to' END as comparison , rv.value , CONVERT (VARCHAR(6), CONVERT (INT, SUBSTRING (au.first_page, 6, 1) + SUBSTRING (au.first_page, 5, 1))) + ':' + CONVERT (VARCHAR(20), CONVERT (INT, SUBSTRING (au.first_page, 4, 1) + SUBSTRING (au.first_page, 3, 1) + SUBSTRING (au.first_page, 2, 1) + SUBSTRING (au.first_page, 1, 1))) AS first_page FROM sys.partitions p INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id INNER JOIN sys.objects o
ON p.object_id = o.object_id INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id WHERE i.index_id < 2 AND o.object_id = OBJECT_ID(@TableName);
GO

--Vemos también que la partición 3 se ha quedado vacía

--object			p#	filegroup	rows	pages	comparison	value						first_page
--dbo.Rescates		1	FG_Archivo	0		0		less than	2021-01-01 00:00:00.000		0:0
--dbo.Rescates		2	FG_2021		3		9		less than	2022-01-01 00:00:00.000		5:8
--dbo.Rescates		3	FG_2022		0		0		less than	NULL						0:0










