# Panther

# 🐆 Panther Mobile App Backend Documentation

[](Panther/Untitled%202aeed62a3eb480bdb2cafea5a88f23c2.md)

## 1️⃣ Purpose

This backend module connects the **Chronos mobile app** to the AI engine (Panther), stores and serves AI insights, handles user interactions, and provides endpoints for analytics and predictive features.

**Scope:**

- REST APIs for mobile frontend
- Database schema for AI profiles, insights, logs
- Authentication and authorization
- Integration points with AI engine (Python FastAPI Panther)
- Logging and error handling

---

## 2️⃣ Folder Structure

```
/panther-backend
│
├── /src
│   ├── /controllers        # API handlers for mobile app requests
│   ├── /services           # Logic to communicate with AI engine
│   ├── /routes             # Express route definitions
│   ├── /models             # Prisma models: AIProfile, AIInsight, AILog
│   ├── /middlewares        # Auth, logging, error handling
│   ├── /config             # Environment variables, constants
│   ├── /utils              # Encryption, validation helpers
│   └── /integrations       # Connectors to external APIs (market data, etc.)
│
├── prisma/schema.prisma     # Database schema
├── tests/                   # Unit & integration tests
├── .env.example             # Environment variables template
├── package.json
├── tsconfig.json
└── server.ts                # Entry point

```

---

## 3️⃣ Tech Stack

| Component | Technology |
| --- | --- |
| Runtime | Node.js (TypeScript) |
| Framework | Express.js |
| ORM | Prisma (PostgreSQL) |
| Auth | JWT + Chronos 3rd party biometric integration |
| AI Communication | REST API to Python FastAPI (Panther engine) |
| Logging | Winston |
| Security | HTTPS, AES-256, input validation |
| Cloud | AWS ECS / Lambda + RDS |
| Queue | AWS SQS / Kafka (optional for high-volume events) |

---

## 4️⃣ Environment Variables

| Variable | Description |
| --- | --- |
| `DATABASE_URL` | PostgreSQL connection string |
| `AI_ENGINE_URL` | URL of Panther AI engine |
| `JWT_SECRET` | JWT signing secret |
| `ENCRYPTION_KEY` | AES encryption key for sensitive data |
| `LOG_LEVEL` | Logging verbosity |

---

## 5️⃣ Database Schema (Prisma)

```
model AIProfile {
  id          String   @id @default(uuid())
  userId      String   @unique
  preferences Json?
  riskLevel   String?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
}

model AIInsight {
  id          String   @id @default(uuid())
  userId      String
  type        String
  content     Json
  createdAt   DateTime @default(now())
  expiresAt   DateTime?
}

model AILog {
  id          String   @id @default(uuid())
  userId      String?
  action      String
  payload     Json?
  createdAt   DateTime @default(now())
}

```

> Notes:
>
> - `AIProfile` stores user preferences and risk profile
> - `AIInsight` stores recommendations or AI-generated insights
> - `AILog` tracks requests, responses, and events for debugging

---

## 6️⃣ API Endpoints (Mobile App Integration)

| Method | Endpoint | Description |
| --- | --- | --- |
| `POST` | `/api/panther/analyze` | Analyze user data (transactions, portfolio) |
| `POST` | `/api/panther/predict` | Predict trends for investments, spending, health goals |
| `GET` | `/api/panther/insights/:userId` | Get AI insights for a user |
| `POST` | `/api/kevin/chat` | Mobile chat requests to Kevin agent |
| `POST` | `/api/panther/context` | Update AI context for personalized experience |
| `GET` | `/api/panther/health` | Service health check |

**Example Request Flow:**

1. Mobile user sends a query via chat → `/api/kevin/chat`.
2. Backend authenticates user using JWT.
3. Backend forwards request to Panther engine → `/analyze` or `/predict`.
4. Engine returns insights → backend stores log & insight → returns to mobile app.

---

## 7️⃣ Services Structure

- `PantherService`: handles communication with AI engine
- `InsightsService`: fetches, stores, and caches AI insights
- `ContextService`: manages Kevin’s session and context per user
- `LogService`: logs all AI-related actions

---

## 8️⃣ Middleware

- **AuthMiddleware**: verifies JWT + optional biometric token
- **ErrorHandler**: formats and logs errors
- **LoggerMiddleware**: logs API requests and responses

---

## 9️⃣ Integration Notes

- The backend **does not train or run AI models**. It only passes data and receives insights.
- For security, sensitive user data is encrypted before sending to AI engine.
- Panther engine endpoints can return multiple insights → backend decides what to persist in DB.

---

## 10️⃣ Setup Instructions

```bash
git clone https://github.com/chronos/panther-backend.git
cd panther-backend
npm install
cp .env.example .env
# Fill environment variables
npx prisma migrate dev
npm run dev

```

---

## 11️⃣ Responsibilities for Backend Engineer

| Task | Description |
| --- | --- |
| API Development | Build endpoints for mobile app to communicate with Panther |
| Database | Prisma schema, migration, insights, and logs storage |
| Security | JWT, encryption, rate-limiting |
| Logging & Error Handling | Centralized logging and error reporting |
| Testing | Unit & integration tests for mobile API endpoints |
