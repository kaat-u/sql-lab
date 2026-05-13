------------------------------------------------
--                   pag 7
------------------------------------------------

USE Master
go

IF EXISTS ( SELECT name FROM sysdatabases WHERE name = 'Northwind' )
    DROP DATABASE Northwind
go

CREATE DATABASE Northwind
ON PRIMARY
(NAME = Northwind_Dat, FILENAME = 'C:\DB\Northwind_Dat.mdf',
 SIZE = 5MB, MAXSIZE = 200, FILEGROWTH = 1 )
LOG ON
(NAME = Northwind_Log, FILENAME = 'C:\DB\Northwind_Log.ldf',
 SIZE = 1MB, MAXSIZE = 200, FILEGROWTH = 1MB)
go

------------------------------------------------
--                   pag 16
------------------------------------------------

-- Consultar la tabla Clientes
SELECT * FROM Customers
GO

------------------------------------------------
--                   pag 17
------------------------------------------------ 

-- Consultar la tabla Productos
SELECT * FROM Products
GO

------------------------------------------------
--                   pag 18
------------------------------------------------

SELECT ProductID, ProductName, UnitPrice
FROM Products
GO

------------------------------------------------
--                   pag 19
------------------------------------------------

-- Utilizando un alias para las cabeceras de columnas
-- Utilizar un alias
SELECT
    ProductID AS 'Codigo',
    ProductName AS 'Producto',
    UnitPrice AS 'Precio'
FROM Products
GO

------------------------------------------------
--                   pag 20
------------------------------------------------

SELECT OrderID, ProductID, UnitPrice, Quantity, Discount,
       UnitPrice * Quantity AS 'SubTotal'
FROM [Order Details]
GO

------------------------------------------------
--                   pag 23
------------------------------------------------

-- Listado de los clientes de Mexico
SELECT * FROM Customers
WHERE Country = 'Mexico'
GO

------------------------------------------------
--                   pag 24
------------------------------------------------

-- Listado de los clientes de Francia
SELECT * FROM Customers
WHERE Country = 'France'
GO

------------------------------------------------
--                   pag 25
------------------------------------------------

-- Listado de productos con precio mayor a 20
SELECT * FROM Products
WHERE UnitPrice > 20
GO

------------------------------------------------
--                   pag 27
------------------------------------------------

-- Listado de productos con precio entre 20 y 30
-- operador BETWEEN
SELECT * FROM Products
WHERE UnitPrice BETWEEN 20 AND 30
GO

------------------------------------------------
--                   pag 29
------------------------------------------------

-- Listado de productos de la categoria 1, 4 y 6  
SELECT ProductID, ProductName, CategoryID  
FROM Products  
WHERE CategoryID IN (1,4,6)  
GO

------------------------------------------------
--                   pag 31
------------------------------------------------

-- Lista de clientes con la letra C como primer carácter
-- en el nombre
SELECT CustomerID, CompanyName 
FROM Customers
WHERE CompanyName LIKE 'C%'
GO

------------------------------------------------
--                   pag 32
------------------------------------------------

-- Lista de clientes con la letra a como primer
-- y último carácter en el nombre
SELECT CustomerID, CompanyName 
FROM Customers
WHERE CompanyName LIKE 'a%a'
GO

------------------------------------------------
--                   pag 33
------------------------------------------------

-- Listado de clientes con la letra U como tercer carácter  
-- en el nombre  
SELECT CustomerID, CompanyName 
FROM Customers  
WHERE CompanyName LIKE '__U%'  
GO

------------------------------------------------
--                   pag 37
------------------------------------------------

-- Obtener el precio unitario máximo de todos los productos  
SELECT MAX(UnitPrice) AS 'Precio mayor'  
FROM Products  
GO

------------------------------------------------
--                   pag 38
------------------------------------------------

-- Obtener el stock valorado en la tabla Products.
SELECT SUM(UnitPrice*UnitsInStock) AS 'stock valorado'
FROM Products
GO

------------------------------------------------
--                   pag 39
------------------------------------------------

-- Obtener el precio unitario máximo, mínimo, promedio  
-- de todos los productos en la tabla Products.  
-- Además mostrar el número de productos.  
SELECT MAX(UnitPrice) AS 'Precio mayor',  
       MIN(UnitPrice) AS 'Precio menor',  
       AVG(UnitPrice) AS 'Precio promedio',  
       COUNT(*) AS 'numero de productos'  
FROM Products  
GO

------------------------------------------------
--                   pag 41
------------------------------------------------

