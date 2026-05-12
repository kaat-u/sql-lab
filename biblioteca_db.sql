USE Master
GO
CREATE DATABASE Biblioteca
ON PRIMARY
(
    NAME = Biblio_Dat,
    FILENAME = 'C:\compartir\Biblio_Dat.mdf',
    SIZE = 5MB,
    MAXSIZE = 200,
    FILEGROWTH = 1
)
LOG ON
(
    NAME = Biblio_Log,
    FILENAME = 'C:\compartir\Biblio_Log.ldf',
    SIZE = 1MB,
    MAXSIZE = 200,
    FILEGROWTH = 1MB
)
GO

----------------------------------------------
----------------------------------------------

USE Biblioteca
GO

-- Creando la tabla Juvenil
CREATE TABLE JUVENIL
(
  NumeroSocio      INT       NOT NULL,
  NumMiembroAdulto INT       NOT NULL,
  FechaNac         DATETIME  NOT NULL
)
GO

-- Creando la tabla Miembros
CREATE TABLE Miembros
(
  NroMiembro INT IDENTITY(1,1) NOT NULL,
  Apellidos  VARCHAR(20)       NOT NULL,
  Nombres    VARCHAR(20)       NOT NULL,
  Iniciales  CHAR(1)           NULL
)
GO

----------------------------------------------
----------------------------------------------

-- 1. Crear la tabla Socio
USE Biblioteca
GO
CREATE TABLE Socio
(
  IdSocio   INT NOT NULL,
  Nombres   VARCHAR(20) NOT NULL,
  Apellidos VARCHAR(30) NOT NULL
)
GO

-- 2. Verificar la existencia de la tabla Socio
SELECT table_name
FROM information_schema.tables
WHERE table_name = 'Socio'
GO

-- 3. Eliminar la tabla Socio
DROP TABLE Socio
GO

-- 4. Repetir la verificación para confirmar que la tabla ya no existe
SELECT table_name
FROM information_schema.tables
WHERE table_name = 'Socio'
GO


------------------------------------------------
--                   pag 21
------------------------------------------------

-- 1. Agregar una nueva columna a la tabla Miembros
ALTER TABLE Miembros
ADD Edad TINYINT NULL
GO

-- 2. Observar las propiedades de la tabla Miembros
SP_HELP Miembros
GO


------------------------------------------------
--                   pag 22
------------------------------------------------

-- 1. Eliminar la columna Edad de la tabla Miembros
ALTER TABLE Miembros
DROP COLUMN Edad
GO

-- 2. Observar las propiedades de la tabla Miembros
SP_HELP Miembros
GO


------------------------------------------------
--                   pag 29
------------------------------------------------

-- 1. Añadir un campo a la tabla Miembros
USE Biblioteca
GO
ALTER TABLE Miembros
    ADD Departamento CHAR(2) NULL
GO

-- 2. Observar las propiedades de la tabla Miembros
SP_HELP Miembros
GO

-- 3. Definir un constraint DEFAULT para el campo Departamento
ALTER TABLE Miembros
    ADD CONSTRAINT DepartInicial DEFAULT 'LI' FOR Departamento
GO

-- Verificar los constraints de la tabla Miembros
SP_HELPCONSTRAINT Miembros
GO


------------------------------------------------
--                   pag 30
------------------------------------------------

-- 1. Añadir un campo Teléfono a la tabla Miembros
ALTER TABLE Miembros
    ADD Telefono VARCHAR(13) NULL
GO

