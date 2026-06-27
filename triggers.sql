------------------------------------------------
--					   S11
------------------------------------------------
USE Northwind

------------------------------------------------
--      1. CREACIÓN DE TABLAS DE AUDITORÍA
------------------------------------------------
-- Auditoría de pedidos
CREATE TABLE OrderAudit (
    AuditID INT IDENTITY PRIMARY KEY,
    OrderID INT NOT NULL,
    Action NVARCHAR(20),
    AuditDate DATETIME
);

-- Cambios de precio
CREATE TABLE PriceChanges (
    ChangeID INT IDENTITY PRIMARY KEY,
    ProductID INT NOT NULL,
    OldPrice MONEY,
    NewPrice MONEY,
    ChangeDate DATETIME
);

-- Eliminaciones de productos
CREATE TABLE ProductDeletions (
    DeletionID INT IDENTITY PRIMARY KEY,
    ProductID INT NOT NULL,
    ProductName NVARCHAR(40),
    DeletionDate DATETIME
);

-- Auditoría de publishers (Northwind tiene Suppliers, usamos esa tabla)
CREATE TABLE SupplierAudit (
    AuditID INT IDENTITY PRIMARY KEY,
    SupplierID INT,
    Action NVARCHAR(50),
    AuditDate DATETIME
);

GO

------------------------------------------------
--      2. CREACIÓN DE TRIGGERS AFTER
------------------------------------------------
-- AFTER INSERT en Orders
CREATE TRIGGER trg_OrderInsert
ON Orders
AFTER INSERT
AS
BEGIN
    PRINT 'Trigger AFTER INSERT ejecutado';
    INSERT INTO OrderAudit (OrderID, Action, AuditDate)
    SELECT OrderID, 'INSERT', GETDATE()
    FROM inserted;
END;
GO

-- AFTER UPDATE en Products
CREATE TRIGGER trg_PriceUpdate
ON Products
AFTER UPDATE
AS
BEGIN
    PRINT 'Trigger AFTER UPDATE ejecutado';
    INSERT INTO PriceChanges (ProductID, OldPrice, NewPrice, ChangeDate)
    SELECT d.ProductID, d.UnitPrice, i.UnitPrice, GETDATE()
    FROM deleted d
    INNER JOIN inserted i ON d.ProductID = i.ProductID;
END;
GO

-- AFTER DELETE en Products
CREATE TRIGGER trg_ProductDelete
ON Products
AFTER DELETE
AS
BEGIN
    PRINT 'Trigger AFTER DELETE ejecutado';
    INSERT INTO ProductDeletions (ProductID, ProductName, DeletionDate)
    SELECT ProductID, ProductName, GETDATE()
    FROM deleted;
END;
GO

------------------------------------------------
--      3. CREACIÓN DE TRIGGERS INSTEAD OF
------------------------------------------------
-- INSTEAD OF INSERT en Customers
CREATE TRIGGER trg_CustomerInsert
ON Customers
INSTEAD OF INSERT
AS
BEGIN
    PRINT 'Trigger INSTEAD OF INSERT ejecutado';
    -- Inserta manualmente los datos
    INSERT INTO Customers (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
    SELECT CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax
    FROM inserted;
END;
GO

-- INSTEAD OF UPDATE en Products
CREATE TRIGGER trg_ProductUpdate
ON Products
INSTEAD OF UPDATE
AS
BEGIN
    PRINT 'Trigger INSTEAD OF UPDATE ejecutado';
    UPDATE Products
    SET UnitPrice = i.UnitPrice
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO

-- INSTEAD OF DELETE en Suppliers
CREATE TRIGGER trg_SupplierDelete
ON Suppliers
INSTEAD OF DELETE
AS
BEGIN
    PRINT 'Trigger INSTEAD OF DELETE ejecutado';
    INSERT INTO SupplierAudit (SupplierID, Action, AuditDate)
    SELECT SupplierID, 'DELETE BLOQUEADO', GETDATE()
    FROM deleted;
END;
GO

------------------------------------------------
--      4. EJECUCIONES DE PRUEBA
------------------------------------------------
-- AFTER INSERT
INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, ShipVia)
VALUES ('ALFKI', 5, GETDATE(), 1);
SELECT * FROM OrderAudit;

