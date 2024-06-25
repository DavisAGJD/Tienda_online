CREATE DATABASE webstore;

USE webstore;

-- Tabla de Productos
CREATE TABLE Productos (
    ProductoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL
);

-- Tabla de Clientes
CREATE TABLE Clientes (
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL
);

-- Tabla de Pedidos
CREATE TABLE Pedidos (
    PedidoID INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID INT,
    FechaPedido DATETIME,
    Total DECIMAL(10, 2),
    Estado NVARCHAR(50),
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

-- Tabla de Detalles de Pedido
CREATE TABLE DetallesPedido (
    DetalleID INT IDENTITY(1,1) PRIMARY KEY,
    PedidoID INT,
    ProductoID INT,
    Cantidad INT,
    PrecioUnitario DECIMAL(10, 2),
    Subtotal DECIMAL(10, 2),
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

-- Tabla de Auditoria
CREATE TABLE Auditoria (
    AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
    FechaHora DATETIME,
    TablaAfectada NVARCHAR(100),
    TipoOperacion NVARCHAR(50),
    Descripcion NVARCHAR(MAX)
);

INSERT INTO Clientes (Nombre, Email) VALUES
('Antonio Banderas', 'antoniobanderas@gmail.com'),
('roberto borjas', 'robertoborjas@gmail.com');

SELECT * FROM Productos 
SELECT * FROM Pedidos 
SELECT * FROM DetallesPedido