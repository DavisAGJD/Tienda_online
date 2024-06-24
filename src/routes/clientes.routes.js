import { Router } from "express";
import { getPedidosPorCliente } from "../controllers/Clientes.controllers.js";

const router = Router();

router.get("/clientes/:ClienteID", getPedidosPorCliente);

export default router;
