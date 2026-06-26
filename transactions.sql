------------------------------------------------
--					   S10
------------------------------------------------
USE Northwind

------------------------------------------------
--                   pag 4
------------------------------------------------
UPDATE clientes SET sexo='F' WHERE sexo ='F'

------------------------------------------------
--                   pag 15
------------------------------------------------
CREATE PROCEDURE EjemploVariableLocal
AS
BEGIN
    -- Variable local
    DECLARE @nombre VARCHAR(50); 
    SET @nombre = 'John Doe';
    
    SELECT * FROM Usuarios WHERE Nombre = @nombre;
END;

------------------------------------------------
--                   pag 16
------------------------------------------------
DECLARE @rowCount INT;

UPDATE Usuarios 
        SET Estado = 'Inactivo' 
 WHERE FechaRegistro < DATEADD(MONTH, -6, GETDATE());

SET @rowCount = @@ROWCOUNT;

SELECT @rowCount AS NumeroFilasAfectadas;

------------------------------------------------
--                   pag 24
------------------------------------------------
DECLARE @counter INT = 1;

Loop:
IF @counter <= 10
BEGIN
   PRINT 'Counter: ' + CAST(@counter AS VARCHAR(10));
   SET @counter = @counter + 1;
   GOTO Loop;
END

------------------------------------------------
--                   pag 25
------------------------------------------------
DECLARE @value INT = 1;
IF @value = 1
   GOTO Label1;
ELSE IF @value = 2
   GOTO Label2;
ELSE
   GOTO Label3;
Label1:
   PRINT 'El valor es 1';
   GOTO End;

Label2:
   PRINT 'El valor es 2';
   GOTO End;
Label3:
   PRINT 'El valor no es ni 1 ni 2';
   GOTO End;

End:
   PRINT 'Fin del programa.';

------------------------------------------------
--                   pag 30
------------------------------------------------
-- Inicio de la transacción implícita
INSERT INTO Categories(CategoryID, CategoryName)
     VALUES(10, 'Spicy Seafood');

-- La transacción se completa automáticamente

-- Verificación de los datos insertados
SELECT * FROM Categories;

------------------------------------------------
--                   pag 31
------------------------------------------------
-- Inicio de la transacción implícita
BEGIN
    -- Sentencia 1: Insertar una nueva categoría
    INSERT INTO Categories(CategoryID, CategoryName)
     VALUES(10, 'Spicy Seafood');
    -- Sentencia 2: Actualizar el nombre de una agencia de envíos
    UPDATE Shippers
       SET CompanyName = 'Federal Speedy Express'
     WHERE ShipperID = 1;
-- La transacción se completa automáticamente
-- Verificación de los datos modificados
SELECT * FROM Categories;
SELECT * FROM Shippers;

------------------------------------------------
--                   pag 33
------------------------------------------------
BEGIN TRANSACTION;
BEGIN TRY
    -- Sentencia: Actualizar el nombre del cliente
    UPDATE Customers
       SET ContactName = 'Pedro'
     WHERE CustomerID = 'ALFKI';

    -- Condición para determinar si se confirma o se deshace la transacción
    IF (EXISTS (SELECT * FROM Customers WHERE CustomerID = 'ALFKI' AND ContactName = 'Pedro'))
        COMMIT TRANSACTION;
    ELSE
        ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    -- Deshacer la transacción en caso de error
    ROLLBACK TRANSACTION;
END CATCH;
-- Verificación del resultado
SELECT * FROM Customers WHERE CustomerID = 'ALFKI';

------------------------------------------------
--                   pag 34
------------------------------------------------
BEGIN TRANSACTION;
DECLARE @RetryCount INT = 3; -- Número máximo de intentos
DECLARE @CurrentRetry INT = 1; -- Contador de intentos
BEGIN TRY
    WHILE (@CurrentRetry <= @RetryCount)
    BEGIN
        -- Sentencia 1: Actualizar el nombre del cliente
        UPDATE Customers
        SET ContactName = 'Pedro'
        WHERE CustomerID = 'ALFKI';

        -- Sentencia 2: Actualizar el estado del cliente
        UPDATE Customers
        SET Country = 'Spain'
        WHERE CustomerID = 'ALFKI';

        -- Condición para determinar si se confirma o se deshace la transacción
        IF (EXISTS (SELECT * FROM Customers WHERE CustomerID = 'ALFKI' AND ContactName = 'Pedro' AND Country = 'Spain'))
        BEGIN
            COMMIT TRANSACTION;
            BREAK; -- Salir del bucle si se confirma la transacción
        END
        ELSE
        BEGIN
            SET @CurrentRetry += 1; -- Incrementar el contador de intentos
            CONTINUE; -- Volver a intentar la transacción
        END
    END;
END TRY
BEGIN CATCH
    -- Deshacer la transacción en caso de error
    ROLLBACK TRANSACTION;
END CATCH;
-- Verificación del resultado
SELECT * FROM Customers WHERE CustomerID = 'ALFKI';

