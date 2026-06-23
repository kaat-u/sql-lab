------------------------------------------------
--					   S09
------------------------------------------------
USE Northwind

------------------------------------------------
--                   pag 6
------------------------------------------------
CREATE PROCEDURE SumarNumeros
    @numero1 INT,
    @numero2 INT,
    @resultado INT OUTPUT
AS
BEGIN
    SET @resultado = @numero1 + @numero2
END


DECLARE @resultado INT
EXEC SumarNumeros 5, 3, @resultado OUTPUT
SELECT @resultado AS suma

------------------------------------------------
--                   pag 9
------------------------------------------------
CREATE PROCEDURE Saludo
AS
BEGIN
    PRINT '¡Hola!'
END

------------------------------------------------
--                   pag 10
------------------------------------------------
-- Procedimiento con solo parámetros de entrada
CREATE PROCEDURE ObtenerTotalPedido
    @PedidoID INT   -- Solo entrada
AS
BEGIN
    -- Calcula el total y lo devuelve con SELECT
    SELECT SUM(Quantity * UnitPrice) AS Total
    FROM [Order Details]
    WHERE OrderID = @PedidoID;
END
GO
-- Ejemplo de ejecución
EXEC ObtenerTotalPedido @PedidoID = 10248;


------------------------------------------------
--                   pag 11
------------------------------------------------
CREATE PROCEDURE CalcularSuma  
    @Suma INT OUTPUT  
AS  
BEGIN  
    SET @Suma = 8 + 6  
END
GO
-- Ejecución del procedimiento
DECLARE @Resultado INT;
EXEC CalcularSuma @Suma = @Resultado OUTPUT;
-- Mostrar el valor obtenido
PRINT 'La suma es: ' + CAST(@Resultado AS VARCHAR);

------------------------------------------------
--                   pag 12
------------------------------------------------
CREATE PROCEDURE IncrementarValor2
    @Numero INT OUTPUT
AS
BEGIN
    SET @Numero = @Numero + 1;
END
GO
DECLARE @MiNumero INT = 10;
EXEC IncrementarValor2 @Numero = @MiNumero OUTPUT;
PRINT 'El nuevo valor es: ' + CAST(@MiNumero AS VARCHAR);

------------------------------------------------
--                   pag 13
------------------------------------------------
CREATE PROCEDURE ObtenerEmpleados3
AS
BEGIN
    SELECT * FROM Employees
END
exec ObtenerEmpleados3

------------------------------------------------
--                   pag 14
------------------------------------------------
CREATE PROCEDURE CalcularDescuento2
    @Precio INT
AS
BEGIN
    DECLARE @Descuento INT;
    IF @Precio > 1000
        SET @Descuento = 10;
    ELSE
        SET @Descuento = 5;
    RETURN @Descuento;
END
GO
-- Ejecución y captura del valor de retorno
DECLARE @Resultado INT;
EXEC @Resultado = CalcularDescuento2 500;
PRINT 'El descuento es: ' + CAST(@Resultado AS VARCHAR);

------------------------------------------------
--                   pag 21
------------------------------------------------
CREATE PROCEDURE ActualizarStockSimple
    @ProductoID INT,
    @CantidadVendida INT,
    @StockRestante INT OUTPUT,
    @Descuento FLOAT OUTPUT
AS
BEGIN
    -- Obtener el stock actual
    SELECT @StockRestante = UnitsInStock
    FROM Products
    WHERE ProductID = @ProductoID;
    -- Calcular el descuento según el stock
    SET @Descuento = CASE 
                        WHEN @StockRestante > 50 THEN 0.1
                        ELSE 0.05
                     END;
    -- Actualizar el stock restante
    SET @StockRestante = @StockRestante - @CantidadVendida;
    UPDATE Products
       SET UnitsInStock = @StockRestante
     WHERE ProductID = @ProductoID;
END
GO
-- Ejemplo de ejecución
DECLARE @Stock INT, @Desc FLOAT;
EXEC ActualizarStockSimple 
    @ProductoID = 1, 
    @CantidadVendida = 5, 
    @StockRestante = @Stock OUTPUT, 
    @Descuento = @Desc OUTPUT;
PRINT 'Stock restante: ' + CAST(@Stock AS VARCHAR);
PRINT 'Descuento aplicado: ' + CAST(@Desc AS VARCHAR);

------------------------------------------------
--                   pag 24
------------------------------------------------
CREATE PROCEDURE VerificarStock
    @ProductoID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductoID AND UnitsInStock > 0)
        RETURN 0;  -- éxito
    ELSE
        RETURN 1;  -- error: sin stock
END

------------------------------------------------
--                   pag 26
------------------------------------------------
DECLARE @Codigo INT;
EXEC @Codigo = VerificarStock 5;
SELECT @Codigo AS Estado;

------------------------------------------------
--                   pag 27
------------------------------------------------
CREATE PROCEDURE CalcularSuma
    @Numero1 INT,
    @Numero2 INT
AS
BEGIN
    DECLARE @Suma INT

    SET @Suma = @Numero1 + @Numero2

    IF @Suma > 100
        RETURN 1
    ELSE
        RETURN 0
END


DECLARE @Resultado INT
EXEC @Resultado = CalcularSuma 50, 70
-- Ver resultado
SELECT @Resultado AS Resultado

------------------------------------------------
--                   pag 32
------------------------------------------------
alter  PROCEDURE InsertarEmpleadoSimple
    @Apellido NVARCHAR(20),
    @Nombre NVARCHAR(10),
    @EmpleadoID INT OUTPUT
