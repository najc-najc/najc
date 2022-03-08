-- Generado por Oracle SQL Developer Data Modeler 20.3.0.283.0710
--   en:        2022-03-05 23:40:09 CET
--   sitio:      SQL Server 2012
--   tipo:      SQL Server 2012



CREATE TABLE Actuaciones 
    (
     id_act INTEGER NOT NULL , 
     Fecha_inicio DATETIME NOT NULL , 
     Fecha_fin DATETIME NOT NULL , 
     Localidad_id_Loc INTEGER NOT NULL , 
     Persona_Rescatada_id_persona INTEGER NOT NULL , 
     Cobertura BIT , 
     Vehiculo_id_Veh INTEGER NOT NULL 
    )
GO 

    


CREATE UNIQUE NONCLUSTERED INDEX 
    Actuaciones__IDX ON Actuaciones 
    ( 
     Localidad_id_Loc 
    ) 
GO

ALTER TABLE Actuaciones ADD CONSTRAINT Actuaciones_PK PRIMARY KEY CLUSTERED (id_act)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE CCAA 
    (
     id_CCAA INTEGER NOT NULL , 
     Nombre VARCHAR (50) NOT NULL 
    )
GO

ALTER TABLE CCAA ADD CONSTRAINT CCAA_PK PRIMARY KEY CLUSTERED (id_CCAA)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Empleado 
    (
     id_Personal INTEGER NOT NULL , 
     Localidad_id_Loc INTEGER NOT NULL , 
     En_activo BIT NOT NULL , 
     DNI NVARCHAR (9) NOT NULL , 
     Nombre VARCHAR (50) NOT NULL , 
     Apellido VARCHAR (50) NOT NULL , 
     Apellido2 VARCHAR (50) NOT NULL , 
     Cuerpo VARCHAR (50) NOT NULL , 
     Especialidad VARCHAR (50) , 
     Observaciones VARCHAR (200) 
    )
GO

ALTER TABLE Empleado ADD CONSTRAINT Empleado_PK PRIMARY KEY CLUSTERED (id_Personal)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Inventario_total 
    (
     id_inv_total INTEGER NOT NULL , 
     Vehiculo_id_Veh INTEGER NOT NULL , 
     Cant_veh NUMERIC (4) NOT NULL , 
     Material_id_material INTEGER NOT NULL , 
     Material_Cantidad NUMERIC (4) NOT NULL , 
     Material_Nombre_material VARCHAR (50) NOT NULL , 
     Fecha_inv_tot DATETIME NOT NULL 
    )
GO 

    


CREATE UNIQUE NONCLUSTERED INDEX 
    Inventario_total__IDX ON Inventario_total 
    ( 
     Vehiculo_id_Veh 
    ) 
GO 


CREATE UNIQUE NONCLUSTERED INDEX 
    Inventario_total__IDXv1 ON Inventario_total 
    ( 
     Material_id_material , 
     Material_Cantidad , 
     Material_Nombre_material 
    ) 
GO

ALTER TABLE Inventario_total ADD CONSTRAINT Inventario_total_PK PRIMARY KEY CLUSTERED (id_inv_total)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Inventario_Veh 
    (
     Vehiculo_id_Veh INTEGER NOT NULL , 
     Material_id_material INTEGER NOT NULL , 
     fecha DATETIME NOT NULL , 
     Material_Cantidad NUMERIC (4) NOT NULL , 
     Material_Nombre_material VARCHAR (50) NOT NULL 
    )
GO 

    


CREATE UNIQUE NONCLUSTERED INDEX 
    Inventario_Veh__IDX ON Inventario_Veh 
    ( 
     Vehiculo_id_Veh 
    ) 
GO

ALTER TABLE Inventario_Veh ADD CONSTRAINT Inventario_Veh_PK PRIMARY KEY CLUSTERED (fecha)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Localidad 
    (
     Provincia_id_Prov INTEGER NOT NULL , 
     id_Loc INTEGER NOT NULL , 
     Nombre VARCHAR (50) NOT NULL 
    )
GO

ALTER TABLE Localidad ADD CONSTRAINT Localidad_PK PRIMARY KEY CLUSTERED (id_Loc)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Material 
    (
     id_material INTEGER NOT NULL , 
     Nombre_material VARCHAR (50) NOT NULL , 
     Cantidad NUMERIC (4) NOT NULL , 
     observaciones VARCHAR (200) 
    )
GO

ALTER TABLE Material ADD CONSTRAINT Material_PK PRIMARY KEY CLUSTERED (id_material, Cantidad, Nombre_material)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Part_act 
    (
     Actuaciones_id_act INTEGER NOT NULL , 
     Empleado_id_Personal INTEGER NOT NULL 
    )
GO

CREATE TABLE Persona_Rescatada 
    (
     id_persona INTEGER NOT NULL , 
     Nombre VARCHAR (50) NOT NULL , 
     Apellido1 VARCHAR (50) NOT NULL , 
     Apellido2 VARCHAR (50) NOT NULL , 
     Nacionalidad VARCHAR (50) NOT NULL 
    )
