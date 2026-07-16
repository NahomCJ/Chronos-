import express, { Application, Request, Response } from "express";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";
import helmet from "helmet";
import morgan from "morgan";
import compression from "compression";
import * as Sentry from "@sentry/node";
import { nodeProfilingIntegration } from "@sentry/profiling-node";

import { errorMiddleware } from "./middlewares/error.middleware";
import routes from "./routes"; // your general routes
import exchangeModule from "./modules/exchange/exchange.module"; // the exchange module
import { setupExpressErrorHandler } from "@sentry/node";

dotenv.config();

const app: Application = express();

// ===== Sentry Initialization =====
Sentry.init({
  dsn: process.env.SENTRY_DSN,
  sendDefaultPii: true,
  integrations: [nodeProfilingIntegration()],
  tracesSampleRate: 1.0,
  profilesSampleRate: 1.0,
  enableLogs: true,
});

// ===== Middlewares =====
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan("dev"));

// ===== Sentry Request Handler =====
app.use(Sentry.Handlers.requestHandler());
app.use(Sentry.Handlers.tracingHandler());

// ===== Routes =====
app.use("/api", routes);
app.use("/api", exchangeModule);

// ===== Health Check =====
app.get("/health", (_req: Request, res: Response) => {
  res.status(200).json({ status: "ok" });
});

// ===== Sentry Error Handler =====
setupExpressErrorHandler(app);

// ===== Global Error Middleware =====
app.use(errorMiddleware);

// ===== Connect to MongoDB and Start Server =====
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || "mongodb://localhost:27017/chronos";

mongoose
  .connect(MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  } as mongoose.ConnectOptions)
  .then(() => {
    console.log("✅ MongoDB connected");
    app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
  })
  .catch((err) => {
    console.error("❌ MongoDB connection error:", err);
  });

export default app;
