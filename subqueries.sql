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
