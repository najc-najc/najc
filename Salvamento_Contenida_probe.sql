USE [Salvamento_Contenida]
GO

Create table Rescates(
    r_id integer NOT NULL primary key,
	r_lname varchar(40) NOT NULL,
	r_fname varchar(20) NOT NULL,
); 
go
select current_user
go