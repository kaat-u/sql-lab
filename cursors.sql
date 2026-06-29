------------------------------------------------
--					   S12
------------------------------------------------
USE Northwind
DECLARE @OrderID INT, @Secuencia INT = 1;

DECLARE cur CURSOR FOR
    SELECT OrderID
    FROM Orders
    ORDER BY OrderDate;

OPEN cur;
FETCH NEXT FROM cur INTO @OrderID;

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE Orders
    SET ShipRegion = ISNULL(ShipRegion,'') + ' COD-' + CAST(@Secuencia AS NVARCHAR(10))
    WHERE OrderID = @OrderID;

    SET @Secuencia = @Secuencia + 1;
    FETCH NEXT FROM cur INTO @OrderID;
END

CLOSE cur;
DEALLOCATE cur;

------------------------------------------------
------------------------------------------------
 CREATE TABLE NotificacionesClientes (
    NotificacionID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NCHAR(5) NOT NULL,
    Mensaje NVARCHAR(200) NOT NULL,
    Fecha DATETIME NOT NULL DEFAULT GETDATE()
);

DECLARE @CustomerID NCHAR(5), @CompanyName NVARCHAR(40);

DECLARE cur CURSOR FOR
    SELECT DISTINCT C.CustomerID, C.CompanyName
    FROM Customers C
    INNER JOIN Orders O ON C.CustomerID = O.CustomerID
    WHERE O.ShippedDate IS NULL;

OPEN cur;
FETCH NEXT FROM cur INTO @CustomerID, @CompanyName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Notificar al cliente: ' + @CompanyName;

    INSERT INTO NotificacionesClientes (CustomerID, Mensaje)
    VALUES (@CustomerID, 'Tiene pedidos pendientes');

    FETCH NEXT FROM cur INTO @CustomerID, @CompanyName;
END

CLOSE cur;
DEALLOCATE cur;

select * from NotificacionesClientes

------------------------------------------------
------------------------------------------------
 DECLARE @OrderID INT, @Monto DECIMAL(10,2), @Saldo DECIMAL(10,2) = 0;

-- Cursor que recorre pedidos de un cliente específico en orden de fecha
DECLARE cur CURSOR FOR
    SELECT O.OrderID, SUM(OD.UnitPrice * OD.Quantity) AS Monto
    FROM Orders O
    INNER JOIN [Order Details] OD ON O.OrderID = OD.OrderID
    WHERE O.CustomerID = 'ALFKI'   -- ejemplo: cliente ALFKI
    GROUP BY O.OrderID, O.OrderDate
    ORDER BY O.OrderDate;          -- ahora sí válido

OPEN cur;
FETCH NEXT FROM cur INTO @OrderID, @Monto;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Acumulamos pedido por pedido
    SET @Saldo = @Saldo + @Monto;

    PRINT 'Pedido: ' + CAST(@OrderID AS NVARCHAR(10)) 
          + ' - Monto: ' + CAST(@Monto AS NVARCHAR(20)) 
          + ' - Saldo acumulado: ' + CAST(@Saldo AS NVARCHAR(20));

    FETCH NEXT FROM cur INTO @OrderID, @Monto;
END

CLOSE cur;
DEALLOCATE cur;

------------------------------------------------
------------------------------------------------
DECLARE @EmployeeID INT, @Ventas DECIMAL(10,2), @Saldo DECIMAL(10,2) = 0;

DECLARE cur CURSOR FOR
    SELECT E.EmployeeID, SUM(OD.UnitPrice * OD.Quantity) AS Ventas
    FROM Employees E
    INNER JOIN Orders O ON E.EmployeeID = O.EmployeeID
    INNER JOIN [Order Details] OD ON O.OrderID = OD.OrderID
    GROUP BY E.EmployeeID
    ORDER BY E.EmployeeID;

OPEN cur;
FETCH NEXT FROM cur INTO @EmployeeID, @Ventas;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Saldo = @Saldo + @Ventas;

    PRINT 'Empleado ' + CAST(@EmployeeID AS NVARCHAR(10)) 
          + ' - Ventas: ' + CAST(@Ventas AS NVARCHAR(20)) 
          + ' - Saldo acumulado: ' + CAST(@Saldo AS NVARCHAR(20));

    -- Lógica secuencial: detenernos en el primer que supere el umbral
    IF @Saldo > 810000
    BEGIN
        PRINT 'Se alcanzó el umbral global en el empleado ' + CAST(@EmployeeID AS NVARCHAR(10));
        BREAK;  -- detenemos el cursor aquí
    END

    FETCH NEXT FROM cur INTO @EmployeeID, @Ventas;
END

CLOSE cur;
DEALLOCATE cur;

------------------------------------------------
------------------------------------------------
DECLARE ProductCursor CURSOR FOR
    SELECT ProductID, UnitPrice
    FROM Products
    FOR UPDATE OF UnitPrice;

OPEN ProductCursor;
FETCH NEXT FROM ProductCursor INTO @ProductID, @UnitPrice;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @UnitPrice = @UnitPrice * 1.1;

    UPDATE Products
    SET UnitPrice = @UnitPrice
    WHERE CURRENT OF ProductCursor;  -- aquí se reemplaza el valor de la fila actual

    FETCH NEXT FROM ProductCursor INTO @ProductID, @UnitPrice;
END

CLOSE ProductCursor;
DEALLOCATE ProductCursor;
