--VAMOS A RECONFIGURAR EL ARCHIVO DE CONFIGURACI�N PARA QUE NOS PERMITA LA CARACTER
USE MASTER
GO

--A�N NO SE ACTIVAN LAS OPCIONES AVANZADAS
EXEC SP_CONFIGURE 'show advanced options', 1
GO

--ACTUALIZAMOS EL VALOR
RECONFIGURE
GO

--ACTIVAMOS LA CARACTER�STICA
EXEC SP_CONFIGURE 'contained database authentication', 1
GO

--actualizamos de nuevo
RECONFIGURE
GO

----
---HASTA AQU� PREPARAMOS EL ENTORNO PARA LO QUE VMAOS A EJECUTAR
---

DROP DATABASE IF EXISTS Contenida_najc
GO

CREATE DATABASE Contenida_najc
CONTAINMENT=PARTIAL --ESTO ES LO QUE INDICA QUE ES CONTENIDA
GO


--UNA VEZ CREADA LA ACTIVAMOS 
USE Contenida_najc
GO

--CREAMOS UN USUARIO
DROP USER IF EXISTS jason
GO
CREATE USER jason
	WITH PASSWORD = 'abcd1234.',
	DEFAULT_SCHEMA=dbo
GO 

--en deshuso
exec sp_addrolemember 'db_owner', 'jason'
GO
--formato nuevo
ALTER ROLE db_owner
ADD MEMBER jason

--DAMOS PERMISO A JASON PARA QUE SE PUEDA CONECTAR, PORQUE LO HEMOS CREADO EN UNA BD CONTENIDA
GRANT CONNECT TO jason
GO

--nos conectamos a una nueva instacia, autenticaci�n con sqlserver, introducimos este usuario
--y nos sale un error. Para solventarlo tenemos que ir a opcipnes->additional connection parameters
--y a�adimos lo siguiente --> DATABASE=Contenida_najc
--Ahora volvemos a autenticarnos y ya nos deja entrar en nuestra nueva instancia con el usuario jason