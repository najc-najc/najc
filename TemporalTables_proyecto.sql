-- Tablas Temporales

USE master 
go
DROP DATABASE IF EXISTS [SalvamentoTest] 
GO
CREATE DATABASE SalvamentoTest
	ON PRIMARY ( NAME = 'SalvamentoTest', 
	FILENAME = 'C:\Data\SalvamentoTest.mdf' , 
	SIZE = 15360KB , MAXSIZE = UNLIMITED, FILEGROWTH = 0) 
	LOG ON ( NAME = 'SalvamentoTest_log', 
	FILENAME = 'C:\Data\SalvamentoTest_log.ldf' , 
	SIZE = 10176KB , MAXSIZE = 2048GB , FILEGROWTH = 10%) 
GO

USE SalvamentoTest
GO

--Vamos a crear una tabla para ver la cantidad de materiales que se usan en los rescates
--ya que son necesarios y es importante saber los más usados para referencias futuras.
 

create table materiales 
	(   id_material integer identity Primary Key Clustered,  
		nombre varchar (50) NOT NULL,
		cantidad numeric(4,0) NOT NULL,
	SysStartTime datetime2 generated always as row start not null,   --estas sentencias son así porque lo manda el sistema (microsoft)
	SysEndTime datetime2 generated always as row end not null,  
	period for System_time (SysStartTime,SysEndTime) ) 
	with (System_Versioning = ON (History_Table = dbo.materiales_historico) --esta parte también se puede hacer con un alter después, lo mejor es hacerlo ahora
	) 
go

SELECT * FROM [dbo].[materiales]
GO
SELECT * FROM [dbo].[materiales_historico]
GO
--aparecen vacías porque todavía no hemos insertado nada, ni realizado ningún cambio. 



insert into materiales(nombre,cantidad)
values ('Cuerda rapel',2), 
	('linternas',50), 
	('Mantas térmicas',800), 
	('luces químicas',1000), 
	('mosquetones',200) 
GO 
-- (5 rows affected)

SELECT * FROM materiales
GO

--id nombre			cantidad	SysStartTime					SysEndTime
--1	Cuerda rapel	2			2022-03-07 01:13:57.7741204		9999-12-31 23:59:59.9999999
--2	linternas		50			2022-03-07 01:13:57.7741204		9999-12-31 23:59:59.9999999
--3	Mantas térmicas	800			2022-03-07 01:13:57.7741204		9999-12-31 23:59:59.9999999
--4	luces químicas	1000		2022-03-07 01:13:57.7741204		9999-12-31 23:59:59.9999999
--5	mosquetones		200			2022-03-07 01:13:57.7741204		9999-12-31 23:59:59.9999999

SELECT * FROM [dbo].[materiales_historico]
GO

--id nombre			cantidad	SysStartTime					SysEndTime
--no aparece nada ya que todavía no hemos realizado ningún cambio en la tabla de materiales


update materiales 
	set cantidad = 30
	where nombre = 'mantas térmicas'
GO

--(1 row affected)

SELECT * FROM materiales
GO

--id nombre			cantidad	SysStartTime					SysEndTime
--1	Cuerda rapel	2			2022-03-07 01:13:57.7741204		9999-12-31 23:59:59.9999999
--2	linternas		50			2022-03-07 01:13:57.7741204		9999-12-31 23:59:59.9999999
--3	Mantas térmicas	30			2022-03-07 01:13:57.7741204		9999-12-31 23:59:59.9999999
--4	luces químicas	1000		2022-03-07 01:13:57.7741204		9999-12-31 23:59:59.9999999
--5	mosquetones		200			2022-03-07 01:13:57.7741204		9999-12-31 23:59:59.9999999

SELECT * FROM [dbo].[materiales_historico]
GO

--id nombre				cantidad	SysStartTime				SysEndTime
--3	 Mantas térmicas	800			2022-03-07 01:13:57.7741204	2022-03-07 01:17:43.5802858.7257183

--ahora si que tenemos datos en la tabla histórico, ya que se ha realizado un cambio en la tabla ppal

update materiales 
	set cantidad = 1
	where nombre = 'linternas'
GO

SELECT * FROM materiales
GO