-- 2. Crear el constraint CHECK para validar el formato del teléfono
ALTER TABLE Miembros
    ADD CONSTRAINT ReglaTelefono
    CHECK (Telefono LIKE '(206)[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
GO

-- 3. Verificar los constraints de la tabla Miembros
SP_HELPCONSTRAINT Miembros
GO


------------------------------------------------
--                   pag 31
------------------------------------------------

-- 1. Crear la tabla Editorial y agregar registros
CREATE TABLE Editorial
(
  IdEditorial INT IDENTITY(1,1) NOT NULL,
  NomEdit     VARCHAR(20)       NOT NULL
)
GO

-- Insertar registros
INSERT INTO Editorial VALUES('AMAZONAS')
GO
INSERT INTO Editorial VALUES('ALGODATA')
GO

-- Consultar registros
SELECT * FROM Editorial
GO

-- 2. Agregar constraint UNIQUE sobre el campo NomEdit
ALTER TABLE Editorial
ADD CONSTRAINT u_Nombre UNIQUE (NomEdit)
GO

-- Verificar los constraints de la tabla Editorial
SP_HELPCONSTRAINT Editorial
GO


------------------------------------------------
--                   pag 32
------------------------------------------------

-- 1. Crear la base de datos y las tablas con integridad referencial en cascada
USE MASTER
GO
CREATE DATABASE Prueba_2
GO
USE Prueba_2
GO

CREATE TABLE CLIENTE2
(
  CLICOD CHAR(2) PRIMARY KEY,
  CLINOM VARCHAR(20)
)
GO

CREATE TABLE PEDIDO2
(
  PEDCOD   CHAR(3) PRIMARY KEY,
  PEDFECHA DATETIME DEFAULT GETDATE(),
  CLICOD   CHAR(2) FOREIGN KEY REFERENCES CLIENTE2(CLICOD)
           ON DELETE CASCADE
           ON UPDATE CASCADE
)
GO

-- 2. Insertar registros en CLIENTE2
INSERT INTO CLIENTE2 VALUES('01','JOEL CARRASCO')
INSERT INTO CLIENTE2 VALUES('02','CESAR QUISPE')
INSERT INTO CLIENTE2 VALUES('03','RAUL CHUCO')
INSERT INTO CLIENTE2 VALUES('04','CESAR GUERRA')
INSERT INTO CLIENTE2 VALUES('05','GUSTAVO CORONEL')
GO

-- Insertar registros en PEDIDO2
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P01','01')
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P02','01')
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P03','02')
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P04','02')
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P05','02')
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P06','03')
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P07','03')
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P08','03')
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P09','04')
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P10','04')
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P11','05')
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P12','02')
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P13','01')
INSERT INTO PEDIDO2 (PEDCOD,CLICOD) VALUES('P14','01')
GO

-- 3. Consultar los registros
SELECT * FROM CLIENTE2
SELECT * FROM PEDIDO2
GO


------------------------------------------------
--                   pag 35
------------------------------------------------

-- Probando el constraint DEFAULT, añadiendo datos

-- Insertando un registro con todos los campos
INSERT INTO Miembros (Apellidos, Nombres, Iniciales, Departamento)
    VALUES ('CARRASCO','JOEL','A','SM')
GO

-- Insertando registros sin especificar el campo Departamento
-- Aquí se aplicará el valor por defecto definido en el constraint
INSERT INTO Miembros (Nombres, Apellidos)
    VALUES ('GUSTAVO','CORONEL')
GO

INSERT INTO Miembros (Nombres, Apellidos)
    VALUES ('MATSUKAWA','SERGIO')
GO

-- Consultar los registros para verificar el valor por defecto
SELECT * FROM Miembros
GO


------------------------------------------------
--                   pag 36
------------------------------------------------

-- 1. Intento de inserción que no cumple el constraint CHECK
INSERT INTO Miembros (Nombres, Apellidos, Telefono)
VALUES ('PEDRO', 'DIAS', '5227812')
GO

-- 2. Inserción válida que cumple el constraint CHECK
INSERT INTO Miembros (Nombres, Apellidos, Telefono)
VALUES ('PEDRO', 'DIAS', '(206)52-7812')
GO

-- Consultar los registros para verificar
SELECT * FROM Miembros
GO


------------------------------------------------
--                   pag 37
------------------------------------------------



-- Probando el constraint UNIQUE
-- Intento de insertar un valor duplicado en NomEdit
INSERT INTO Editorial VALUES('Amazonas')
GO

-- Este intento generará un error por violación del constraint UNIQUE:
-- Msg 2627, Level 14, State 1
-- Violation of UNIQUE KEY constraint 'u_Nombre'.
-- Cannot insert duplicate key in object 'dbo.Editorial'.
-- The statement has been terminated.


------------------------------------------------
--                   pag 38
------------------------------------------------ 

-- 1. Actualizar el código de un cliente en la tabla CLIENTE2
-- El cliente con CLICOD = '01' será cambiado a '29'
UPDATE CLIENTE2
SET CLICOD = '29'
WHERE CLICOD = '01'
GO

-- 2. Consultar los registros para verificar la actualización
SELECT * FROM CLIENTE2
SELECT * FROM PEDIDO2
GO


------------------------------------------------
--                   pag 39
------------------------------------------------

-- 1. Eliminar el cliente con código 29 en la tabla CLIENTE2
DELETE FROM CLIENTE2
WHERE CLICOD = '29'
GO

-- 2. Consultar los registros para verificar la eliminación
SELECT * FROM CLIENTE2
SELECT * FROM PEDIDO2
GO

------------------------------------------------
------------------------------------------------