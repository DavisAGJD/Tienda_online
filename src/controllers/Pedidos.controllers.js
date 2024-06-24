import { getConnection } from "../database/conexion.js";
import sql from "mssql";

export async function registrarPedido(req, res) {
  console.log(req.body);

  const { ClienteID, Detalles } = req.body;

  if (
    !ClienteID ||
    !Detalles ||
    !Array.isArray(Detalles) ||
    Detalles.length === 0
  ) {
    return res.status(400).json({
      error: "Solicitud inválida. ClienteID y Detalles son requeridos.",
    });
  }

  try {
    const pool = await getConnection();

    // Crear un tipo de tabla para los detalles del pedido
    const table = new sql.Table("DetallesPedidoType"); // Especificar el nombre del tipo de tabla
    table.columns.add("ProductoID", sql.Int);
    table.columns.add("Cantidad", sql.Int);

    Detalles.forEach((detalle) => {
      table.rows.add(detalle.ProductoID, detalle.Cantidad);
    });

    const request = new sql.Request();

    // Definir parámetros del procedimiento almacenado
    request.input("ClienteID", sql.Int, ClienteID);
    request.input("DetallesPedido", table);

    // Ejecutar el procedimiento almacenado
    const result = await request.execute("RegistrarPedido");

    console.log("Pedido registrado correctamente:", result);

    // Verificar el resultado y enviar respuesta
    if (result.recordset && result.recordset.length > 0) {
      res.status(200).json({
        message: "Pedido registrado correctamente.",
        PedidoID: result.recordset[0].PedidoID,
        ClienteID: ClienteID,
        DetallesPedido: Detalles,
      });
    } else {
      res.status(500).json({
        error: "No se pudo registrar el pedido correctamente.",
      });
    }
  } catch (err) {
    console.error("Error al registrar el pedido:", err.message);
    res.status(500).json({ error: "Hubo un problema al registrar el pedido." });
  } finally {
    sql.close(); // Cerrar la conexión después de la ejecución
  }
}

export const getPedido = async (req, res) => {
  console.log(req.params.PedidoID);

  const pool = await getConnection();
  const result = await pool
    .request()
    .input("PedidoID", sql.Int, req.params.PedidoID)
    .query("SELECT * FROM Pedidos WHERE PedidoID = @PedidoID");
  console.log(result);

  if (result.rowsAffected[0] === 0) {
    return res.status(404).json({ message: "Product not found " });
  }

  return res.status(200).json(result.recordset[0]);
};