-- AFTER UPDATE
UPDATE Products SET UnitPrice = UnitPrice - 1 WHERE ProductID = 1;
SELECT * FROM PriceChanges;

-- AFTER DELETE
DELETE FROM Products WHERE ProductID = 2;
SELECT * FROM ProductDeletions;

-- INSTEAD OF INSERT
INSERT INTO Customers (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
VALUES ('ZZZZZ', 'Nueva Empresa', 'Carlos Perez', 'Gerente', 'Av. Siempre Viva 123', 'Lima', NULL, '99999', 'Peru', '555-9999', NULL);
SELECT * FROM Customers WHERE CustomerID = 'ZZZZZ';

-- INSTEAD OF UPDATE
UPDATE Products SET UnitPrice = UnitPrice + 5 WHERE ProductID = 3;
SELECT ProductID, UnitPrice FROM Products WHERE ProductID = 3;

-- INSTEAD OF DELETE
DELETE FROM Suppliers WHERE SupplierID = 1;
SELECT * FROM SupplierAudit WHERE SupplierID = 1;

------------------------------------------------
--  1. CREACIÓN DE TABLAS DE AUDITORÍA (INTERMEDIO)
------------------------------------------------

-- Auditoría de pedidos (intermedio)
CREATE TABLE OrderAudit_Int (
    AuditID INT IDENTITY PRIMARY KEY,
    OrderID INT NOT NULL,
    Action NVARCHAR(20),
    AuditDate DATETIME
);

-- Cambios de precio (intermedio)
CREATE TABLE PriceChanges_Int (
    ChangeID INT IDENTITY PRIMARY KEY,
    ProductID INT NOT NULL,
    OldPrice MONEY,
    NewPrice MONEY,
    ChangeDate DATETIME
);

-- Eliminaciones de productos (intermedio)
CREATE TABLE ProductDeletions_Int (
    DeletionID INT IDENTITY PRIMARY KEY,
    ProductID INT NOT NULL,
    ProductName NVARCHAR(40),
    DeletionDate DATETIME
);

-- Auditoría de suppliers (intermedio)
CREATE TABLE SupplierAudit_Int (
    AuditID INT IDENTITY PRIMARY KEY,
    SupplierID INT,
    Action NVARCHAR(50),
    AuditDate DATETIME
);

GO

------------------------------------------------
--  2. TRIGGERS AFTER CON VALIDACIONES (INTERMEDIO)
------------------------------------------------

-- AFTER INSERT en Orders
CREATE TRIGGER trg_OrderInsert_Int
ON Orders
AFTER INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE CustomerID IS NULL)
    BEGIN
        PRINT 'No se permite insertar pedidos sin cliente';
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    PRINT 'Trigger AFTER INSERT (intermedio) ejecutado';
    INSERT INTO OrderAudit_Int (OrderID, Action, AuditDate)
    SELECT OrderID, 'INSERT', GETDATE()
    FROM inserted;
END;
GO

-- AFTER UPDATE en Products
CREATE TRIGGER trg_PriceUpdate_Int
ON Products
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE UnitPrice <= 0)
    BEGIN
        PRINT 'El precio debe ser mayor a 0';
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    PRINT 'Trigger AFTER UPDATE (intermedio) ejecutado';
    INSERT INTO PriceChanges_Int (ProductID, OldPrice, NewPrice, ChangeDate)
    SELECT d.ProductID, d.UnitPrice, i.UnitPrice, GETDATE()
    FROM deleted d
    INNER JOIN inserted i ON d.ProductID = i.ProductID;
END;
GO

-- AFTER DELETE en Products
CREATE TRIGGER trg_ProductDelete_Int
ON Products
AFTER DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM deleted WHERE UnitsInStock > 0)
    BEGIN
        PRINT 'No se pueden eliminar productos con stock disponible';
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    PRINT 'Trigger AFTER DELETE (intermedio) ejecutado';
    INSERT INTO ProductDeletions_Int (ProductID, ProductName, DeletionDate)
    SELECT ProductID, ProductName, GETDATE()
    FROM deleted;
