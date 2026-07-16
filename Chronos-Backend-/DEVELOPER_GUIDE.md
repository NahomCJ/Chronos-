# Chronos Backend: Master Developer Guide

Welcome to the Chronos Backend codebase. This project is a multi-module banking and crypto platform designed with a hybrid architecture to support both traditional banking and advanced crypto trading.

---

## 🏗️ Architecture Overview

The project uses a **Hybrid Micro-monorepo** architecture:

1.  **Chronos Core (Express)**:
    *   **Root**: `src/`
    *   **Port**: `4000`
    *   **Tech**: Node.js, Express, TypeScript, Prisma.
    *   **Purpose**: Handles core banking (Accounts, BNPL, Auth, KYC, User Management).
    *   **Entry Point**: `src/server.ts`

2.  **Blockhub Module (NestJS)**:
    *   **Path**: `src/modules/blockhub/`
    *   **Port**: `3000`
    *   **Tech**: NestJS, TypeScript, Prisma.
    *   *Purpose**: Advanced crypto trading with Paxos Sandbox integration.
    *   **Entry Point**: `src/modules/blockhub/src/main.ts`

---

## 📂 Key Directory Structure

```text
Chronos-Backend/
├── prisma/                 # Shared Database Schema (Source of Truth)
├── src/                    # Core Express Application
│   ├── modules/            # Core Business Modules
│   │   ├── core/           # Banking Engine (Accounts, Transfers)
│   │   ├── bnpl/           # Buy Now, Pay Later (TickPay)
│   │   ├── auth/           # Identity & Authentication
│   │   ├── blockhub/       # NestJS Crypto Module (Paxos)
│   │   └── ...             # AI, Akoya, Notification modules
│   ├── app.ts              # Express App Configuration
│   └── server.ts           # Express Server Entry Point
├── package.json            # Unified Dependencies
└── tsconfig.json           # Shared TypeScript Configuration
```

---

## 🚀 Getting Started

### 1. Prerequisites
*   Node.js (v20+)
*   Docker (for Postgres/Redis)
*   Prisma CLI (`npm install -g prisma`)

### 2. Environment Setup
Copy the example environment file and fill in required secrets:
```bash
cp .env.example .env
```

### 3. Spin up Infrastructure
```bash
docker-compose up -d
```

### 4. Database Setup
```bash
npm run prisma:generate
npm run prisma:migrate
```

---

## 🛠️ Running the Application

### Option A: Run Everything (Integrated)
Currently, the two servers run on different ports but share the same database.

1.  **Start Core Express (Port 4000):**
    ```bash
    npm run dev
    ```

2.  **Start Blockhub NestJS (Port 3000):**
    ```bash
    npx ts-node src/modules/blockhub/src/main.ts
    ```

### Option B: Run Blockhub in Isolation
The Blockhub module is designed to be highly independent. You can work specifically on crypto trading logic within the `src/modules/blockhub` directory.

---

## 🧪 Testing

The project uses **Jest** for testing.

*   **Core Tests**: Found in `src/tests` or alongside Express modules.
*   **Blockhub Tests**: Found in `src/modules/blockhub/src/.../*.spec.ts`.

Run Blockhub trading tests:
```bash
npm test src/modules/blockhub/src/trading/trading.service.spec.ts
```

---

## 📜 Detailed Module Documentation
For deep dives into specific modules, see:
*   [Core Banking Engine](file:///c:/Users/Nahom/Desktop/Chronos/Business%20Plan/Chronos-Backend-/src/modules/core/CORE_BANKING.md)
*   [BNPL (TickPay)](file:///c:/Users/Nahom/Desktop/Chronos/Business%20Plan/Chronos-Backend-/src/modules/bnpl/BNPL_MODULE.md)
*   [Blockhub Crypto Trading](file:///c:/Users/Nahom/Desktop/Chronos/Business%20Plan/Chronos-Backend-/src/modules/blockhub/BLOCKHUB_GUIDE.md)

---
*Chronos Backend v1.0 — Empowering Modern Finance*
