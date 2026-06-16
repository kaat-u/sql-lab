USE Northwind
------------------------------------------------
--					   S06
------------------------------------------------

------------------------------------------------
--                   pag 12
------------------------------------------------
CREATE VIEW HappybirthdayEmployeeView
AS
SELECT FirstName, LastName, BirthDate
FROM Employees;

------------------------------------------------
--                   pag 15
------------------------------------------------
ALTER VIEW HappybirthdayEmployeeView 
AS
SELECT FirstName, LastName, BirthDate, Title, City
FROM Employees;

------------------------------------------------
--                   pag 16
------------------------------------------------
DROP VIEW HappybirthdayEmployeeView;

------------------------------------------------
--                   pag 17
------------------------------------------------
UPDATE HappybirthdayEmployeeView
   SET City = 'Lima'
 WHERE FirstName = 'Nancy' AND LastName = 'Davolio';

------------------------------------------------
--                   pag 18
------------------------------------------------
 UPDATE HappybirthdayEmployeeView
   SET City = 'Lima'
 WHERE FirstName = 'Nancy' AND LastName = 'Davolio';

------------------------------------------------
--                   pag 25
------------------------------------------------
 SP_HELPINDEX nombre_tabla;

------------------------------------------------
--                   pag 28
------------------------------------------------
CREATE CLUSTERED INDEX IDX_Clustered_Orders
  ON Orders (OrderID, CustomerID, OrderDate);

------------------------------------------------
--                   pag 30
------------------------------------------------
CREATE NONCLUSTERED INDEX IDX_NonClustered_OrderDetails
  ON OrderDetails (OrderID, ProductID);

------------------------------------------------
--                   pag 32
------------------------------------------------
CREATE UNIQUE INDEX IDX_Unique_Customers
  ON Customers (Country, CompanyName);

------------------------------------------------
--                   pag 35
------------------------------------------------
CREATE FULLTEXT INDEX IDX_FullText_Products
  ON Products (Description);
