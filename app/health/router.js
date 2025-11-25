import { Router } from "express";
import { healthCheck } from "./controller.js";

const healthRouter = Router();

healthRouter.get("/", healthCheck);

export { healthRouter };
