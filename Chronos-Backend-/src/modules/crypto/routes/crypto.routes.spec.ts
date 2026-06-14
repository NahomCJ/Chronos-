import express, { Express } from "express";
import { IncomingMessage, ServerResponse } from "http";
import { Duplex } from "stream";

const mockCryptoService = {
  getDashboard: jest.fn(),
  buy: jest.fn(),
  sell: jest.fn(),
  getHistory: jest.fn(),
  getPrice: jest.fn(),
};

const mockRequireAuth = jest.fn((req: any, _res: any, next: any) => {
  req.user = { id: "user-1" };
  next();
});

jest.mock("../../../middlewares/auth.middleware", () => ({
  requireAuth: mockRequireAuth,
}));

jest.mock("../services/crypto.service", () => ({
  __esModule: true,
  default: mockCryptoService,
}));

import cryptoRoutes from "./crypto.routes";
import { CryptoApiError } from "../services/crypto.errors";

function createApp() {
  const app = express();
  app.use(express.json());
  app.use("/api/v1/crypto", cryptoRoutes);
  return app;
}

class MockSocket extends Duplex {
  _read() {}

  _write(_chunk: unknown, _encoding: BufferEncoding, callback: (error?: Error | null) => void) {
    callback();
  }
}

async function dispatch(
  app: Express,
  options: { method: string; path: string; body?: unknown },
): Promise<{ status: number; body: any }> {
  return new Promise((resolve, reject) => {
    const payload = options.body === undefined ? undefined : JSON.stringify(options.body);
    const socket = new MockSocket() as any;
    socket.setTimeout = jest.fn();
    socket.destroy = jest.fn();
    socket.cork = jest.fn();
    socket.uncork = jest.fn();

    const req = new IncomingMessage(socket);
    req.method = options.method;
    req.url = options.path;
    req.headers = payload
      ? {
          "content-type": "application/json",
          "content-length": Buffer.byteLength(payload).toString(),
        }
      : {};

    const res = new ServerResponse(req);
    const chunks: Buffer[] = [];
    const originalWrite = res.write.bind(res);
    const originalEnd = res.end.bind(res);

    (res as any).write = (chunk: unknown, encoding?: BufferEncoding, callback?: () => void) => {
      if (chunk) {
        chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(String(chunk), encoding));
      }
      return originalWrite(chunk as any, encoding as any, callback as any);
    };

    (res as any).end = (chunk?: unknown, encoding?: BufferEncoding, callback?: () => void) => {
      if (chunk) {
        chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(String(chunk), encoding));
      }
      return originalEnd(chunk as any, encoding as any, callback as any);
    };

    res.on("finish", () => {
      const responseBody = Buffer.concat(chunks).toString("utf8");
      resolve({
        status: res.statusCode,
        body: responseBody ? JSON.parse(responseBody) : undefined,
      });
    });
    res.on("error", reject);
    socket.on("error", reject);
    res.assignSocket(socket);

    if (payload) req.push(Buffer.from(payload));
    req.push(null);
    (app as any).handle(req, res, reject);
  });
}

