"""
CHRONOS API — Backend gateway for the Chronos fintech platform.

Boots a FastAPI server with /health and /api/authorize-payment endpoints.
Routers for Chris chat, transaction queries, etc. will be added in future sprints.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware

from core.logger import log
from routers.payment_authorization.router import router as payment_router
from routers.chris_chat.router import router as chris_router
from routers.transactions.router import router as transactions_router
from routers.webhooks.plaid import router as plaid_webhook_router
from routers.insights.router import router as insights_router
from routers.income.router import router as income_router
from routers.liabilities.router import router as liabilities_router
from routers.net_worth.router import router as net_worth_router
from routers.plaid.router import router as plaid_router
from routers.voice.router import router as voice_router
from routers.financial_advisor.router import router as financial_advisor_router
from routers.receipts.router import router as receipts_router

app = FastAPI(
    title="CHRONOS API",
    description="Backend gateway for the Chronos fintech platform",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # TODO: Lock down in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Gzip responses above 500 bytes (JSON payloads from insights/transactions/etc.).
# Starlette's GZipMiddleware negotiates via the client's Accept-Encoding header
# and only compresses when gzip is accepted, so it never double-compresses.
app.add_middleware(GZipMiddleware, minimum_size=500)


@app.get("/health")
def health_check():
    """Liveness probe. Returns {"status": "ok"} when the server is up."""
    return {"status": "ok"}


app.include_router(payment_router, prefix="/api")
app.include_router(chris_router, prefix="/api")
app.include_router(voice_router, prefix="/api")
app.include_router(transactions_router)
app.include_router(plaid_webhook_router)
# plaid_router already declares prefix="/api/plaid" on itself — no extra
# "/api" prefix here, or routes would double up to /api/api/plaid/*.
app.include_router(plaid_router)
app.include_router(insights_router, prefix="/api")
app.include_router(income_router, prefix="/api")
app.include_router(liabilities_router, prefix="/api")
app.include_router(net_worth_router, prefix="/api")
app.include_router(financial_advisor_router, prefix="/api")
app.include_router(receipts_router, prefix="/api")

log.phase("server_started", module="main")
