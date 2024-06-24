CREATE DATABASE Negocio_online

USE Negocio_online;

-- Tabla Productos
CREATE TABLE productos (
    ID_producto INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Precio DECIMAL (10,2) NOT NULL,
    Inventario INT NOT NULL
);

-- Tabla Clientes
CREATE TABLE clientes (
    ID_cliente INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Gmail VARCHAR(50) NOT NULL,
    Telefono VARCHAR(50) NOT NULL,
    Direccion VARCHAR(50) NOT NULL
);

-- Tabla Pedidos
CREATE TABLE pedidos (
    ID_pedido INT IDENTITY(1,1) PRIMARY KEY,
    ID_cliente INT NOT NULL,
    Fecha_pedido DATETIME NOT NULL,
    Estado VARCHAR(50) NOT NULL,
    FOREIGN KEY (ID_cliente) REFERENCES clientes(ID_cliente)
);

-- Tabla Detalle_pedido
CREATE TABLE detalle_pedido (
    ID_detallepedido INT IDENTITY(1,1) PRIMARY KEY,
    ID_pedido INT NOT NULL,
    ID_producto INT NOT NULL,
    Cantidad INT NOT NULL,
    Total DECIMAL (10,2) NOT NULL,
    FOREIGN KEY (ID_pedido) REFERENCES Pedidos(ID_pedido),
    FOREIGN KEY (ID_producto) REFERENCES Productos(ID_producto)
);

-- Tabla Auditoria
CREATE TABLE auditoria (
    ID_auditoria INT IDENTITY(1,1) PRIMARY KEY,
    Tabla VARCHAR(50) NOT NULL,
    Operacion VARCHAR(50) NOT NULL,
    Fecha DATETIME NOT NULL DEFAULT GETDATE()
);
GO


--Creacion de indices para las tablas--
CREATE INDEX idx_Productos_Nombre ON productos(Nombre);
CREATE INDEX idx_Cliente_Email ON clientes(Gmail);
CREATE INDEX idx_Pedidos_FechaPedido ON pedidos(Fecha_Pedido);


--VISTA PARA PRODUCTOS--
CREATE VIEW VerProductos AS
SELECT 
    Nombre,
    Precio,
    Inventario
FROM 
    productos;
GO

--Vista para vizualizar los clientes
CREATE VIEW VistaClientePedidos AS
SELECT 
    c.ID_cliente, c.Nombre AS ClienteNombre, c.Gmail, c.Telefono, c.Direccion,
    p.ID_pedido, p.Fecha_pedido, p.Estado,
    dp.ID_producto, pr.Nombre AS ProductoNombre, dp.Cantidad, dp.Total
FROM 
    clientes c
JOIN 
    pedidos p ON c.ID_cliente = p.ID_cliente
JOIN 
    detalle_pedido dp ON p.ID_pedido = dp.ID_pedido
JOIN 
    productos pr ON dp.ID_producto = pr.ID_producto;


--Creacion de un procedimiento almacenado para registrar pedidos
CREATE PROCEDURE RegistrarPedido
    @ID_cliente INT,
    @Fecha_pedido DATETIME,
    @Estado VARCHAR(50),
    @ProductosDetalle dbo.DetallePedidoType READONLY -- Debe crear un tipo de tabla para los detalles del pedido
AS
BEGIN
    DECLARE @ID_pedido INT;
    
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Insertar el pedido
        INSERT INTO pedidos (ID_cliente, Fecha_pedido, Estado)
        VALUES (@ID_cliente, @Fecha_pedido, @Estado);

        -- Obtener el ID del pedido recién insertado
        SET @ID_pedido = SCOPE_IDENTITY();

        -- Insertar los detalles del pedido y actualizar el inventario
        INSERT INTO detalle_pedido (ID_pedido, ID_producto, Cantidad, Total)
        SELECT @ID_pedido, ID_producto, Cantidad, Total
        FROM @ProductosDetalle;

        -- Actualizar inventario de productos
        UPDATE p
        SET p.Inventario = p.Inventario - d.Cantidad
        FROM productos p
        JOIN @ProductosDetalle d ON p.ID_producto = d.ID_producto;

        -- Validar que ningún producto tenga inventario negativo
        IF EXISTS (SELECT 1 FROM productos WHERE Inventario < 0)
        BEGIN
            -- Si hay inventario negativo, se hace rollback
            RAISERROR('Inventario insuficiente para uno o más productos.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Si todo va bien, confirmar la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- En caso de error, se hace rollback
        ROLLBACK TRANSACTION;
        -- Se puede agregar más lógica para manejar el error aquí
        THROW;
    END CATCH
END



--REVISION VISTA--
SELECT * FROM VerProductos;

INSERT INTO productos (Nombre, Precio, Inventario) VALUES ('mouse',10.00, 10)
