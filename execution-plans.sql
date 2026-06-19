------------------------------------------------
--					   S07
------------------------------------------------
CREATE DATABASE LabClusterVsHeap;
GO
USE LabClusterVsHeap;
GO

-- 2. Tabla con índice clúster (PK en EmpleadoID)
CREATE TABLE EmpleadosClustered (
    EmpleadoID INT PRIMARY KEY,
    Nombre NVARCHAR(50)
);

-- 3. Tabla heap (sin índice clúster)
CREATE TABLE EmpleadosHeap (
    EmpleadoID INT,
    Nombre NVARCHAR(50)
);

-- 4. Insertar registros desordenados en ambas tablas
INSERT INTO EmpleadosClustered VALUES (3, 'Carlos');
INSERT INTO EmpleadosClustered VALUES (7, 'Ana');
INSERT INTO EmpleadosClustered VALUES (2, 'Luis');
INSERT INTO EmpleadosClustered VALUES (10, 'María');
INSERT INTO EmpleadosClustered VALUES (1, 'Pedro');

INSERT INTO EmpleadosHeap VALUES (3, 'Carlos');
INSERT INTO EmpleadosHeap VALUES (7, 'Ana');
INSERT INTO EmpleadosHeap VALUES (2, 'Luis');
INSERT INTO EmpleadosHeap VALUES (10, 'María');
INSERT INTO EmpleadosHeap VALUES (1, 'Pedro');

-- 5. Consultas de prueba
-- Tabla con índice clúster: devuelve ordenado por PK
SELECT * FROM EmpleadosClustered;

-- Tabla heap: devuelve en el orden físico de inserción (no garantizado)
SELECT * FROM EmpleadosHeap;

--------------------------------------------------
--------------------------------------------------
/* Clustered Index (EmpleadoID)
Código
Raíz
 └── Nodo intermedio
      ├── Hoja: EmpleadoID=1 → Fila completa
      ├── Hoja: EmpleadoID=2 → Fila completa
      ├── Hoja: EmpleadoID=3 → Fila completa
Las hojas contienen toda la fila.

Nonclustered Index (Nombre)
Código
Raíz
 └── Nodo intermedio
      ├── Hoja: Nombre='Ana' → puntero a EmpleadoID=7
      ├── Hoja: Nombre='Carlos' → puntero a EmpleadoID=3
      ├── Hoja: Nombre='Luis' → puntero a EmpleadoID=2
*/

index unique

index fulltext


------------------------------------------------
------------------------------------------------
------------------------------------------------

 -- 1. Crear base de datos y usarla
CREATE DATABASE LabEjecucionCompleto;
GO
USE LabEjecucionCompleto;
GO

-- 2. Crear tablas
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY,
    Nombre NVARCHAR(100),
    Ciudad NVARCHAR(50),
    Email NVARCHAR(100)
);

CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY,
    ClienteID INT,
    Fecha DATE,
    Monto DECIMAL(10,2),
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

-- 3. Poblar datos con más ciudades y distribución variada
INSERT INTO Clientes (ClienteID, Nombre, Ciudad, Email)
SELECT TOP 100000 
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ClienteID,
    'Cliente' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS NVARCHAR(10)),
    CASE ABS(CHECKSUM(NEWID())) % 10
        WHEN 0 THEN 'Lima'       -- muy frecuente
        WHEN 1 THEN 'Cusco'
        WHEN 2 THEN 'Arequipa'
        WHEN 3 THEN 'Trujillo'
        WHEN 4 THEN 'Tacna'      -- poco frecuente
        WHEN 5 THEN 'Piura'
        WHEN 6 THEN 'Chiclayo'
        WHEN 7 THEN 'Iquitos'
        WHEN 8 THEN 'Huancayo'
        ELSE 'Puno'              -- poco frecuente
    END,
    'cliente' + CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS NVARCHAR(10)) + '@demo.com'
FROM sys.all_objects a CROSS JOIN sys.all_objects b;

INSERT INTO Pedidos (PedidoID, ClienteID, Fecha, Monto)
SELECT TOP 300000 
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS PedidoID,
    ABS(CHECKSUM(NEWID())) % 100000 + 1,
    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, '2025-01-01'),
    CAST(RAND(CHECKSUM(NEWID())) * 1000 AS DECIMAL(10,2))
FROM sys.all_objects a CROSS JOIN sys.all_objects b;

-- 4. Crear índices adicionales
CREATE NONCLUSTERED INDEX IX_Clientes_Ciudad ON Clientes(Ciudad);
CREATE NONCLUSTERED INDEX IX_Pedidos_Fecha ON Pedidos(Fecha);

-- 5. Consultas para provocar distintos operadores
-- A. Clustered Index Seek (muy selectiva por PK)
SELECT * FROM Clientes WHERE ClienteID = 12345;

-- B. Nonclustered Index Seek (ciudad poco frecuente)b
SELECT * FROM Clientes WHERE Ciudad = 'Callao';

-- C. Nonclustered Index Scan (ciudad muy frecuente)
SELECT * FROM Clientes WHERE Ciudad = 'Lima';

-- D. Nonclustered Index Seek + Key Lookup
SELECT Nombre, Email ,Ciudad ,Email
FROM Clientes 
WHERE Ciudad = 'Callao';

-- E. Nonclustered Index Scan (consulta no sargable)
SELECT * FROM Pedidos WHERE YEAR(Fecha) = 2025;

-- F. Nested Loop Join (tabla pequeña con tabla grande)
SELECT c.Nombre, p.Monto
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE c.ClienteID < 100;

-- G. Hash Join (gran volumen de datos)
SELECT c.Nombre, p.Monto
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID;

-- H. Merge Join (tablas ordenadas)
SELECT c.Nombre, p.Monto
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
ORDER BY c.ClienteID;

-- I. Sort
SELECT * FROM Pedidos ORDER BY Fecha;

-- J. Aggregate
SELECT Ciudad, COUNT(*) AS TotalClientes
FROM Clientes
GROUP BY Ciudad;

-- 6. Actualización de estadísticas
UPDATE STATISTICS Clientes;
UPDATE STATISTICS Pedidos;