AS
BEGIN
    INSERT INTO Employees (LastName, FirstName)
    VALUES (@Apellido, @Nombre);
    SET @EmpleadoID = @@IDENTITY;
END

DECLARE @EmpleadoID INT;
EXEC InsertarEmpleadoSimple
    @Apellido = 'Ramirez',
    @Nombre = 'David',
    @EmpleadoID = @EmpleadoID OUTPUT;
SELECT @EmpleadoID AS NuevoEmpleadoID;

------------------------------------------------
--                   pag 33
------------------------------------------------
CREATE PROCEDURE ActualizarCiudadEmpleados
    @CiudadActual NVARCHAR(15),
    @NuevaCiudad NVARCHAR(15),
    @FilasAfectadas INT OUTPUT
AS
BEGIN
    UPDATE Employees
    SET City = @NuevaCiudad
    WHERE City = @CiudadActual;

    -- Devuelve cuántas filas fueron modificadas
    SET @FilasAfectadas = @@ROWCOUNT;
END

DECLARE @Filas INT;
EXEC ActualizarCiudadEmpleados
    @CiudadActual = 'London',
    @NuevaCiudad = 'Londres',
    @FilasAfectadas = @Filas OUTPUT;
SELECT @Filas AS FilasModificadas;

------------------------------------------------
--                   pag 34
------------------------------------------------
alter  PROCEDURE EliminarPedido
    @PedidoID INT,
    @EstadoPedido NVARCHAR(30) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    -- Primero borrar los detalles
    DELETE FROM [Order Details]
    WHERE OrderID = @PedidoID;
    -- Luego borrar el pedido
    DELETE FROM Orders
    WHERE OrderID = @PedidoID;
    IF @@ROWCOUNT > 0
        SET @EstadoPedido = 'ELIMINADO';
    ELSE
        SET @EstadoPedido = 'NO EXISTE';
END

DECLARE @Estado NVARCHAR(30);
EXEC EliminarPedido
    @PedidoID = 11076,
    @EstadoPedido = @Estado OUTPUT;
SELECT @Estado AS EstadoPedido;

------------------------------------------------
--                   pag 35
------------------------------------------------
ALTER  PROCEDURE InsProdActExist
    @NombreProducto NVARCHAR(40),
    @CategoriaID INT,
    @Precio DECIMAL(10, 2),
    @UnidadesEnExistencia INT,
    @NuevoProductID INT OUTPUT,
    @TotalProductosCategoria INT OUTPUT
AS
BEGIN
    -- Insertar el producto
    INSERT INTO Products (ProductName, CategoryID, UnitPrice, UnitsInStock)
    VALUES (@NombreProducto, @CategoriaID, @Precio, @UnidadesEnExistencia);
    -- Capturar el nuevo ProductID
    SET @NuevoProductID = @@IDENTITY;
    -- Contar productos en la categoría después de la inserción
    SELECT @TotalProductosCategoria = COUNT(*)
    FROM Products
    WHERE CategoryID = @CategoriaID;
END

DECLARE @ProductID INT, @Total INT;
EXEC InsProdActExist
    @NombreProducto = 'Nuevo Producto',
    @CategoriaID = 1,
    @Precio = 10.99,
    @UnidadesEnExistencia = 100,
    @NuevoProductID = @ProductID OUTPUT,
    @TotalProductosCategoria = @Total OUTPUT;
SELECT @ProductID AS NuevoProductID, @Total AS TotalProductosEnCategoria;

------------------------------------------------
--                   pag 36
------------------------------------------------
CREATE PROCEDURE ActualizarPrecioProducto
    @ProductoID INT,
    @NuevoPrecio DECIMAL(10, 2),
    @PrecioAnterior DECIMAL(10, 2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    -- Guardar el precio anterior
    SELECT @PrecioAnterior = UnitPrice
    FROM Products
    WHERE ProductID = @ProductoID;
    -- Actualizar al nuevo precio
    UPDATE Products
    SET UnitPrice = @NuevoPrecio
    WHERE ProductID = @ProductoID;
END

DECLARE @PrecioAnterior DECIMAL(10, 2);
EXEC ActualizarPrecioProducto
    @ProductoID = 5,
    @NuevoPrecio = 19.99,
    @PrecioAnterior = @PrecioAnterior OUTPUT;
SELECT @PrecioAnterior AS PrecioAnterior;

------------------------------------------------
--                   pag 37
------------------------------------------------
CREATE PROCEDURE EliminarCliente
    @ClienteID NVARCHAR(5),
    @PedidosEliminados INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    -- Contar pedidos asociados
    SELECT @PedidosEliminados = COUNT(*)
    FROM Orders
    WHERE CustomerID = @ClienteID;
    -- Primero borrar detalles de los pedidos
    DELETE FROM [Order Details]
    WHERE OrderID IN (SELECT OrderID FROM Orders WHERE CustomerID = @ClienteID);
    -- Luego borrar los pedidos
    DELETE FROM Orders
    WHERE CustomerID = @ClienteID;
    -- Finalmente borrar el cliente
    DELETE FROM Customers
    WHERE CustomerID = @ClienteID;
END

DECLARE @PedidosEliminados INT;
EXEC EliminarCliente
    @ClienteID = 'ALFKI',
    @PedidosEliminados = @PedidosEliminados OUTPUT;
SELECT @PedidosEliminados AS PedidosEliminados;
