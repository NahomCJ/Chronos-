# BlockHub AI

## **1. Overview**

Panther powers **BlockHub**, providing **intelligent trading guidance, portfolio insights, and marketplace recommendations** for crypto and NFTs.

**Purpose:**

- Enhance user experience through AI-driven trading and investment insights
- Provide actionable suggestions across crypto, NFT, and wallet management
- Connect users with partner APIs for trading execution and portfolio tracking
- Enable Kevin (chat assistant) to deliver personalized BlockHub advice

**Phase 1 Focus:**

- MVP insights and recommendations (no automated trading execution initially)
- Portfolio analysis, risk scoring, price alerts, NFT suggestions

---

## **2. Architecture**

```
          ┌─────────────────────────────┐
          │        BlockHub Web/UI      │
          └─────────────┬──────────────┘
                        │
                        ▼
          ┌─────────────────────────────┐
          │       Panther Agent Layer    │
          │ ─ Market Routing Agent       │
          │ ─ Portfolio Expert Agent    │
          │ ─ NFT & Crypto Insight Agent│
          │ ─ Execution & Data Fetch    │
          └─────────────┬──────────────┘
                        │
                        ▼
       ┌────────────────────────────────────────┐
       │       BlockHub Data Layer / APIs       │
       │ - Wallets & balances                   │
       │ - Trading execution APIs               │
       │ - Portfolio management APIs            │
       │ - Market price data & feeds            │
       │ - NFT marketplace APIs                  │
       └────────────────────────────────────────┘

```

---

## **3. Panther BlockHub Agents**

| Agent | Responsibility | Description |
| --- | --- | --- |
| **Market Routing Agent** | Routes user requests to correct agent | Determines whether a query is crypto trading, NFT, portfolio analysis, or market insights |
| **Portfolio Expert Agent** | Provides portfolio overview & analysis | Suggests asset allocation, risk scoring, and diversification |
| **NFT & Crypto Insight Agent** | Analyzes market trends, NFT drops, price alerts | Offers actionable insights for investments and collectibles |
| **Execution & Data Fetch Agent** | Interfaces with APIs | Fetches wallet balances, trades, NFT metadata, market prices |

---

## **4. Key Features**

### **4.1 Crypto & NFT Portfolio Analysis**

- Shows holdings and allocation
- Calculates ROI and asset performance
- Provides diversification suggestions
- Highlights risk exposure

### **4.2 Price & Market Alerts**

- Tracks market movements
- Alerts for price thresholds or volatility
- NFT drop notifications

### **4.3 Trading & Execution Guidance**

- Suggests optimal buy/sell windows
- Provides portfolio rebalancing advice
- No autonomous execution in Phase 1
- Integration-ready for trading APIs

### **4.4 NFT Marketplace Recommendations**

- Scans partner marketplaces
- Suggests potential buys within budget
- Highlights rare or trending NFTs
- Checks BNPL eligibility if connected with TickPay

### **4.5 Risk & Volatility Scoring**

- Scores portfolio risk (1-100)
- Highlights overexposure in volatile assets
- Suggests safer allocation strategies

### **4.6 Personalized Chat Assistant (Kevin)**

- Answers user queries like:
    - “What’s my crypto portfolio value?”
    - “Should I buy this NFT?”
    - “How risky is my current allocation?”
- Fetches insights from Panther Agent Layer

---

## **5. Data Sources**

| Source | Data Access | Purpose |
| --- | --- | --- |
| Wallet balances | Partner wallet API | Portfolio tracking |
| Trading APIs | Partner broker API | Execute recommendations |
| Market feeds | CoinGecko, CoinMarketCap, etc. | Price alerts & trends |
| NFT Marketplaces | OpenSea, Rarible, etc. | NFT analysis & suggestions |
| User portfolio & transactions | BlockHub backend | Risk & ROI calculations |

---

## **6. Agent Workflows**

### **6.1 Portfolio Analysis Flow**

1. Kevin receives a request: “Analyze my crypto portfolio.”
2. Market Routing Agent directs to Portfolio Expert Agent
3. Agent fetches portfolio data via backend & wallet API
4. Calculates allocation, ROI, risk scores
5. Generates report & suggestions
6. Kevin delivers results to the user

### **6.2 NFT Recommendation Flow**

1. User asks: “Show trending NFTs in the $100-$500 range.”
2. Routing Agent identifies NFT domain
3. NFT & Crypto Insight Agent queries marketplace APIs
4. Filters by price, rarity, popularity
5. Recommends top options
6. Kevin presents actionable suggestions

---

## **7. API Integrations**

| API Type | Recommended Partners | Notes |
| --- | --- | --- |
| Wallet & Accounts | Fireblocks, BitGo | Scalable wallet management |
| Market Data | CoinGecko, CryptoCompare | Real-time prices, historical data |
| Trading Execution | Binance API, Coinbase Pro API | For buy/sell recommendations |
| NFT Marketplaces | OpenSea, Rarible | Metadata & marketplace insights |

---

## **8. Prompts & Templates**

### **Portfolio Expert Agent Prompt**

```
You are Panther — a BlockHub Portfolio Expert.
- Analyze crypto and NFT holdings.
- Provide ROI, risk scoring, and allocation recommendations.
- Suggest diversification strategies.
- Provide conservative advice based on risk levels.

```

### **NFT & Crypto Insight Agent Prompt**

```
You are Panther — a BlockHub NFT & Crypto Insight Agent.
- Monitor market trends, NFT drops, and crypto price movements.
- Suggest actionable investments within user risk tolerance.
- Highlight trending and rare NFTs within budget.

```

---

## **9. Deliverables for AI Engineer (BlockHub Focus)**

| Month | Task |
| --- | --- |
| Month 1 | Build Market Routing & Portfolio Expert Agents |
| Month 2 | Implement Portfolio Analysis, ROI, Risk Scoring |
| Month 3 | NFT & Crypto Insight Agent, marketplace integration |
| Month 4 | Price alerts, trend detection, BNPL eligibility for NFTs |
| Month 5 | Kevin chat integration, Phase 1 BlockHub MVP |

---

## **10. Summary**

**Panther x BlockHub AI** is a **modular, intelligent trading assistant** that:

- Provides portfolio analysis & risk scoring
- Monitors crypto markets & NFT marketplaces
- Suggests actionable investment insights
- Integrates with Kevin for user-facing recommendations

Phase 1 is **MVP-ready** for investor demos and testing, with **future expansions** for autonomous trading and advanced risk prediction.

---
