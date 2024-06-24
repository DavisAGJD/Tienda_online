import { getConnection } from "../database/conexion.js";
import sql from "mssql";

export async function getPedidosPorCliente(req, res) {
  const { ClienteID } = req.params;

  if (!ClienteID) {
    return res
      .status(400)
      .json({ error: "Solicitud inválida. ClienteID es requerido." });
  }

  try {
    const pool = await getConnection();

    const request = new sql.Request();

    // Definir parámetros del procedimiento almacenado
    request.input("ClienteID", sql.Int, ClienteID);

    // Ejecutar la consulta para obtener los pedidos del cliente
    const result = await request.query(`
          SELECT PedidoID, FechaPedido, Total, Estado
          FROM Pedidos
          WHERE ClienteID = @ClienteID
      `);

    console.log("Pedidos del cliente obtenidos correctamente:", result);

    // Verificar el resultado y enviar respuesta
    if (result.recordset && result.recordset.length > 0) {
      res.status(200).json({
        message: "Pedidos del cliente obtenidos correctamente.",
        Pedidos: result.recordset,
      });
    } else {
      res.status(404).json({
        error: "No se encontraron pedidos para el cliente especificado.",
      });
    }
  } catch (err) {
    console.error("Error al obtener los pedidos del cliente:", err.message);
    res
      .status(500)
      .json({ error: "Hubo un problema al obtener los pedidos del cliente." });
  } finally {
    sql.close(); // Cerrar la conexión después de la ejecución
  }
}