GO

ALTER TABLE Persona_Rescatada ADD CONSTRAINT Persona_Rescatada_PK PRIMARY KEY CLUSTERED (id_persona)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Provincia 
    (
     CCAA_id_CCAA INTEGER NOT NULL , 
     id_Prov INTEGER NOT NULL , 
     Nombre VARCHAR (50) NOT NULL 
    )
GO

ALTER TABLE Provincia ADD CONSTRAINT Provincia_PK PRIMARY KEY CLUSTERED (id_Prov)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Vehiculo 
    (
     id_Veh INTEGER NOT NULL , 
     Cod_veh VARCHAR (10) NOT NULL , 
     Nombre VARCHAR (50) NOT NULL , 
     Capacidad_min NUMERIC (2) NOT NULL , 
     Capacidad_max NUMERIC (4) NOT NULL , 
     Observaciones VARCHAR (200) , 
     Localidad_id_Loc INTEGER NOT NULL 
    )
GO

ALTER TABLE Vehiculo ADD CONSTRAINT Vehiculo_PK PRIMARY KEY CLUSTERED (id_Veh)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

ALTER TABLE Actuaciones 
    ADD CONSTRAINT Actuaciones_Localidad_FK FOREIGN KEY 
    ( 
     Localidad_id_Loc
    ) 
    REFERENCES Localidad 
    ( 
     id_Loc 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Actuaciones 
    ADD CONSTRAINT Actuaciones_Persona_Rescatada_FK FOREIGN KEY 
    ( 
     Persona_Rescatada_id_persona
    ) 
    REFERENCES Persona_Rescatada 
    ( 
     id_persona 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Actuaciones 
    ADD CONSTRAINT Actuaciones_Vehiculo_FK FOREIGN KEY 
    ( 
     Vehiculo_id_Veh
    ) 
    REFERENCES Vehiculo 
    ( 
     id_Veh 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Empleado 
    ADD CONSTRAINT Empleado_Localidad_FK FOREIGN KEY 
    ( 
     Localidad_id_Loc
    ) 
    REFERENCES Localidad 
    ( 
     id_Loc 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Inventario_total 
    ADD CONSTRAINT Inventario_total_Material_FK FOREIGN KEY 
    ( 
     Material_id_material, 
     Material_Cantidad, 
     Material_Nombre_material
    ) 
    REFERENCES Material 
    ( 
     id_material , 
     Cantidad , 
     Nombre_material 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Inventario_total 
    ADD CONSTRAINT Inventario_total_Vehiculo_FK FOREIGN KEY 
    ( 
     Vehiculo_id_Veh
    ) 
    REFERENCES Vehiculo 
    ( 
     id_Veh 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Inventario_Veh 
    ADD CONSTRAINT Inventario_Veh_Material_FK FOREIGN KEY 
    ( 
     Material_id_material, 
     Material_Cantidad, 
     Material_Nombre_material
    ) 
    REFERENCES Material 
    ( 
     id_material , 
     Cantidad , 
     Nombre_material 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Inventario_Veh 
    ADD CONSTRAINT Inventario_Veh_Vehiculo_FK FOREIGN KEY 
    ( 
     Vehiculo_id_Veh
    ) 
    REFERENCES Vehiculo 
    ( 
     id_Veh 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Localidad 
    ADD CONSTRAINT Localidad_Provincia_FK FOREIGN KEY 
    ( 
     Provincia_id_Prov
    ) 
    REFERENCES Provincia 
    ( 
     id_Prov 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Part_act 
    ADD CONSTRAINT Part_act_Actuaciones_FK FOREIGN KEY 
    ( 
     Actuaciones_id_act
    ) 
    REFERENCES Actuaciones 
    ( 
     id_act 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Part_act 
    ADD CONSTRAINT Part_act_Empleado_FK FOREIGN KEY 
    ( 
     Empleado_id_Personal
    ) 
    REFERENCES Empleado 
    ( 
     id_Personal 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Provincia 
    ADD CONSTRAINT Provincia_CCAA_FK FOREIGN KEY 
    ( 
     CCAA_id_CCAA
    ) 
    REFERENCES CCAA 
    ( 
     id_CCAA 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Vehiculo 
    ADD CONSTRAINT Vehiculo_Localidad_FK FOREIGN KEY 
    ( 
     Localidad_id_Loc
    ) 
    REFERENCES Localidad 
    ( 
     id_Loc 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            11
-- CREATE INDEX                             4
-- ALTER TABLE                             23
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE DATABASE                          0
-- CREATE DEFAULT                           0
-- CREATE INDEX ON VIEW                     0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE ROLE                              0
-- CREATE RULE                              0
-- CREATE SCHEMA                            0
-- CREATE SEQUENCE                          0
-- CREATE PARTITION FUNCTION                0
-- CREATE PARTITION SCHEME                  0
-- 
-- DROP DATABASE                            0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
