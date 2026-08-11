import express, { Application, Request, Response } from "express";
import cors from "cors";
import dotenv from "dotenv";
import helmet from "helmet";
import morgan from "morgan";
import compression from "compression";
import path from "path";
import fs from "fs";
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
// Only present on hosts that carry the bundled public/ dir (e.g. EB). On
// serverless deploys (Vercel) it isn't in the function bundle — the Flutter
// web app is deployed separately there (see chronos/vercel.json) — so this
// falls back to a plain 404 instead of crashing on a missing file.
const publicDir = path.join(__dirname, "..", "public");
const publicIndexHtml = path.join(publicDir, "index.html");
const hasPublicDir = fs.existsSync(publicIndexHtml);
if (hasPublicDir) {
  app.use(express.static(publicDir));
}
// SPA fallback — send index.html for any non-API route
// Express 5's router (path-to-regexp v8) rejects a bare "*"; named wildcard required.
app.get("/*splat", (_req: Request, res: Response) => {
  if (hasPublicDir) {
    res.sendFile(publicIndexHtml);
  } else {
    res.status(404).json({ error: "Not found" });
  }
});

// ===== Sentry Error Handler =====
setupExpressErrorHandler(app);

// ===== Global Error Middleware =====
app.use(errorMiddleware);
app.use(errorHandler);

export default app;