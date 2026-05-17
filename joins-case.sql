------------------------------------------------
--                   pag 7
------------------------------------------------

SELECT Products.ProductName, Categories.CategoryName
FROM Products
INNER JOIN Categories 
    ON Products.CategoryID = Categories.CategoryID;


INSERT INTO Products (ProductName, CategoryID)
VALUES ('ProductoSinCategoria', NULL);

------------------------------------------------
--                   pag 8
------------------------------------------------

SELECT Products.ProductName, Categories.CategoryName
FROM Products
LEFT OUTER JOIN Categories 
    ON Products.CategoryID = Categories.CategoryID;

------------------------------------------------
--                   pag 10
------------------------------------------------

SELECT c.CustomerID, c.ContactName, o.OrderID, o.OrderDate
FROM Customers c
LEFT OUTER JOIN Orders o 
    ON c.CustomerID = o.CustomerID;

------------------------------------------------
--                   pag 11
------------------------------------------------

SELECT c.CustomerID, c.ContactName, o.OrderID, o.OrderDate
FROM Customers c
RIGHT OUTER JOIN Orders o 
    ON c.CustomerID = o.CustomerID;

------------------------------------------------
--                   pag 12
------------------------------------------------

SELECT p.ProductID, p.ProductName, o.OrderID, o.OrderDate
FROM Products p
FULL OUTER JOIN [Order Details] od 
    ON p.ProductID = od.ProductID
FULL OUTER JOIN Orders o 
    ON od.OrderID = o.OrderID;

------------------------------------------------
--                   pag 13
------------------------------------------------

SELECT c.CategoryName, cu.CompanyName
FROM Categories c
CROSS JOIN Customers cu;

------------------------------------------------
--                   pag 14
------------------------------------------------

SELECT e.EmployeeID, 
       e.FirstName + ' ' + e.LastName AS EmployeeName,
       s.EmployeeID AS SupervisorID, 
       s.FirstName + ' ' + s.LastName AS SupervisorName
FROM Employees e
INNER JOIN Employees s 
       ON e.ReportsTo = s.EmployeeID;

------------------------------------------------
--                   pag 15
------------------------------------------------

SELECT o.OrderID, 
       od.ProductID, 
       od.Quantity, 
       od.UnitPrice
FROM Orders o, [Order Details] od
WHERE o.OrderID = od.OrderID;

------------------------------------------------
--                   pag 18
------------------------------------------------

SELECT ProductName,
       CASE
           WHEN CategoryID = 1 THEN 'Bebida'
           WHEN CategoryID = 2 THEN 'Frutas y verduras'
           WHEN CategoryID = 3 THEN 'Carnes'
           WHEN CategoryID = 4 THEN 'Lácteos'
           ELSE 'Otro'
       END AS Categoría
FROM Products;

------------------------------------------------
--                   pag 19
------------------------------------------------

SELECT OrderID,
       CASE
           WHEN ShippedDate IS NOT NULL THEN 'Enviado'
           ELSE 'No enviado'
       END AS Estado
FROM Orders;

------------------------------------------------
--                   pag 20
------------------------------------------------

SELECT CompanyName,
       CASE
           WHEN Country IN ('USA', 'Canada', 'Russia', 'France', 'UK') THEN 'Norte'
           ELSE 'Sur'
       END AS Hemisferio
FROM Suppliers;

------------------------------------------------
--                   pag 21
------------------------------------------------

SELECT Customers.ContactName,
       SUM([Order Details].UnitPrice * [Order Details].Quantity) AS VentasTotales,
       CASE
           WHEN SUM([Order Details].UnitPrice * [Order Details].Quantity) > 10000 THEN 'Grande'
           WHEN SUM([Order Details].UnitPrice * [Order Details].Quantity) > 5000 THEN 'Mediano'
           ELSE 'Pequeño'
       END AS Tamaño
FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID
INNER JOIN [Order Details] ON Orders.OrderID = [Order Details].OrderID
GROUP BY Customers.ContactName;

------------------------------------------------
--                   pag 22
------------------------------------------------

SELECT FirstName, 
       LastName, 
       BirthDate, 
       YEAR(GETDATE()) - YEAR(BirthDate) AS Age,
       CASE
           WHEN YEAR(GETDATE()) - YEAR(BirthDate) >= 75 THEN 'Niños de la Posguerra'
           WHEN YEAR(GETDATE()) - YEAR(BirthDate) BETWEEN 55 AND 74 THEN 'Baby Boomer'
           WHEN YEAR(GETDATE()) - YEAR(BirthDate) BETWEEN 43 AND 54 THEN 'Generación X'
           WHEN YEAR(GETDATE()) - YEAR(BirthDate) BETWEEN 30 AND 42 THEN 'Millenials'
           WHEN YEAR(GETDATE()) - YEAR(BirthDate) BETWEEN 13 AND 29 THEN 'Generación Z'
           WHEN YEAR(GETDATE()) - YEAR(BirthDate) <= 12 THEN 'Alfa'
           ELSE 'Otra generación'
       END AS Generación
FROM Employees;

------------------------------------------------
--                   pag 26
------------------------------------------------

SELECT ProductName AS NombreDelProducto, 
       CategoryName AS NombreDeLaCategoría
FROM Products
JOIN Categories ON Products.CategoryID = Categories.CategoryID
UNION
SELECT CategoryName, ''
FROM Categories
WHERE CategoryID NOT IN (SELECT CategoryID FROM Products);

------------------------------------------------
--                   pag 27
------------------------------------------------

SELECT e.FirstName + ' ' + e.LastName AS Empleado, 
       s.FirstName + ' ' + s.LastName AS Supervisor
FROM Employees e
LEFT JOIN Employees s ON e.ReportsTo = s.EmployeeID
UNION
SELECT s.FirstName + ' ' + s.LastName, 
       'Ninguno' AS Supervisor
FROM Employees s
WHERE s.EmployeeID NOT IN (
    SELECT ReportsTo 
    FROM Employees 
    WHERE ReportsTo IS NOT NULL
);

------------------------------------------------
--                   pag 28
------------------------------------------------

SELECT CompanyName AS Proveedor, 
       Country AS País
FROM Suppliers
UNION
SELECT 'Ninguno' AS Proveedor, 
       Country
FROM (
    SELECT DISTINCT Country FROM Customers
    UNION
    SELECT DISTINCT Country FROM Employees
) AS p
WHERE Country NOT IN (
    SELECT DISTINCT Country 
    FROM Suppliers
);

------------------------------------------------
--                   pag 29
------------------------------------------------

SELECT ProductName AS NombreDelProducto, 
       e.FirstName + ' ' + e.LastName AS Empleado
FROM [Order Details] od
JOIN Products p ON od.ProductID = p.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Employees e ON o.EmployeeID = e.EmployeeID
UNION
SELECT ProductName, 'Ninguno' AS Empleado
FROM Products
WHERE ProductID NOT IN (
    SELECT DISTINCT ProductID 
    FROM [Order Details]
);

------------------------------------------------
------------------------------------------------