describe("crypto routes", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockCryptoService.getDashboard.mockResolvedValue({
      wallet: { status: "ready" },
      supported_assets: ["BTC", "ETH", "SOL", "UNI", "AAVE", "LINK"],
    });
    mockCryptoService.buy.mockResolvedValue({ trade_id: "trade-buy-1", status: "filled" });
    mockCryptoService.sell.mockResolvedValue({ trade_id: "trade-sell-1", status: "filled" });
    mockCryptoService.getHistory.mockResolvedValue({ trades: [], pagination: { page: 2, limit: 10 } });
    mockCryptoService.getPrice.mockResolvedValue({
      asset: "BTC",
      market: "BTCUSD",
      price: 65000,
      source: "paxos",
    });
  });

  it("routes GET /api/v1/crypto to the authenticated dashboard", async () => {
    const response = await dispatch(createApp(), { method: "GET", path: "/api/v1/crypto" });

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({ wallet: { status: "ready" } });
    expect(mockRequireAuth).toHaveBeenCalled();
    expect(mockCryptoService.getDashboard).toHaveBeenCalledWith("user-1");
  });

  it("routes POST /api/v1/crypto/buy with the buy payload", async () => {
    const response = await dispatch(createApp(), {
      method: "POST",
      path: "/api/v1/crypto/buy",
      body: { asset: "BTC", amount_usd: 5 },
    });

    expect(response.status).toBe(200);
    expect(mockCryptoService.buy).toHaveBeenCalledWith("user-1", {
      asset: "BTC",
      amount_usd: 5,
    });
  });

  it("returns 400 and skips service calls for invalid buy payloads", async () => {
    const response = await dispatch(createApp(), {
      method: "POST",
      path: "/api/v1/crypto/buy",
      body: { asset: "BTC", amount_usd: 4.99 },
    });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({ code: "VALIDATION_ERROR" });
    expect(mockCryptoService.buy).not.toHaveBeenCalled();
  });

  it("returns 400 for unsupported assets at the route boundary", async () => {
    const response = await dispatch(createApp(), {
      method: "POST",
      path: "/api/v1/crypto/buy",
      body: { asset: "DOGE", amount_usd: 5 },
    });

    expect(response.status).toBe(400);
    expect(response.body).toMatchObject({ code: "VALIDATION_ERROR" });
    expect(mockCryptoService.buy).not.toHaveBeenCalled();
  });

  it("routes POST /api/v1/crypto/sell with the sell payload", async () => {
    const response = await dispatch(createApp(), {
      method: "POST",
      path: "/api/v1/crypto/sell",
      body: { asset: "BTC", amount_crypto: 0.0001 },
    });

    expect(response.status).toBe(200);
    expect(mockCryptoService.sell).toHaveBeenCalledWith("user-1", {
      asset: "BTC",
      amount_crypto: 0.0001,
    });
  });

  it("routes GET /api/v1/crypto/history with pagination and filters", async () => {
    const response = await dispatch(createApp(), {
      method: "GET",
      path: "/api/v1/crypto/history?page=2&limit=10&asset=ETH",
    });

    expect(response.status).toBe(200);
    expect(mockCryptoService.getHistory).toHaveBeenCalledWith("user-1", {
      page: 2,
      limit: 10,
      asset: "ETH",
    });
  });

  it("returns 401 when authenticated routes do not receive a user", async () => {
    mockRequireAuth.mockImplementationOnce((_req: any, _res: any, next: any) => next());

    const response = await dispatch(createApp(), { method: "GET", path: "/api/v1/crypto" });

    expect(response.status).toBe(401);
    expect(response.body).toMatchObject({ code: "UNAUTHORIZED" });
    expect(mockCryptoService.getDashboard).not.toHaveBeenCalled();
  });

  it("maps CryptoApiError service failures to their public status and code", async () => {
    mockCryptoService.buy.mockRejectedValueOnce(
      new CryptoApiError("PAXOS_NOT_CONFIGURED", "Trading disabled", 503, {
        env: "sandbox",
      }),
    );

    const response = await dispatch(createApp(), {
      method: "POST",
      path: "/api/v1/crypto/buy",
      body: { asset: "BTC", amount_usd: 5 },
    });

    expect(response.status).toBe(503);
    expect(response.body).toEqual({
      code: "PAXOS_NOT_CONFIGURED",
      message: "Trading disabled",
      details: { env: "sandbox" },
    });
  });

  it("maps unexpected service failures to a generic crypto error", async () => {
    mockCryptoService.getDashboard.mockRejectedValueOnce(new Error("unexpected"));

    const response = await dispatch(createApp(), { method: "GET", path: "/api/v1/crypto" });

    expect(response.status).toBe(500);
    expect(response.body).toEqual({ code: "CRYPTO_ERROR", message: "unexpected" });
  });

  it("routes public GET /api/v1/crypto/price/:asset without auth", async () => {
    const response = await dispatch(createApp(), {
      method: "GET",
      path: "/api/v1/crypto/price/BTC",
    });

    expect(response.status).toBe(200);
    expect(mockCryptoService.getPrice).toHaveBeenCalledWith("BTC");
    expect(mockCryptoService.getDashboard).not.toHaveBeenCalled();
  });
});