--id nombre				cantidad	SysStartTime				SysEndTime
--1	 Cuerda rapel		2			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--2	 linternas			1			2022-03-07 01:29:46.8610454	9999-12-31 23:59:59.9999999
--3	 Mantas térmicas	30			2022-03-07 01:29:36.1428604	9999-12-31 23:59:59.9999999
--4	 luces químicas		1000		2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--5	 mosquetones		200			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999

SELECT * FROM [dbo].[materiales_historico]
GO

--id nombre				cantidad	SysStartTime				SysEndTime
--3  Mantas térmicas	800			2022-03-07 01:29:22.6757686	2022-03-07 01:29:36.1428604
--2	 linternas			50			2022-03-07 01:29:22.6757686	2022-03-07 01:29:46.8610454


--Vamos a añadir una nueva fila
insert into materiales(nombre,cantidad)  
	values ('pilas AAA',5000)
GO

SELECT * FROM materiales
GO

--id nombre				cantidad	SysStartTime				SysEndTime
--1	 Cuerda rapel		2			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--2	 linternas			1			2022-03-07 01:29:46.8610454	9999-12-31 23:59:59.9999999
--3	 Mantas térmicas	30			2022-03-07 01:29:36.1428604	9999-12-31 23:59:59.9999999
--4	 luces químicas		1000		2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--5	 mosquetones		200			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--6	 pilas AAA			5000		2022-03-07 01:33:29.8408370	9999-12-31 23:59:59.9999999


SELECT * FROM [dbo].[materiales_historico]
GO

--podemos observar que no se ha modificado la tabla histórica, ya que no han habido modificaciones en la ppal.

--3	Mantas térmicas	800	2022-03-07 01:29:22.6757686	2022-03-07 01:29:36.1428604
--2	linternas	50	2022-03-07 01:29:22.6757686	2022-03-07 01:29:46.8610454


--Vamos a probar si con un delete se añade un registro a la tabla histórica
delete from materiales 
	where nombre='pilas AAA'
GO

SELECT * FROM materiales
GO

--id nombre				cantidad	SysStartTime				SysEndTime
--1	 Cuerda rapel		2			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--2	 linternas			1			2022-03-07 01:29:46.8610454	9999-12-31 23:59:59.9999999
--3	 Mantas térmicas	30			2022-03-07 01:29:36.1428604	9999-12-31 23:59:59.9999999
--4	 luces químicas		1000		2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--5	 mosquetones		200			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999

--Comprobamos que se borra de nuestra tabla ppal

--Consultamos la histórica
SELECT * FROM [dbo].[materiales_historico]
GO

--id nombre				cantidad	SysStartTime				SysEndTime
--3	 Mantas térmicas	800			2022-03-07 01:29:22.6757686	2022-03-07 01:29:36.1428604
--2  linternas			50			2022-03-07 01:29:22.6757686	2022-03-07 01:29:46.8610454
--6	 pilas AAA			5000		2022-03-07 01:33:29.8408370	2022-03-07 01:41:15.6938843

--Observamos que ahora sí, al usar delete, se modifica la tabla ppal por lo tanto se modifica la tabla histórica






-- Con “for system_time all” vemos todas las operaciones realizadas sobre la tabla

select * 
from materiales 
for system_time all 
go

--id nombre				cantidad	SysStartTime				SysEndTime
--1	Cuerda rapel		2			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--2	linternas			1			2022-03-07 01:29:46.8610454	9999-12-31 23:59:59.9999999
--3	Mantas térmicas		30			2022-03-07 01:29:36.1428604	9999-12-31 23:59:59.9999999
--4	luces químicas		1000		2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--5	mosquetones			200			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--3	Mantas térmicas		800			2022-03-07 01:29:22.6757686	2022-03-07 01:29:36.1428604
--2	linternas			50			2022-03-07 01:29:22.6757686	2022-03-07 01:29:46.8610454
--6	pilas AAA			5000		2022-03-07 01:33:29.8408370	2022-03-07 01:41:15.6938843

select * 
from [dbo].[materiales_historico]
for system_time all 
go

--Msg 13544, Level 16, State 2, Line 193
--La cláusula FOR SYSTEM_TIME temporal solo se puede usar en tablas con versiones del sistema. 'SalvamentoTest.dbo.materiales_historico' no es una con versiones del sistema.

--Vemos que no se puede usar para las tablas históricas

SELECT * FROM materiales
GO

