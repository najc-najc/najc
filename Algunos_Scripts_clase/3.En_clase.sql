--include actual execution plan
use adventureworks2019
go

Select *
	from [HumanResources].[Employee]
Go
--Define los atributos de un cursor, como su comportamiento de desplazamiento
--y la consulta utilizada para generar el conjunto de resultados sobre el que opera el cursor.
--VAMOS A CREAR UN CURSOR, LE PONEMOS EL NOMBRE Y LE INDICAMOS DE DÓNDE QUEREMOS QUE TOME LOS DATOS
declare Employee_Cursor CURSOR FOR 
	SELECT BusinessEntityID, JobTitle
	FROM AdventureWorks2019.HumanResources.Employee;
--"ABRIMOS" EL CURSOR QUE HEMOS CREADO 
OPEN Employee_Cursor;
--FETCH Recupera una fila específica, EN ESTE CASO VA A RECUPEREAR EL CURSOR QUE HEMOS CREADO 
FETCH NEXT FROM Employee_Cursor;
--@@FETCH_STATUS es una función que devuelve el estado de la última instrucción FETCH del cursor 
--emitida contra cualquier cursor abierto actualmente por la conexión.
--En este ejemplo se usa @@FETCH_STATUS para controlar las actividades del cursor en un bucle WHILE.
WHILE @@FETCH_STATUS = 0
	BEGIN
		FETCH NEXT FROM Employee_Cursor
	END;
--tenemos que cerrar el cursor ya que hemos usado la variable global @@FETCH
--si no lo hacemos la siguiente vez que usemos FETCH va a devolver lo que tiene en @@FETCH
CLOSE Employee_Cursor;
DEALLOCATE Employee_Cursor;
GO


https://docs.microsoft.com/es-es/sql/t-sql/language-elements/declare-cursor-transact-sql?view=sql-server-ver15
