# Database Schema

**File:** `prisma/schema.prisma`  
**Database:** PostgreSQL  
**ORM:** Prisma 6

---

## Model Map

### Auth & Users

| Model | Key fields | Relations |
|-------|-----------|-----------|
| `User` | id, email, password, role, tier | → BankingProfile, Account, CryptoWallet, trades, ... |

### Core Banking

| Model | Key fields | Relations |
|-------|-----------|-----------|
| `BankingProfile` | userId, status, kycVerified, riskLevel, plaidIdvId, plaidAccessToken | → User, Account[] |
| `Account` | userId, accountNumber, type, status, tier | → User, Wallet[], BankingProfile |
| `Wallet` | accountId, currency, type, status | → Account, LedgerEntry[], Transfer[] |
| `CoreTransaction` | userId, type, status, reference | → LedgerEntry[], Transfer |
| `LedgerEntry` | transactionId, walletId, direction, amount, currency | → CoreTransaction, Wallet |
| `Transfer` | userId, fromWalletId, toWalletId, amount, currency, fee | → CoreTransaction, Wallet |
| `Card` | accountId, brand, last4, type, status | → Account, Wallet |
| `FxOrder` | userId, fromWalletId, toWalletId, side, rate, status | → User, Wallet |
| `ExchangeRate` | baseCurrency, quoteCurrency, rate, provider | — |
| `Currency` | code, name, symbol, isActive | — |
| `IdempotencyKey` | key, userId, requestHash, response | — |
| `BillPayment` | userId, providerId, amount, reference, status | → User, BillProvider |
| `BillProvider` | name, category | → BillPayment[] |

### TickPay (BNPL)

| Model | Key fields | Relations |
|-------|-----------|-----------|
| `TickPayOnboarding` | userId, employmentStatus, monthlySalary, score, recommendedLimit | → User |
| `TickPayAccount` | userId, creditLimit, balance, available, status | → User, TickPayTransaction[] |
| `TickPayTransaction` | tickPayAccountId, type, status, amount, merchant | → TickPayAccount, TickPayFeeInstallment[] |
| `TickPayFeeInstallment` | tickPayAccountId, amount, status, dueDate | → TickPayAccount, TickPayTransaction |
| `TickPayCard` | cardId, tickPayAccountId | → Card, TickPayAccount |
| `TickPayAudit` | accountId, actorId, action, payload | — |

### BlockHub (Crypto)

| Model | Key fields | Relations |
|-------|-----------|-----------|
| `CryptoWallet` | userId, paxosCustomerId, paxosWalletId | → User |
| `Trade` | userId, asset, side, amountUsd, amountCrypto, fee, paxosOrderId, status | → User, Revenue[] |
| `PortfolioHolding` | userId, asset, amount, avgPrice | → User |
| `Revenue` | userId, tradeId, type, amount, asset | → User, Trade |
| `AuditLog` | userId, action, amount, asset, metadata | → User |

### LifeX — Education

| Model | Key fields | Relations |
|-------|-----------|-----------|
| `Course` | provider, title, url, price | → Enrollment[] |
| `Enrollment` | userId, courseId, status, progress | → User, Course |
| `Scholarship` | provider, title, amount, deadline | → ScholarshipApplication[] |
| `ScholarshipApplication` | userId, scholarshipId, status | → User, Scholarship |
| `Tutor` | name, subjects, rating, pricePerHour | → TutorSession[] |
| `TutorSession` | tutorId, userId, scheduledAt, status | → Tutor, User |
| `StudentLoan` | userId, lender, principal, outstanding, status | → User |

### LifeX — Financial

| Model | Key fields | Relations |
|-------|-----------|-----------|
| `FinancialPlan` | userId, goalName, targetAmount, savedAmount, frequency | → User |
| `Transaction` | userId, accountId, type, category, amount | → User |
| `Loan` | userId, name, principalAmount, interestRate, status | → User |
| `InvestmentAdvice` | userId, riskProfile, recommendedAssets | → User |
| `CreditScore` | userId, score, provider | → User |
| `Budget` | userId, category, limit, period | — |

### LifeX — Health

| Model | Key fields | Relations |
|-------|-----------|-----------|
| `HealthMetric` | userId, metricType, value, unit | — |
| `FitnessSession` | userId, type, duration, caloriesBurned | — |
| `DietLog` | userId, mealType, calories, nutrients | — |
| `HsaAccount` | userId, balance, contributions, withdrawals | — |
| `HsaTransaction` | hsaAccountId, type, amount | — |
| `MedicalRecord` | userId, recordType, documentUrl | — |
| `Habit` | userId, title, type, frequency, reminders | → User |

### LifeX — Vision

| Model | Key fields | Relations |
|-------|-----------|-----------|
| `VisionBoard` | userId, title, imageUrls | — |
| `LongTermGoal` | userId, title, category, status | → Milestone[] |
| `Milestone` | goalId, title, dueDate, status | → LongTermGoal |
| `HabitTracker` | userId, habitName, frequency, status | — |
| `MentorshipProgram` | title, mentorId, schedule, status | — |
| `CommunityGroup` | name, category, members | — |

### Notifications

| Model | Key fields | Relations |
|-------|-----------|-----------|
| `Notification` | userId, type, content, scheduledAt, status | — |
| `WellnessProgram` | title, provider, schedule, status | — |
| `GymPartner` | name, location, offer, qrCode | — |

---

## Key Enums

| Enum | Values |
|------|--------|
| `Role` | USER, ADMIN |
| `AccountStatus` | DRAFT, PENDING, APPROVED, REJECTED, SUSPENDED |
| `RiskLevel` | LOW, MEDIUM, HIGH |
| `WalletType` | FIAT, CRYPTO, STABLECOIN, SYSTEM, ESCROW, SETTLEMENT, FEE_POOL |
| `CoreTransactionType` | DEPOSIT, WITHDRAWAL, TRANSFER, PURCHASE, PAYMENT, REPAYMENT, FEE, ADJUSTMENT |
| `TransactionStatus` | INITIATED, PENDING, COMPLETED, FAILED, CANCELLED |
| `LedgerDirection` | DEBIT, CREDIT |
| `TradeSide` | BUY, SELL |
| `TradeStatus` | PENDING, FILLED, FAILED |
| `RevenueType` | TRADE_FEE, SPREAD |
| `TickPayAccountStatus` | ACTIVE, SUSPENDED, CLOSED |
| `TickPayFeeStatus` | SCHEDULED, DUE, PAID, MISSED, CANCELLED, WAIVED |

---

## Migration Workflow

```bash
# After editing schema.prisma:
npx prisma migrate dev --name describe_your_change
npx prisma generate

# Never edit migration files manually
# Never run prisma migrate deploy in dev — use migrate dev
```
