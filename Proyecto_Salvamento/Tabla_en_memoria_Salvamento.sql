--tablas en memoria
--lO QUE HACEMOS ES CARGAR LA TABLA QUE SELECCIONEMOS EN LA MEMORIA PPAL,
--CON ESTO CONSEGUIMOS QUE LA LECTURA SEA MUCHO MÁS RÁPIDA.
--Seleccionamos la base de datos que queremos
use [salvamento]
go

--Vamos a ver el nivel de compatibilidad
select d.compatibility_level
	from sys.databases as d 
	where d.name = db_name()
go

--compatibility_level
--150

-- Si hubiera que cambiar el nivel

--alter database current
--	set compatibility_level = 150
--go

-------------------------------------------------
--Solo está permitido un filegroup tipo MEMORY_OPTIMIZED_DATA por base de datos.

--Activamos el "memory_optimized_elevate_to_snapshot"
alter database current
	set memory_optimized_elevate_to_snapshot = on
go

--create an optimized filegroup

alter database [salvamento]
	add filegroup Salvamento_mod
	contains memory_optimized_data
go

--le agregamos los contenedores
-- You need to add one or more containers to the MEMORY_OPTIMIZED_DATA filegroup
alter database [salvamento]
	add file (name='Salvamento_mod1',
	filename='c:\Data\Salvamento_mod1')
	to filegroup Salvamento_mod
go

--Comprobamos que lo tenemos activo
SELECT g.name,
       g.type_desc,
       f.physical_name
FROM sys.filegroups g
    JOIN sys.database_files f
        ON g.data_space_id = f.data_space_id
WHERE g.type = 'FX'
      AND f.type = 2;



--La tabla que utilicemos, tiene que tener una primary key non clustered definida y necesitamos
--crear una nueva para añadirle la optimización de memoria, luego copiaremos los datos de la tabla que queramos
--Para este ejemplo se elige la tabla de ccaa 
sp_helpindex CCAA
GO

--index_name	index_description										index_keys
--CCAA_PK		clustered, unique, primary key located on PRIMARY		id_CCAA

--Creamos la tabla CCAA_opt
drop table if exists CCAA_OPT
go
create table CCAA_OPT
(	[id_CCAA] [int] NOT NULL PRIMARY KEY NONCLUSTERED, --tiene que tener una primary key non clustered 
	[Nombre] [varchar](50) NOT NULL,
)
with
(memory_optimized = on,
durability = schema_and_data)
go
--COMPROBAMOS
sp_helpindex CCAA_OPT
GO
--index_name						index_description										index_keys
--PK__CCAA_OPT__458396501D84289E	nonclustered, unique, primary key located in MEMORY 	id_CCAA

--IMPORTAMOS LOS DATOS
INSERT INTO [dbo].[CCAA_OPT]
SELECT *
FROM [dbo].[CCAA]
GO

SELECT * FROM [dbo].[CCAA]
GO
SELECT * FROM [dbo].[CCAA_OPT]
GO

INSERT INTO [dbo].[CCAA_OPT] 
VALUES (10,'ASTURIAS'), (7,'PAÍS VSACO'), (6,'CEUTA'),(9,'CANARIAS')
GO
SELECT * FROM [dbo].[CCAA_OPT]
GO