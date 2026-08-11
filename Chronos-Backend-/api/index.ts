// Vercel serverless entrypoint for the Main API. Vercel calls the default
// export directly as a (req, res) handler — an Express app already has that
// shape, so no adapter is needed. Local dev still goes through src/server.ts
// (app.listen); this file must never call listen().
import app from "../src/app";

export default app;
