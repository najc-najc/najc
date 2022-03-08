USE MASTER
GO

--Para mostrar los procedimientos almacenados de configuración
EXEC sp_configure
go
-- Con esto mostramos los de acceso a filestream
EXEC sp_configure filestream_access_level
go

--Tenemos estos niveles:

--0 = Deshabilitado. Este es el valor por defecto.
--1 = Habilitado solo para acceso T-SQL.
--2 = Habilitado solo para T-SQL y acceso local al sistema de ficheros.
--3 = Habilitado para T-SQL, acceso local y remoto al sistema de ficheros.

--Con esto reconfiguramos el nivel de acceso 
EXEC sp_configure filestream_access_level, 2
RECONFIGURE
GO
--Se ha cambiado la opción de configuración 'filestream access level' de 2 a 2. Ejecute la instrucción RECONFIGURE para instalar.


--Comprobamos que se han camdiado
EXEC sp_configure filestream_access_level
go

----------------------

USE MASTER
GO
--DROP DATABASE IF EXISTS SalvamentoFS
--GO
--CREATE DATABASE SalvamentoFS
--go
USE Salvamento
go

--Las siguientes sentencias las tendremos que poner tal cual, es lo que marca Microsoft en el manual.
ALTER DATABASE Salvamento 
	ADD FILEGROUP [PRIMARY_FILESTREAM] 
	CONTAINS FILESTREAM 
GO
ALTER DATABASE Salvamento
       ADD FILE (
             NAME = 'MyDatabase_filestream',
             FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\filestream'
       )
       TO FILEGROUP [PRIMARY_FILESTREAM]
GO
USE Salvamento
GO
DROP TABLE IF EXISTS IMAGES
GO
--Creamos la tabla imágenes, donde añadiremos las imágenes del proyecto.
CREATE TABLE images(
       id UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE,
       imageFile VARBINARY(MAX) FILESTREAM
);
GO
--Ruta las imágenes C:\blob\
--Con lo siguiente añadimos las imágenes a la base de datos

INSERT INTO images(id, imageFile)
		SELECT NEWID(), BulkColumn
		FROM OPENROWSET(BULK 'C:\blob\montana.jpg', SINGLE_BLOB) as f;
GO
INSERT INTO images(id, imageFile)
	SELECT NEWID(), BulkColumn
	FROM OPENROWSET(BULK 'C:\blob\protecciv.jpg', SINGLE_BLOB) as f;
GO
INSERT INTO images(id, imageFile)
	SELECT NEWID(), BulkColumn
	FROM OPENROWSET(BULK 'C:\blob\salvamento.jpg', SINGLE_BLOB) as f;
GO

SELECT *
FROM images;
GO

-- Esta es la ruta donde se han guardado nuestras imágenes C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\filestream
-- vamos a visualizarlas con PAINT

--Para eliminar las imágenes paso a paso si nos hiciese falta

--ALTER TABLE [dbo].[images] DROP COLUMN [imageFile]
--GO
--ALTER TABLE [images] SET (FILESTREAM_ON="NULL")
--GO
--ALTER DATABASE Salvamento REMOVE FILE MyDatabase_filestream;
--GO

--Msg 5042, Level 16, State 13, Line 134
--The file 'MyDatabase_filestream' cannot be removed because it is not empty.

--nos da un error ya que no está vacía, además de que estamos en la base de datos

--USE master
--GO

--ALTER DATABASE Salvamento REMOVE FILE MyDatabase_filestream;
--GO

--The file 'MyDatabase_filestream' has been removed.

--ALTER DATABASE Salvamento REMOVE FILEGROUP  [PRIMARY_FILESTREAM]
--GO

-- The filegroup 'PRIMARY_FILESTREAM' has been removed.

