USE webstore;

CREATE INDEX idx_Productos_Nombre ON Productos(Nombre);
CREATE INDEX idx_Clientes_Email ON Clientes(Email);
CREATE INDEX idx_Pedidos_FechaPedido ON Pedidos(FechaPedido);

-- Vista de Clientes con sus Pedidos
CREATE VIEW VistaClientePedidos AS
SELECT c.ClienteID, c.Nombre AS NombreCliente, p.PedidoID, p.FechaPedido, p.Total, p.Estado
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID;


CREATE TYPE DetallesPedidoType AS TABLE (
    ProductoID INT,
    Cantidad INT
);


-- Procedimiento almacenado para registrar un pedido
CREATE PROCEDURE RegistrarPedido
    @ClienteID INT,
    @DetallesPedido DetallesPedidoType READONLY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    DECLARE @PedidoID INT;
    DECLARE @ProductoID INT;
    DECLARE @Cantidad INT;
    DECLARE @PrecioUnitario DECIMAL(10, 2);
    DECLARE @Subtotal DECIMAL(10, 2);
    DECLARE @Total DECIMAL(10, 2) = 0;

    -- Insertar en la tabla Pedidos
    INSERT INTO Pedidos (ClienteID, FechaPedido, Total, Estado)
    VALUES (@ClienteID, GETDATE(), 0, 'Pendiente');

    -- Obtener el ID del pedido recién insertado
    SET @PedidoID = SCOPE_IDENTITY();

    DECLARE DetallesCursor CURSOR FOR
    SELECT ProductoID, Cantidad FROM @DetallesPedido;

    OPEN DetallesCursor;
    FETCH NEXT FROM DetallesCursor INTO @ProductoID, @Cantidad;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Validar disponibilidad del producto
        IF EXISTS (SELECT 1 FROM Productos WHERE ProductoID = @ProductoID AND Stock >= @Cantidad)
        BEGIN
            -- Obtener el precio del producto
            SELECT @PrecioUnitario = Precio FROM Productos WHERE ProductoID = @ProductoID;

            -- Calcular subtotal
            SET @Subtotal = @Cantidad * @PrecioUnitario;

            -- Insertar en DetallesPedido
            INSERT INTO DetallesPedido (PedidoID, ProductoID, Cantidad, PrecioUnitario, Subtotal)
            VALUES (@PedidoID, @ProductoID, @Cantidad, @PrecioUnitario, @Subtotal);

            -- Actualizar el inventario
            UPDATE Productos
            SET Stock = Stock - @Cantidad
            WHERE ProductoID = @ProductoID;

            -- Calcular el total del pedido
            SET @Total = @Total + @Subtotal;
        END
        ELSE
        BEGIN
            -- Si no hay suficiente stock, rollback y lanzar un error
            ROLLBACK TRANSACTION;
            RAISERROR ('No hay suficiente stock para el producto con ID %d', 16, 1, @ProductoID);
            RETURN;
        END

        FETCH NEXT FROM DetallesCursor INTO @ProductoID, @Cantidad;
    END

    CLOSE DetallesCursor;
    DEALLOCATE DetallesCursor;

    -- Actualizar el total en la tabla Pedidos
    UPDATE Pedidos
    SET Total = @Total
    WHERE PedidoID = @PedidoID;

    COMMIT TRANSACTION;

    -- Devolver el ID del pedido
    SELECT @PedidoID AS PedidoID;
END;


-- Disparador para auditoría de cambios en la tabla Productos
CREATE TRIGGER DisparadorAuditoriaProductos
ON Productos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Operacion NVARCHAR(50);
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        IF EXISTS (SELECT * FROM deleted)
            SET @Operacion = 'UPDATE';
        ELSE
            SET @Operacion = 'INSERT';
    END
    ELSE
        SET @Operacion = 'DELETE';

    INSERT INTO Auditoria (FechaHora, TablaAfectada, TipoOperacion, Descripcion)
    VALUES (GETDATE(), 'Productos', @Operacion, 'Se realizó una operación ' + @Operacion + ' en la tabla Productos');
END;

select * from DetallesPedido