END;
GO

------------------------------------------------
--  3. TRIGGERS INSTEAD OF CON VALIDACIONES (INTERMEDIO)
------------------------------------------------

-- INSTEAD OF INSERT en Customers
CREATE TRIGGER trg_CustomerInsert_Int
ON Customers
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE CompanyName IS NULL)
    BEGIN
        PRINT 'No se permite insertar clientes sin nombre de empresa';
        RETURN;
    END;

    PRINT 'Trigger INSTEAD OF INSERT (intermedio) ejecutado';
    INSERT INTO Customers (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
    SELECT CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax
    FROM inserted;
END;
GO

-- INSTEAD OF UPDATE en Products
CREATE TRIGGER trg_ProductUpdate_Int
ON Products
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE Products
    SET UnitPrice = i.UnitPrice
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID
    WHERE i.UnitPrice < p.UnitPrice;

    IF EXISTS (
        SELECT * FROM inserted i
        INNER JOIN Products p ON i.ProductID = p.ProductID
        WHERE i.UnitPrice >= p.UnitPrice
    )
    BEGIN
        PRINT 'No se permite aumentar el precio del producto';
    END;

    PRINT 'Trigger INSTEAD OF UPDATE (intermedio) ejecutado';
END;
GO

-- INSTEAD OF DELETE en Suppliers
CREATE TRIGGER trg_SupplierDelete_Int
ON Suppliers
INSTEAD OF DELETE
AS
BEGIN
    PRINT 'Trigger INSTEAD OF DELETE (intermedio) ejecutado';
    INSERT INTO SupplierAudit_Int (SupplierID, Action, AuditDate)
    SELECT SupplierID, 'DELETE BLOQUEADO', GETDATE()
    FROM deleted;
END;
GO

------------------------------------------------
--  4. EJECUCIONES DE PRUEBA (INTERMEDIO)
------------------------------------------------

-- AFTER INSERT válido
INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, ShipVia)
VALUES ('ALFKI', 5, GETDATE(), 1);
SELECT * FROM OrderAudit_Int;

-- AFTER INSERT inválido
INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, ShipVia)
VALUES (NULL, 5, GETDATE(), 1);

-- AFTER UPDATE válido
UPDATE Products SET UnitPrice = UnitPrice - 1 WHERE ProductID = 1;
SELECT * FROM PriceChanges_Int;

-- AFTER UPDATE inválido
UPDATE Products SET UnitPrice = 0 WHERE ProductID = 1;

-- AFTER DELETE inválido
DELETE FROM Products WHERE ProductID = 3;

-- AFTER DELETE válido
DELETE FROM Products WHERE ProductID = 4;
SELECT * FROM ProductDeletions_Int;

-- INSTEAD OF INSERT válido
INSERT INTO Customers (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
VALUES ('ZZZZZ', 'Nueva Empresa', 'Carlos Perez', 'Gerente', 'Av. Siempre Viva 123', 'Lima', NULL, '99999', 'Peru', '555-9999', NULL);
SELECT * FROM Customers WHERE CustomerID = 'ZZZZZ';

-- INSTEAD OF INSERT inválido
INSERT INTO Customers (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax)
VALUES ('YYYYY', NULL, 'Ana Lopez', 'Directora', 'Av. Central 456', 'Lima', NULL, '88888', 'Peru', '555-8888', NULL);

-- INSTEAD OF UPDATE válido
UPDATE Products SET UnitPrice = UnitPrice - 2 WHERE ProductID = 5;

-- INSTEAD OF UPDATE inválido
UPDATE Products SET UnitPrice = UnitPrice + 10 WHERE ProductID = 5;

-- INSTEAD OF DELETE bloqueado
DELETE FROM Suppliers WHERE SupplierID = 1;
SELECT * FROM SupplierAudit_Int WHERE SupplierID = 1;