import express, { Application, Request, Response } from "express";
import cors from "cors";
import dotenv from "dotenv";
import helmet from "helmet";
import morgan from "morgan";
import compression from "compression";
import path from "path";
// import * as Sentry from "@sentry/node";
// import { nodeProfilingIntegration } from "@sentry/profiling-node";

import { errorMiddleware } from "./middlewares/error.middleware";
import routes from "./routes"; // your general routes
import { setupExpressErrorHandler } from "@sentry/node";
// import tickpayRoutes from "./modules/bnpl/routes/tickpay.routes";
import { errorHandler } from "./modules/bnpl/middlewares/error.middleware";




dotenv.config();

const app: Application = express();

// ===== Sentry Initialization =====
// Sentry.init({
//  dsn: process.env.SENTRY_DSN,
//  sendDefaultPii: true,
//  integrations: [nodeProfilingIntegration()],
//  tracesSampleRate: 1.0,
//  profilesSampleRate: 1.0,
//  enableLogs: true,
// });

// ===== Middlewares =====
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(express.json({
  verify: (req: any, _res, buf) => { req.rawBody = buf; },
}));
app.use(express.urlencoded({ extended: true }));
app.use(morgan("dev"));

// ===== Sentry Request Handler =====
// app.use(Sentry.Handlers.requestHandler());
//app.use(Sentry.Handlers.tracingHandler());

// ===== Routes =====
app.use("/api", routes);

// ===== Health Check =====
app.get("/health", (_req: Request, res: Response) => {
  res.status(200).json({ status: "ok" });
});

// ===== Serve Flutter Web App =====
const publicDir = path.join(__dirname, "..", "public");
app.use(express.static(publicDir));
// SPA fallback — send index.html for any non-API route
app.get("*", (_req: Request, res: Response) => {
  res.sendFile(path.join(publicDir, "index.html"));
});

// ===== Sentry Error Handler =====
setupExpressErrorHandler(app);

// ===== Global Error Middleware =====
app.use(errorMiddleware);
app.use(errorHandler);

export default app;