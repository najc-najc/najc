--Prueba para añadir imágenes a la base de datos 
--use salvamento
--go
DROP TABLE IF EXISTS logo
go
create table logo
(
	logoid int,
	logoname varchar(255),
	logoimage varbinary(max)
)
go

--el comando bulk es para que copie la imagen
insert into logo
(
	logoid,
	logoname,
	logoimage
)
select 1, 'Salvamento',
	* from openrowset
	(bulk 'C:\salvamento\img\salvamento.jpg', single_blob) as imagefile
go

insert into logo
(
	logoid,
	logoname,
	logoimage
)
select 2, 'Protección Civil',
	* from openrowset
	(bulk 'C:\salvamento\img\protecciv.jpg', single_blob) as imagefile
go

insert into logo
(
	logoid,
	logoname,
	logoimage
)
select 3, 'Montaña',
	* from openrowset
	(bulk 'C:\salvamento\img\montana.jpg', single_blob) as imagefile
go

select * from logo
order by logoid
go