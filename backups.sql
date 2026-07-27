------------------------------------------------
--					   S14
------------------------------------------------
-- Parte 1 — Los 4 tipos de backup (diapositivas 7-13)

------------------------------------------------
-- Ejercicio 1 — Backup completo (Full Backup)
------------------------------------------------
BACKUP DATABASE Northwind
TO DISK = 'C:\BackupsNorthwind\Northwind_Full.bak'
WITH FORMAT, NAME = 'Northwind-Full Backup';

RESTORE HEADERONLY FROM DISK = 'C:\BackupsNorthwind\Northwind_Full.bak';

USE Northwind;
GO

UPDATE Products
SET UnitPrice = UnitPrice * 1.10
WHERE CategoryID = 1; -- Beverages: sube precio 10%

INSERT INTO Products (ProductName, SupplierID, CategoryID, UnitPrice, UnitsInStock)
VALUES ('Café ISIL Premium', 1, 1, 25.50, 100);

------------------------------------------------
--               Backup diferencial
------------------------------------------------
BACKUP DATABASE Northwind
TO DISK = 'C:\BackupsNorthwind\Northwind_Diff.bak'
WITH DIFFERENTIAL, NAME = 'Northwind-Differential Backup';


------------------------------------------------
-- Ejercicio 3: Backup del log de transacciones
------------------------------------------------
-- Requiere modo de recuperación `FULL`:
ALTER DATABASE Northwind SET RECOVERY FULL;

USE Northwind;
GO

BEGIN TRANSACTION;
DELETE FROM  Order_Details WHERE OrderID = 10248;  
UPDATE Customers SET ContactName = 'Ana Torres' WHERE CustomerID = 'ALFKI';
COMMIT TRANSACTION;

------------------------------------------------
--              Backup del log
------------------------------------------------
BACKUP LOG Northwind
TO DISK = 'C:\BackupsNorthwind\Northwind_Log1.trn'
WITH NAME = 'Northwind-Log Backup 1';

-- Northwind normalmente tiene un solo archivo de datos, así que primero identificamos sus archivos físicos:

SELECT name, physical_name, type_desc
FROM sys.master_files
WHERE database_id = DB_ID('Northwind');

ALTER DATABASE Northwind ADD FILEGROUP FG_Historico;

ALTER DATABASE Northwind
ADD FILE (
    NAME = 'Northwind_Historico',
    FILENAME = 'C:\BackupsNorthwind\Northwind_Historico.ndf',
    SIZE = 10MB
) TO FILEGROUP FG_Historico;

BACKUP DATABASE Northwind
FILE = 'Northwind_Historico'
TO DISK = 'C:\BackupsNorthwind\Northwind_Historico.bak';

DECLARE @path VARCHAR(256) = 'C:\BackupsNorthwind\';
DECLARE @fileName VARCHAR(256);
DECLARE @filedate VARCHAR(20) = CONVERT(VARCHAR(20), GETDATE(), 112);

SET @fileName = @path + 'Northwind_Full_' + @filedate + '.BAK';

BACKUP DATABASE Northwind
TO DISK = @fileName
WITH FORMAT;


DECLARE @name VARCHAR(50)
DECLARE @path VARCHAR(256)
DECLARE @fileName VARCHAR(256)
DECLARE @filedate VARCHAR(20)

SET @path = 'C:\BackupsNorthwind\'
SELECT @filedate = CONVERT(VARCHAR(20), GETDATE(), 112)

DECLARE db_cursor CURSOR FOR
SELECT name FROM sys.databases
WHERE name NOT IN ('master','model','msdb','tempdb')

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @name

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @fileName = @path + @name + '_' + @filedate + '.BAK'
    BACKUP DATABASE @name TO DISK = @fileName
    FETCH NEXT FROM db_cursor INTO @name
END

CLOSE db_cursor
DEALLOCATE db_cursor

------------------------------------------------
-- Error 1: El módulo SqlServer no está instalado
------------------------------------------------
-- Import-Module : No se cargó el módulo 
-- 'SqlServer' especificado porque no se encontró
-- ningún archivo de módulo válido en ningún 
-- directorio de módulo.

-- Solución (ejecutar como administrador, una sola vez por máquina):

-- PowerShell
-- Install-Module -Name SqlServer -Scope CurrentUser -AllowClobber -Force
-- Si pide confirmar un repositorio no 
-- confiable (NuGet), aceptar con `S` o `Y`.
 
