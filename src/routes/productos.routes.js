import { Router } from "express";
import {
  createProduct,
  deleteProduct,
  getProduct,
  getProducts,
  updateProduct,
} from "../controllers/productos.controllers.js";

const router = Router();

//rutas de productos
router.get("/productos", getProducts);
router.get("/productos/:ID_producto", getProduct);
router.post("/productos", createProduct);
router.put("/productos/:ID_producto", updateProduct);
router.delete("/productos/:ID_producto", deleteProduct);

export default router;
