USE Northwind
------------------------------------------------
--                   pag 9
------------------------------------------------
INSERT INTO Customers (CustomerID, CompanyName, ContactName,
                       ContactTitle, Address, City, 
                       Region, PostalCode, Country,
                       Phone, Fax)
     VALUES ('ABCDE', 'Mi Empresa', 'Juan Pérez',
             'Gerente', 'Calle 123', 'México',
             'CDMX', '12345', 'México',
             '555-1234', '555-5678');

------------------------------------------------
--                   pag 10
------------------------------------------------
INSERT INTO Customers (CustomerID, CompanyName, ContactName,
                       ContactTitle, Address, City,
                       PostalCode, Country, Phone,
                       Fax)
     VALUES ('FGHIJ', 'Otra Empresa', 'Ana Gómez',
             'Gerente', 'Calle 456', 'Guadalajara',
             '45678', 'México', '555-9876',
             '555-8765');

------------------------------------------------
--                   pag 11
------------------------------------------------
INSERT INTO Employees (LastName, FirstName, Title, TitleOfCourtesy, BirthDate,
                       HireDate, Address, City, Region, PostalCode,
                       Country, HomePhone, Extension, Notes, ReportsTo, PhotoPath)
     VALUES
     ('Martínez', 'María', 'Vendedor', 'Sra.', '1975-02-01',
      '2000-01-01', 'Calle 456', 'Monterrey', 'Nuevo León', '45678',
      'México', '555-1234', '234', NULL, 2, NULL),
     ('García', 'Pedro', 'Gerente', 'Sr.', '1970-01-01',
      '1995-05-01', 'Calle 789', 'Ciudad Juárez', 'Chihuahua', '78901',
      'México', '555-5555', '123', NULL, NULL, NULL),
     ('Ramírez', 'José', 'Vendedor', 'Sr.', '1980-03-01', 
      '2005-01-01', 'Calle 123', 'Tijuana', 'Baja California', '12345',
      'México', '555-9876', '345', NULL, 2, NULL);

------------------------------------------------
--                   pag 12
------------------------------------------------
INSERT INTO Orders (CustomerID, OrderDate)
SELECT CustomerID, GETDATE() 
  FROM Customers
 WHERE CustomerID = 'ABCDE';

------------------------------------------------
--                   pag 14
------------------------------------------------
UPDATE Employees
   SET FirstName = 'John', 
       LastName = 'Smith'
 WHERE EmployeeID = 1;

------------------------------------------------
--                   pag 15
------------------------------------------------
UPDATE Customers
   SET Region = 'Western'
 WHERE PostalCode LIKE '101%';

------------------------------------------------
--                   pag 16
------------------------------------------------
UPDATE Products
   SET UnitPrice = [Order Details].UnitPrice
  FROM [Order Details]
 WHERE Products.ProductID = [Order Details].ProductID;

------------------------------------------------
--                   pag 17
------------------------------------------------
UPDATE Products
   SET CategoryID = 2
 WHERE CategoryID = 1 AND UnitPrice > 10;

------------------------------------------------
--                   pag 18
------------------------------------------------
UPDATE Products
   SET UnitPrice = UnitPrice * 1.1
 WHERE CategoryID = 2;

------------------------------------------------
--                   pag 19
------------------------------------------------
UPDATE Products
SET CategoryID = 2
WHERE SupplierID IN (
    SELECT SupplierID
    FROM Suppliers
    WHERE CompanyName = 'Exotic Liquids'
);

------------------------------------------------
--                   pag 21
------------------------------------------------
DELETE FROM Employees
 WHERE EmployeeID = 1;

------------------------------------------------
--                   pag 22
------------------------------------------------
DELETE FROM Customers
 WHERE Phone IS NULL;

------------------------------------------------
--                   pag 23
------------------------------------------------
 DELETE FROM Orders
 WHERE OrderID IN (
    SELECT OrderID
    FROM [Order Details]
    GROUP BY OrderID
    HAVING SUM(Quantity * UnitPrice) > 1000
);

------------------------------------------------
--                   pag 24
------------------------------------------------
DELETE FROM Orders
WHERE CustomerID = 'ALFKI';

DELETE FROM [Order Details]
WHERE OrderID IN (
    SELECT OrderID
    FROM Orders
    WHERE CustomerID = 'ALFKI'
);

------------------------------------------------
--                   pag 25
------------------------------------------------
DELETE FROM Products
WHERE CategoryID = (
    SELECT CategoryID
    FROM Categories
    WHERE CategoryName = 'Beverages'
) AND UnitsInStock < 10;

------------------------------------------------
--                   pag 28
------------------------------------------------
-- Crea una copia de la tabla “Customers” pero vacía 
SELECT *
  INTO CustomersCopy
  FROM Customers
 WHERE 1=0;

-- Inserta todos los registros de la tabla
-- “Customers” en la tabla  “CustomersCopy”
INSERT INTO CustomersCopy
     SELECT *
       FROM Customers;

------------------------------------------------
--                   pag 29
------------------------------------------------
-- Crea una copia de la tabla “Customers” pero vacía 
SELECT *
  INTO CustomersLondon
  FROM Customers
 WHERE 1=0;

-- Inserta los registros de la tabla “Customers”, 
-- con City = 'London’, en a la tabla  “CustomersLondon”
INSERT INTO CustomersLondon
SELECT *
FROM Customers
WHERE City = 'London';

------------------------------------------------
--                   pag 30
------------------------------------------------
-- Crea una copia de la tabla “Products” de los 
-- campos ProductName y UnitPrice pero vacía 
SELECT ProductName, UnitPrice
INTO ProductPrices
FROM Products
WHERE 1=0;

-- Inserta los registros de la tabla “Products”, 
-- para los campos ProductName y UnitPrice , en 
-- la tabla  “ProductPrices”
INSERT INTO ProductPrices (ProductName, UnitPrice)
SELECT ProductName, UnitPrice
FROM Products;