------------------------------------------------
-- Error 2: La ejecución de scripts está deshabilitada
------------------------------------------------
-- Import-Module : No se puede cargar el archivo ...SqlServer\...\SqlNotebook.psm1
-- porque la ejecución de scripts está deshabilitada en este sistema.

-- Solución:

-- PowerShell
-- Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

-- Confirmar con `S` (Sí) cuando lo pida.

-- PowerShell
-- Get-Module -ListAvailable -Name SqlServer   # debe listar la versión instalada
-- Get-ExecutionPolicy -List                   # CurrentUser debe mostrar RemoteSigned o menos restrictivo
-- Import-Module SqlServer                     # no debe mostrar ningún error

------------------------------------------------
-- Ejercicio 8: Backup simple con el cmdlet nativo
------------------------------------------------
-- PowerShell
-- Import-Module SqlServer

-- $ServerInstance = "localhost"
-- $DatabaseName   = "Northwind"
-- $BackupFile     = "C:\BackupsNorthwind\Northwind_PS.bak"

-- Backup-SqlDatabase -ServerInstance $ServerInstance -Database $DatabaseName -BackupFile $BackupFile
-- Write-Host "Backup de Northwind completado."

------------------------------------------------
-- Ejercicio 9: Backup con timestamp y carpeta 
-- de archivo histórico (adaptado de la diapositiva 31)
------------------------------------------------
-- PowerShell
-- Import-Module SqlServer

-- $ServerInstance = "localhost"
-- $DatabaseName   = "Northwind"
--       = "C:\BackupsNorthwind"
--      = "C:\BackupsNorthwind\Archive"
-- $Timestamp      = Get-Date -Format "yyyyMMdd_HHmmss" C  
-- $BackupFile     = "$BackupDir\${DatabaseName}_$Timestamp.bak"

-- if (!(Test-Path $BackupDir))  { New-Item -ItemType Directory -Path $BackupDir }
-- if (!(Test-Path $ArchiveDir)) { New-Item -ItemType Directory -Path $ArchiveDir }

-- Backup-SqlDatabase -ServerInstance $ServerInstance -Database $DatabaseName -BackupFile $BackupFile
-- Write-Host "Backup de $DatabaseName completado: $BackupFile"

-- Reto: agreguen una línea que elimine automáticamente 
-- los backups con más de 7 días de antigüedad en 
-- `$BackupDir` (pista: `Get-ChildItem` + `Where-Object` + `Remove-Item`).

------------------------------------------------
-- Ejercicio 10:Script PowerShell que respalda 
-- varias bases en un solo bucle
------------------------------------------------
-- PowerShell
-- Import-Module SqlServer

-- $ServerInstance = "localhost"
-- $BackupDir      = "C:\BackupsNorthwind"
-- $Timestamp      = Get-Date -Format "yyyyMMdd_HHmmss"

-- $databases = Get-SqlDatabase -ServerInstance $ServerInstance |
--     Where-Object { $_.Name -notin @('master','model','msdb','tempdb') }

-- foreach ($db in $databases) {
--     $BackupFile = "$BackupDir\$($db.Name)_$Timestamp.bak"
--     Backup-SqlDatabase -ServerInstance $ServerInstance -Database $db.Name -BackupFile $BackupFile
--     Write-Host "Backup completado: $($db.Name)"
-- }

-- En vez de usar el asistente gráfico, se puede crear un 
-- job directamente por T-SQL. Ejemplo que ejecuta un 
-- full backup de Northwind todos los días a la 1:00 a.m.:
USE msdb;
GO

EXEC dbo.sp_add_job
    @job_name = N'Backup_Full_Northwind';

EXEC sp_add_jobstep
    @job_name = N'Backup_Full_Northwind',
    @step_name = N'Ejecutar full backup',
    @subsystem = N'TSQL',
    @command = N'BACKUP DATABASE Northwind TO DISK = ''C:\BackupsNorthwind\Northwind_Job.bak'' WITH FORMAT';

EXEC sp_add_schedule
    @schedule_name = N'Diario_1am',
    @freq_type = 4,          -- diario
    @freq_interval = 1,
    @active_start_time = 010000;

EXEC sp_attach_schedule
    @job_name = N'Backup_Full_Northwind',
    @schedule_name = N'Diario_1am';

EXEC sp_add_jobserver
    @job_name = N'Backup_Full_Northwind';
