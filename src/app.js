import express from "express";
import productRoutes from "./routes/productos.routes.js";
import pedidosRoutes from "./routes/pedidos.routes.js";
import clientesRoutes from "./routes/clientes.routes.js";

const app = express();

app.use(express.json());

app.use(productRoutes);

app.use(pedidosRoutes);
app.use(clientesRoutes);

export default app;
