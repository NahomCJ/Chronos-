"""
CHRONOS API — Backend gateway for the Chronos fintech platform.

Boots a FastAPI server with /health and /api/authorize-payment endpoints.
Routers for Chris chat, transaction queries, etc. will be added in future sprints.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from core.logger import log
from routers.payment_authorization.router import router as payment_router
from routers.chris_chat.router import router as chris_router
from routers.transactions.router import router as transactions_router
from routers.webhooks.plaid import router as plaid_webhook_router
from routers.insights.router import router as insights_router
from routers.income.router import router as income_router
from routers.liabilities.router import router as liabilities_router
from routers.net_worth.router import router as net_worth_router
from routers.voice.router import router as voice_router

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


@app.get("/health")
def health_check():
    """Liveness probe. Returns {"status": "ok"} when the server is up."""
    return {"status": "ok"}


app.include_router(payment_router, prefix="/api")
app.include_router(chris_router, prefix="/api")
app.include_router(voice_router, prefix="/api")
app.include_router(transactions_router)
app.include_router(plaid_webhook_router)
app.include_router(insights_router, prefix="/api")
app.include_router(income_router, prefix="/api")
app.include_router(liabilities_router, prefix="/api")
app.include_router(net_worth_router, prefix="/api")

log.phase("server_started", module="main")
