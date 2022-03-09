drop database if exists testDB
go

create database testDB
go

use testDB
go


drop schema if exists HR
go

create schema HR;
go


drop table if exists HR.employee
go

create table HR.employee
(
employeeID char (2),
givenname varchar (50),
surname varchar (50),
ssn char (9) 
);
go

drop view if exists HR.lookupemployee
go

create view HR.lookupemployee
as
select
	employeeID,givenname,surname
	from HR.employee;
go

drop role if exists humanresourcesanalyst
go

create role humanresourcesanalyst;
go

grant select on HR.lookupemployee to humanresourcesanalyst;
go


drop user if exists janedoe
go

create user janedoe without login;
go


alter role humanresourcesanalyst
add member janedoe;
go

execute as user = 'janedoe';
go

print user 
go


select * from HR.lookupemployee;
go

select * from HR.employee;
go

revert;
go

print user 
go


create or alter procedure HR.insertnewemployee
 --parametros de entrada en variable 
	@employeeID int,
	@givenname varchar (50),
	@surname varchar (50),
	@ssn char (9)
as
begin
	insert into HR.employee
	( employeeID, givenname, surname, ssn )
	values
	( @employeeID, @givenname, @surname, @ssn);
end;
go

CREATE ROLE HumanResourcesREcruiter;
GO

GRANT EXECUTE ON SCHEMA::[HR] TO HumanResourcesREcruiter;
GO

CREATE USER JohnSmith without login;
GO

ALTER ROLE HumanResourcesREcruiter
ADD MEMBER JohnSmith;
GO

EXECUTE AS USER = 'Johnsmith';
GO

EXEC HR.InsertNewEmployee
	@EmployeeID = 4,
	@GivenName = 'Miguel',
	@SurName = 'Martinez',
	@SSN = '4444';
GO

PRINT USER
GO

SELECT * FROM Employee;
GO

SELECT * FROM HR.Employee;
GO
