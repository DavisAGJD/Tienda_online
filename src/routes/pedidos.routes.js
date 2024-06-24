import { Router } from "express";
import {
  getPedido,
  registrarPedido,
} from "../controllers/Pedidos.controllers.js";

//rutas pedido
const router = Router();

router.post("/pedidos", registrarPedido);
router.get("/pedidos/:PedidoID", getPedido);

export default router;