--id nombre				cantidad	SysStartTime				SysEndTime
--1	Cuerda rapel		2			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--2	linternas			1			2022-03-07 01:29:46.8610454	9999-12-31 23:59:59.9999999
--3	Mantas térmicas		30			2022-03-07 01:29:36.1428604	9999-12-31 23:59:59.9999999
--4	luces químicas		1000		2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--5	mosquetones			200			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999

SELECT * FROM [dbo].[materiales_historico]
GO

--id nombre				cantidad	SysStartTime				SysEndTime
--3	Mantas térmicas		800			2022-03-07 01:29:22.6757686	2022-03-07 01:29:36.1428604
--2	linternas			50			2022-03-07 01:29:22.6757686	2022-03-07 01:29:46.8610454
--6	pilas AAA			5000		2022-03-07 01:33:29.8408370	2022-03-07 01:41:15.6938843


-- Con “for system_time as of” vemos el estado de la tabla en un determinado punto en el tiempo.

--Vamos a probar en el momento en el que añadimos las pilas
--6	 pilas AAA			5000		2022-03-07 01:33:29.8408370	9999-12-31 23:59:59.9999999

select * 
from materiales 
for system_time as of '2022-03-07 01:33:29.8408370' 
go


--id nombre				cantidad	SysStartTime				SysEndTime
--1	Cuerda rapel		2			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--2	linternas			1			2022-03-07 01:29:46.8610454	9999-12-31 23:59:59.9999999
--3	Mantas térmicas		30			2022-03-07 01:29:36.1428604	9999-12-31 23:59:59.9999999
--4	luces químicas		1000		2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--5	mosquetones			200			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--3	Mantas térmicas		800			2022-03-07 01:29:22.6757686	2022-03-07 01:29:36.1428604
--2	linternas			50			2022-03-07 01:29:22.6757686	2022-03-07 01:29:46.8610454
--6	pilas AAA			5000		2022-03-07 01:33:29.8408370	2022-03-07 01:41:15.6938843



-- Con “for system_time from ‘fecha’ to ‘fecha’” vemos los cambios sufridos en la tabla en un rango de fechas

select * 
from materiales 
for system_time from '2022-03-07 01:29:22.6757686' to '2022-03-07 01:33:29.8408370' 
go
--id nombre				cantidad	SysStartTime				SysEndTime
--1	Cuerda rapel		2			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--2	linternas			1			2022-03-07 01:29:46.8610454	9999-12-31 23:59:59.9999999
--3	Mantas térmicas		30			2022-03-07 01:29:36.1428604	9999-12-31 23:59:59.9999999
--4	luces químicas		1000		2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--5	mosquetones			200			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--3	Mantas térmicas		800			2022-03-07 01:29:22.6757686	2022-03-07 01:29:36.1428604
--2	linternas			50			2022-03-07 01:29:22.6757686	2022-03-07 01:29:46.8610454

-- Between es similar al anterior pero toma referencia el SysStartTime

select * 
from materiales
for system_time between '2022-03-07 01:29:22.6757686' and '2022-03-07 01:33:29.8408370'
GO

--id nombre				cantidad	SysStartTime				SysEndTime
--1	Cuerda rapel		2			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--2	linternas			1			2022-03-07 01:29:46.8610454	9999-12-31 23:59:59.9999999
--3	Mantas térmicas		30			2022-03-07 01:29:36.1428604	9999-12-31 23:59:59.9999999
--4	luces químicas		1000		2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--5	mosquetones			200			2022-03-07 01:29:22.6757686	9999-12-31 23:59:59.9999999
--3	Mantas térmicas		800			2022-03-07 01:29:22.6757686	2022-03-07 01:29:36.1428604
--2	linternas			50			2022-03-07 01:29:22.6757686	2022-03-07 01:29:46.8610454
--6	pilas AAA			5000		2022-03-07 01:33:29.8408370	2022-03-07 01:41:15.6938843


-- Con “for system_time contained in” se ven los registros que se introdujeron entre las 01:29 
-- y se cambiaron hasta las 01:33

select * 
from materiales
for system_time contained in ('2022-03-07 01:29:22.6757686','2022-03-07 01:33:29.8408370')
GO
--id nombre				cantidad	SysStartTime				SysEndTime
--3	Mantas térmicas	800	2022-03-07 01:29:22.6757686	2022-03-07 01:29:36.1428604
--2	linternas	50	2022-03-07 01:29:22.6757686	2022-03-07 01:29:46.8610454
