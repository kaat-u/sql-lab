USE Northwind
------------------------------------------------
--                   pag 11
------------------------------------------------
SELECT p.ProductName, p.UnitPrice, od.UnitsSold
FROM Products p
JOIN (SELECT ProductID, SUM(Quantity) as UnitsSold
	  FROM [Order Details]
	  GROUP BY ProductID) od
ON p.ProductID = od.ProductID
WHERE p.UnitPrice > (SELECT AVG(UnitPrice) FROM Products); -- 27.7838 precio

------------------------------------------------
--                   pag 13
------------------------------------------------
SELECT DISTINCT c.CompanyName, c.ContactName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE od.ProductID IN (
	SELECT ProductID
	FROM Products
	WHERE UnitPrice > 20
);

------------------------------------------------
--                   pag 13
------------------------------------------------
SELECT DISTINCT c.CompanyName, c.ContactName
FROM Customers c
WHERE c.CustomerID NOT IN (
	SELECT DISTINCT c.CustomerID
	FROM Customers c
	JOIN Orders o ON c.CustomerID = o.CustomerID
	JOIN [Order Details] od ON o.OrderID = od.OrderID
	WHERE od.ProductID IN (
		SELECT ProductID
		FROM Products
		WHERE UnitPrice > 20
	)
);

------------------------------------------------
--                   pag 14
------------------------------------------------
DELETE FROM Orders
WHERE OrderID IN (
	SELECT DISTINCT od.OrderID
	FROM [Order Details] od
	JOIN Products p ON od.ProductID = p.ProductID
	WHERE p.UnitPrice > 50
);

------------------------------------------------
--                   pag 15
------------------------------------------------
INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
	SELECT 22077, ProductID, UnitPrice, 10, 0.05
	FROM Products
	WHERE CategoryID = (
		SELECT CategoryID
		FROM Categories
		WHERE CategoryName = 'Beverages'
);

------------------------------------------------
--                   pag 16
------------------------------------------------
UPDATE Products
SET UnitsInStock = (
	SELECT SUM(od.Quantity)
	FROM [Order Details] od
	JOIN Orders o ON od.OrderID = o.OrderID
	WHERE o.ShippedDate IS NULL
	  AND od. ProductID = Products.ProductID
)
WHERE ProductID = 7;

------------------------------------------------
--                   pag 17
------------------------------------------------
SELECT *
FROM Customers
WHERE City = (
	SELECT City
	FROM Customers
	WHERE CustomerID = 'ALFKI'
);

------------------------------------------------
--                   pag 18
------------------------------------------------
SELECT *
FROM Products
WHERE CategoryID <> (
	SELECT CategoryID
	FROM Categories
	WHERE CategoryName = 'Beverages'
);

------------------------------------------------
--                   pag 19
------------------------------------------------
SELECT *
FROM Customers c
WHERE EXISTS (
	SELECT *
	FROM Orders o
	WHERE o.CustomerID = c.CustomerID
	  AND o.OrderID = ANY (
		SELECT OrderID
		FROM [Order Details]
		WHERE Quantity > 20
	)
);

------------------------------------------------
--                   pag 20
------------------------------------------------
SELECT *
FROM Customers c
WHERE EXISTS (
	SELECT *
	FROM Orders o
	WHERE o.CustomerID = c.CustomerID
	  AND o.OrderID = SOME (
		SELECT OrderID
		FROM [Order Details]
		WHERE Quantity < 10
	)
);

------------------------------------------------
--                   pag 21
------------------------------------------------
SELECT *
FROM Customers c
WHERE NOT EXISTS (
	SELECT *
	FROM Orders o
	WHERE o.CustomerID = c.CustomerID
	  AND o.OrderID <> ALL (
		SELECT OrderID
		FROM [Order Details]
		WHERE Quantity >= 10
	)
);

------------------------------------------------
--                   pag 22
------------------------------------------------
SELECT p.ProductName, c.CategoryName
FROM Products p
LEFT JOIN Categories c
	ON p.CategoryID = c.CategoryID
		OR (p.CategoryID IS NULL AND c.CategoryID IS NULL)
WHERE (c.CategoryNAME IS DISTINCT FROM 'Beverages')
   OR (c.CategoryNAME IS NULL AND 'Beverages' IS NULL);

------------------------------------------------
--                   pag 31
------------------------------------------------
SELECT *
FROM Customers
WHERE EXISTS (SELECT *
				FROM Orders
				WHERE Orders.CustomerID = Customers.CustomerID);

------------------------------------------------
--                   pag 32
------------------------------------------------
SELECT CategoryID
FROM Products p
WHERE EXISTS (
	SELECT * FROM [Order Details] od
	WHERE od.ProductID = p.ProductID
	AND od.Quantity >= 10
);

------------------------------------------------
--                   pag 33
------------------------------------------------
SELECT *
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
WHERE EXISTS (SELECT *
			  FROM Employees
			 WHERE Employees.EmployeeID = Orders.EmployeeID
			   AND Employees.Title = 'Sales Representative'
);
