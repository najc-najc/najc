--no se pueden concatenar (+) valores que no sean cadenas(strings)
use master
go

drop proc if exists  backup_Salvamento
go

create or alter proc  backup_Salvamento
	@path varchar(256)
as
--declarando variables
Declare @name varchar (50),--database name
	--@path varchar(256),--path for backup files
@filename varchar(256),--filename for backup
@filedate varchar(20),--use for file name
@backupcount int
create table #tempbackup
(intID int identity (1,1),
name varchar (200))
--crear la carpeta backup
--set @path = 'C:\backup\'
--includes the date in the filename
set @filedate = CONVERT(varchar(20), GETDATE(),112)--el 112 es el formato de fecha, hay muchos tipos, heos elegido este, están en la documentación.
insert into #tempbackup (name)
	select name
	from master.dbo.sysdatabases
	where name in ('salvamento')
	--where name in ('Northwind','pubs')
	--where name not in ('master','model','msdb','tempdb')
select top 1 @backupcount = intID
from #tempbackup
order by intID desc

--utilidad: solo comprobación nº de backups a realizar
print @backupcount

if ((@backupcount is not null) and (@backupcount > 0))
begin
	declare @currentbackup int
	set @currentbackup = 1
	while (@currentbackup <= @backupcount)
		begin 
			select 
				@name = name,
				@filename = @path + name + '_' + @filedate + '.bak' --unique filename
				--@filename = @path + name + '.bak' --non unique filename
				from #tempbackup
				where intid = @currentbackup
			--utilidad: solo comprobación nombre backup
			print @filename
			--does not overwrite the existing file
				backup database @name to disk = @filename
			--overwrites the existing file  (note: remove @filedate from the filename so they no longer unique)
			--backup database @name to disk = @filename with init
				set @currentbackup = @currentbackup + 1
		end
end
--utilidad: solo comprobación, mirar panel de resultados autonmérico y nombre bd
select * from #tempbackup
--
drop table #tempbackup
go

exec backup_Salvamento 'C:\backup\'
go