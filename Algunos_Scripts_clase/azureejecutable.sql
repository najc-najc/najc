--versión con azuredatastudio.exe como blob
use tempdb
go
DROP TABLE IF EXISTS tbldata
GO
CREATE Table tbldata
(
    fileid int,
    filedata varbinary(max)
 )
go

INSERT INTO tbldata
( 
  fileid,filedata)  
SELECT  1, bulkcolumn  
      FROM OPENROWSET  
      ( BULK 'C:\blob\azuredatastudio.exe',SINGLE_BLOB)  as ejecutable
GO