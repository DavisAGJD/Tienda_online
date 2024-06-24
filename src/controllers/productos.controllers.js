import { getConnection } from "../database/conexion.js";
import sql from "mssql";

//funciones para hacer funcionar las rutas
export const getProducts = async (req, res) => {
  const pool = await getConnection();

  const result = await pool.request().query("SELECT * FROM Productos");
  res.status(200).json(result.recordset);
};

export const getProduct = async (req, res) => {
  console.log(req.params.ProductoID);

  const pool = await getConnection();
  const result = await pool
    .request()
    .input("ProductoID", sql.Int, req.params.ProductoID)
    .query("SELECT * FROM Productos WHERE ProductoID = @ProductoID");
  console.log(result);

  if (result.rowsAffected[0] === 0) {
    return res.status(404).json({ message: "Product not found " });
  }

  return res.status(200).json(result.recordset[0]);
};

export const createProduct = async (req, res) => {
  console.log(req.body);

  const pool = await getConnection();
  const result = await pool
    .request()
    .input("Nombre", sql.VarChar, req.body.Nombre)
    .input("Precio", sql.Decimal, req.body.Precio)
    .input("Stock", sql.Int, req.body.Stock)
    .query(
      "INSERT INTO productos (Nombre, Precio, Stock) VALUES (@Nombre, @Precio, @Stock); SELECT SCOPE_IDENTITY() AS ProductoID"
    );
  console.log(result);
  res.status(200).json({
    ProductoID: result.recordset[0].ProductoID,
    Nombre: req.body.Nombre,
    Precio: req.body.Precio,
    Inventario: req.body.Stock,
  });
};

export const updateProduct = async (req, res) => {
  const pool = await getConnection();
  const result = await pool
    .request()
    .input("ProductoID", sql.Int, req.params.ProductoID)
    .input("Nombre", sql.VarChar, req.body.Nombre)
    .input("Precio", sql.Decimal, req.body.Precio)
    .input("Stock", sql.Int, req.body.Stock)
    .query(
      "UPDATE productos SET Nombre = @Nombre, Precio = @Precio, Stock = @Stock WHERE ProductoID = @ProductoID"
    );

  console.log(result);
  if (result.rowsAffected[0] === 0) {
    return res.status(404).json({ message: "Product not found" });
  }

  res.status(200).json({
    ProductoID: req.params.ProductoID,
    Nombre: req.body.Nombre,
    Precio: req.body.Precio,
    Stock: req.body.Stock,
  });
};

export const deleteProduct = async (req, res) => {
  const pool = await getConnection();
  const result = await pool
    .request()
    .input("ProductoID", sql.Int, req.params.ProductoID)
    .query("DELETE FROM Productos WHERE ProductoID = @ProductoID ");

  console.log(result);
  if (result.rowsAffected[0] === 0) {
    return res.status(404).json({ message: "Product not found " });
  }

  return res.status(200).json({ message: "Product deleteds " });
};