-- Mostrar un listado que muestre el código del Cliente
-- y el número de pedidos que realizo cada cliente.
-- Primero veremos una lista de pedidos ordenados
-- por cliente:
SELECT CustomerID , OrderID
FROM Orders 
ORDER BY CustomerID
GO

------------------------------------------------
--                   pag 42
------------------------------------------------

-- A continuación agrupamos por cliente (CustomerID)
SELECT CustomerID, COUNT(OrderID) AS 'Nro Pedidos'
FROM Orders
GROUP BY CustomerID
GO

------------------------------------------------
--                   pag 43
------------------------------------------------

-- Mostrar un listado que muestre el código de categoría
-- y el promedio de precios por categoría.
SELECT CategoryID, AVG(UnitPrice) AS 'Promedio de precios'
FROM Products
GROUP BY CategoryID
GO

------------------------------------------------
--                   pag 44
------------------------------------------------

-- Mostrar el Monto de ventas por Pedido  
SELECT OrderID,  
       SUM(UnitPrice * Quantity * (1 - Discount)) AS Monto  
FROM [Order Details]  
GROUP BY OrderID  
GO

------------------------------------------------
--                   pag 45
------------------------------------------------

--Mostrar el numero de Pedidos realizados por los clientes
-- solo para los clientes que hicieron menos de 4 pedidos
SELECT CustomerID, COUNT(OrderID) AS 'Nro Pedidos'
FROM Orders
GROUP BY CustomerID
HAVING COUNT(OrderID) < 4
ORDER BY 2 DESC
GO

------------------------------------------------
--                   pag 48
------------------------------------------------

-- CHARINDEX: devuelve la posición de la primera aparición de un valor de cadena dentro de otra cadena.
-- Ejemplo: SELECT CHARINDEX('an', 'banana')

-- CONCAT: concatena dos o más cadenas en una sola. 
-- Ejemplo: SELECT CONCAT('North', 'wind')

-- LEN: devuelve la longitud de una cadena. 
-- Ejemplo: SELECT LEN('Hello, world! ')

-- LEFT: devuelve una parte especificada de una cadena, comenzando por la izquierda. 
-- Ejemplo: SELECT LEFT('Northwind', 5)

-- RIGHT: devuelve una parte especificada de una cadena, comenzando por la derecha. 
-- Ejemplo: SELECT RIGHT('Northwind', 4)

-- REPLACE: reemplaza todas las apariciones de un valor de cadena dentro de otra cadena con un nuevo valor de cadena. 
-- Ejemplo: SELECT REPLACE('The quick brown fox', 'brown', 'red')

-- SUBSTRING: devuelve una parte especificada de una cadena. 
-- Ejemplo: SELECT SUBSTRING('Northwind', 2, 5)

-- LOWER: convierte una cadena en minúsculas. 
-- Ejemplo: SELECT LOWER('NORTHWIND')

-- UPPER: convierte una cadena en mayúsculas. 
-- Ejemplo: SELECT UPPER('northwind')

-- ABS: devuelve el valor absoluto de un número. 
-- Ejemplo: SELECT ABS(-10)

-- CEILING: redondea un número al entero más cercano mayor o igual al número. 
-- Ejemplo: SELECT CEILING(3.14)

-- FLOOR: redondea un número al entero más cercano menor o igual al número. 
-- Ejemplo: SELECT FLOOR(3.14)

-- POWER: devuelve el resultado de elevar un número a una potencia especificada. 
-- Ejemplo: SELECT POWER(2, 3)

-- ROUND: redondea un número a un número especificado de decimales. 
-- Ejemplo: SELECT ROUND(3.14159, 2)

-- SIGN: devuelve el signo de un número (1 para positivo, -1 para negativo y 0 para cero). 
-- Ejemplo: SELECT SIGN(-10)


-- DATEADD: agrega una cantidad especificada de tiempo a una fecha y devuelve la nueva fecha resultante. 
-- Ejemplo: SELECT DATEADD(day, 7, '2023-04-20')

-- DATEDIFF: devuelve la diferencia entre dos fechas en unidades de tiempo especificadas. 
-- Ejemplo: SELECT DATEDIFF(day, '2023-04-20', '2023-04-27')

-- DATEPART: devuelve una parte especificada de una fecha (como el año, el mes o el día). 
-- Ejemplo: SELECT DATEPART(year, '2023-04-27')

-- GETDATE: devuelve la fecha y hora actuales del sistema. 
-- Ejemplo: SELECT GETDATE()

------------------------------------------------
------------------------------------------------