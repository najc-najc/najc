--Lo mismo que en el caso de Filestream
EXEC sp_configure filestream_access_level, 2
RECONFIGURE
GO
-- FileTable

DROP DATABASE IF EXISTS FTSalva
GO

--Se crea la carpeta FTSalva en C: para esta demostración

--Sentencia para bd que contienen filetables, es así segun manual de Microsoft

CREATE DATABASE FTSalva
ON PRIMARY
(
    NAME = FTSalva_data,
    FILENAME = 'C:\FTSalva\FTSalvaFileTable.mdf'
),

--este sería un .ndf

FILEGROUP FileStreamFG CONTAINS FILESTREAM
(
    NAME = FTSalva,
    FILENAME = 'C:\FTSalva\FTSalva_Container' 
)
LOG ON
(
    NAME = FTSalva_Log,
    FILENAME = 'C:\FTSalva\FTSalva_Log.ldf'
)
WITH FILESTREAM
(
    NON_TRANSACTED_ACCESS = FULL,
    DIRECTORY_NAME = 'FTSalvaContainer'
);
GO
-------------------------
-- Vamos a comprobar opciones con METADATA

  --una forma
SELECT DB_NAME(database_id),
non_transacted_access,
non_transacted_access_desc
FROM sys.database_filestream_options;
GO
  -- Otra forma
SELECT DB_NAME(database_id) as DatabaseName, non_transacted_access, non_transacted_access_desc 
FROM sys.database_filestream_options
where DB_NAME(database_id)='SQLFileTable';
GO

 --Opciones para el acceso sin transacciones:
 --OFF: No se permite el acceso no transaccional a FileTables.
 --Read Only: Se permite el acceso no transaccional a FileTables con fines de solo lectura.
 --Full: Se permite el acceso no transaccional a FileTables tanto para lectura como para escritura.

-- Createe FileTable Table
USE FTSalva
GO
DROP TABLE IF EXISTS FTSalvaDocs 
GO
--se supone que con las apis se ve su uso, tenemos que saber que esta tabla es para eso
CREATE TABLE FTSalvaDocs 
AS FILETABLE
WITH 
(
    FileTable_Directory = 'FTSalvaContainer',
    FileTable_Collate_Filename = database_default
);
GO
  -- Mirar que se ha creado en el OBJECT EXPLORER.
  --Va a estar en tables-->FileTables-->columns 
  --(se crea todo eso de forma automática, es el sistema el que maneja este tipo de tablas)

-- Ahora ya podemos hacer un select normal.

SELECT *
FROM FTSalvaDocs
GO

  --Click derecho en la tabla y le damos a explore filetable directory, nos abre una carpeta.
  -- Metemos(arrastrando) 3 archivos de imagen .jpg y uno .csv

SELECT *
FROM FTSalvaDocs
GO


  --otra forma de hacer un select 
SELECT TOP (1000) [stream_id]
      ,[file_stream]
      ,[name]
      ,[path_locator]
      ,[parent_path_locator]
      ,[file_type]
      ,[cached_file_size]
      ,[creation_time]
      ,[last_write_time]
      ,[last_access_time]
      ,[is_directory]
      ,[is_offline]
      ,[is_hidden]
      ,[is_readonly]
      ,[is_archive]
      ,[is_system]
      ,[is_temporary]
  FROM [FTSalva].[dbo].[FTSalvaDocs]
GO

--Otra forma más de select

SELECT  [stream_id],[name]
  FROM [FTSalva].[dbo].[FTSalvaDocs]
GO

--  stream_id								 name
--38A07A96-8B9D-EC11-9B8D-080027287BAD		Nombres.csv
--8D10C29B-8B9D-EC11-9B8D-080027287BAD	    GC.jpg
--8E10C29B-8B9D-EC11-9B8D-080027287BAD	    Bomberos.jpg
--8F10C29B-8B9D-EC11-9B8D-080027287BAD	    SalvamentoM.jpg






