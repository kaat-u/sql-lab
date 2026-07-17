------------------------------------------------
--					   S13
------------------------------------------------

-- 1. Sergio se conecta al servidor con su LOGIN único
-- (Esto le da acceso al motor completo)
CREATE LOGIN sergio WITH PASSWORD = 'ClaveSegura123!';
GO

-- 2. Configuración para la Base de Datos "Produccion" (Poder Máximo)
USE Produccion;
CREATE USER UserSergioProduccion FOR LOGIN sergio;
-- Lo volvemos el dueño absoluto de esta base de datos:
ALTER ROLE db_owner ADD MEMBER UserSergioProduccion; 
GO

-- 3. Configuración para la Base de Datos "Personal" (Acceso Limitado)
USE Personal;
CREATE USER registrador FOR LOGIN sergio;
-- Solo le damos permiso para leer datos, no puede borrar nada:
ALTER ROLE db_datareader ADD MEMBER registrador; 
GO

-- =========================================================================
-- PASO 1: EL INGRESO AL EDIFICIO (Crear el LOGIN para el Auditor Externo)
-- =========================================================================
USE master;
GO

-- Creamos la credencial para que el auditor pueda conectarse al servidor
CREATE LOGIN login_auditor WITH PASSWORD = 'AuditoriaSegura2026!';
GO

-- =========================================================================
-- PASO 2: EL INGRESO A LA CASA (Crear el USER dentro de la Base de Datos)
-- =========================================================================
USE Northwind;
GO

-- Vinculamos ese login a un usuario interno dentro de Northwind
CREATE USER usuario_auditor FOR LOGIN login_auditor;
GO

-- =========================================================================
-- PASO 3: CREAR LA BOLSA DE PERMISOS (Crear el ROL de Auditoría)
-- =========================================================================
-- Creamos un rol personalizado exclusivo para el equipo de revisión
CREATE ROLE RolAuditoresNorthwind;
GO

-- =========================================================================
-- PASO 4: ASIGNAR PODERES AL ROL (Solo lectura en tablas críticas)
-- =========================================================================
-- Un auditor solo debe consultar (SELECT). Le damos acceso a Empleados y Clientes.
-- Nota que NO le estamos dando permisos de INSERT, UPDATE ni DELETE.
GRANT SELECT ON OBJECT::dbo.Employees TO RolAuditoresNorthwind;
GRANT SELECT ON OBJECT::dbo.Customers TO RolAuditoresNorthwind;
GO


-- =========================================================================
-- PASO 5: METER AL USUARIO EN LA BOLSA (Vincular Usuario al Rol)
-- =========================================================================
-- El usuario auditor hereda de inmediato la política de solo lectura
ALTER ROLE RolAuditoresNorthwind ADD MEMBER usuario_auditor;
GO

------------------------------------------------
--               Backup de llaves 
------------------------------------------------
USE Northwind;
GO

-- Exportamos el certificado y su llave privada a archivos físicos independientes
BACKUP CERTIFICATE CertificadoRaizNorthwind  
TO FILE = 'C:\Backups\CertificadoPublico.cer'  
WITH PRIVATE KEY (  
    FILE = 'C:\Backups\LlavePrivadaSecreta.pvk',  
    ENCRYPTION BY PASSWORD = 'ClaveDelRespaldo2026!' -- Contraseña para blindar el archivo exportado
);
GO

------------------------------------------------
--                  Restauración
------------------------------------------------

USE Northwind;
GO

-- Recreamos el certificado importándolo desde la ubicación segura externa
CREATE CERTIFICATE CertificadoRaizNorthwind  
FROM FILE = 'C:\Backups\CertificadoPublico.cer'  
WITH PRIVATE KEY (  
    FILE = 'C:\Backups\LlavePrivadaSecreta.pvk',  
    DECRYPTION BY PASSWORD = 'ClaveDelRespaldo2026!' -- La misma contraseña con la que lo blindamos
);
GO