------------------------------------------------
--                   pag 35
------------------------------------------------
BEGIN TRANSACTION;
DECLARE @RetryCount INT = 3; -- Número máximo de intentos
DECLARE @CurrentRetry INT = 1; -- Contador de intentos
BEGIN TRY
    WHILE (@CurrentRetry <= @RetryCount)
    BEGIN
        -- Sentencia 1: Actualizar el nombre del cliente
        UPDATE Customers
        SET ContactName = 'Pedro'
        WHERE CustomerID = 'ALFKI';
        -- Sentencia 2: Actualizar el estado del cliente
        UPDATE Customers
        SET Country = 'Spain'
        WHERE CustomerID = 'ALFKI';
        -- Condición para determinar si se confirma o se deshace la transacción
        IF (EXISTS (SELECT * FROM Customers WHERE CustomerID = 'ALFKI' AND ContactName = 'Pedro' AND Country = 'Spain'))
        BEGIN
            COMMIT TRANSACTION;
            BREAK; -- Salir del bucle si se confirma la transacción
        END
        ELSE
        BEGIN
            SET @CurrentRetry += 1; -- Incrementar el contador de intentos
            CONTINUE; -- Volver a intentar la transacción
        END
    END;
END TRY
BEGIN CATCH
    -- Deshacer la transacción en caso de error
    ROLLBACK TRANSACTION;
END CATCH;
-- Verificación del resultado
SELECT * FROM Customers WHERE CustomerID = 'ALFKI';

------------------------------------------------
--                   pag 39
------------------------------------------------
CREATE PROCEDURE ActualizarCliente
    @CustomerID VARCHAR(5),
    @NewContactName NVARCHAR(50),
    @NewCountry NVARCHAR(50),
    @Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @SavepointName NVARCHAR(128) = N'SP_UpdateCustomer';
    DECLARE @OperationResult BIT;
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Realizar la operación y asignar el resultado a la variable local @OperationResult
        SET @OperationResult = dbo.CheckOperation(@CustomerID);
        -- Comprobar el resultado de la operación para determinar si guardar el punto de guardado
        IF @OperationResult = 1
        BEGIN
            -- Guardar el punto de guardado con el nombre de la transacción y la variable de sistema @@TRANCOUNT
            SET @SavepointName = N'SP_UpdateCustomer_' + CONVERT(NVARCHAR(128), @@TRANCOUNT);
            SAVE TRANSACTION @SavepointName;  

------------------------------------------------
--                   pag 40
------------------------------------------------
-- Actualizar el nombre del cliente
            UPDATE Customers
            SET ContactName = @NewContactName
            WHERE CustomerID = @CustomerID;
            -- Comprobar si la actualización se realizó correctamente
            IF (SELECT COUNT(*) FROM Customers WHERE CustomerID = @CustomerID AND ContactName = @NewContactName) > 0
            BEGIN
                -- Actualizar el país del cliente
                UPDATE Customers
                SET Country = @NewCountry
                WHERE CustomerID = @CustomerID;
                -- Comprobar si la actualización se realizó correctamente
                IF (SELECT COUNT(*) FROM Customers WHERE CustomerID = @CustomerID AND Country = @NewCountry) > 0
                BEGIN
                    -- Confirmar la transacción
                    COMMIT TRANSACTION;
                    -- Establecer el valor de retorno en 1 (éxito)
                    SET @Result = 1;
                END
                ELSE   

------------------------------------------------
--                   pag 41
------------------------------------------------
BEGIN
                    -- Deshacer la transacción hasta el punto de guardado
                    ROLLBACK TRANSACTION @SavepointName;
                    -- Establecer el valor de retorno en 0 (fracaso)
                    SET @Result = 0;
                END
            END
            ELSE
            BEGIN
                -- Deshacer la transacción completa
                ROLLBACK TRANSACTION;
                -- Establecer el valor de retorno en 0 (fracaso)
                SET @Result = 0;
            END
        END
        ELSE
        BEGIN
            -- No se guarda el punto de guardado
            -- Actualizar el nombre del cliente sin guardar el punto de guardado
            UPDATE Customers
            SET ContactName = @NewContactName
            WHERE CustomerID = @CustomerID; 

------------------------------------------------
--                   pag 42
------------------------------------------------
-- Comprobar si la actualización se realizó correctamente
            IF (SELECT COUNT(*) FROM Customers WHERE CustomerID = @CustomerID AND ContactName = @NewContactName) > 0
            BEGIN
                -- Confirmar la transacción
                COMMIT TRANSACTION;
                -- Establecer el valor de retorno en 1 (éxito)
                SET @Result = 1;
            END
            ELSE
            BEGIN
                -- Deshacer la transacción completa
                ROLLBACK TRANSACTION;
                -- Establecer el valor de retorno en 0 (fracaso)
                SET @Result = 0;
            END
        END
    END TRY
    BEGIN CATCH
        -- Deshacer la transacción completa
        ROLLBACK TRANSACTION;
        -- Obtener el mensaje de error
        SET @ErrorMessage = ERROR_MESSAGE(); 

------------------------------------------------
--                   pag 43
------------------------------------------------
-- Registrar el error en una tabla de registro de errores (por ejemplo, ErrorLog)
        INSERT INTO ErrorLog (ErrorMessage, ProcedureName)
        VALUES (@ErrorMessage, 'ActualizarCliente');
        -- Establecer el valor de retorno en -1 (error)
        SET @Result = -1;
    END CATCH;
    -- Devolver el valor de retorno
    RETURN @Result;
END;
