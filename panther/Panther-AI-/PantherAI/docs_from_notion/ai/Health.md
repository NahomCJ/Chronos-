# Health

## **1. Overview**

The **Health Life module** is designed to help users **track, improve, and maintain their physical and mental health**. It focuses on **fitness, diet, medical tracking, HSA accounts, doctor visits, preventive care, and wellness programs**.

**Key Goals:**

- Enable users to monitor health metrics (weight, sleep, steps, calories, vitals).
- Integrate Health Savings Accounts (HSA) for financial wellness related to health.
- Provide AI-driven recommendations for fitness, diet, and wellness.
- Connect users with gyms, wellness programs, health products, and telemedicine services.

---

## **2. Features**

| Feature | Description | Backend Requirements | Notes |
| --- | --- | --- | --- |
| Health Dashboard | Overview of health metrics, progress, and upcoming activities | health_metrics table, aggregated data | Include weight, BMI, steps, calories, sleep |
| Fitness Tracker | Track workouts, steps, and physical activity | fitness_sessions table, device sync | Integration with Apple Health, Google Fit, Fitbit |
| Diet & Nutrition | Log meals, track calories and nutrients | diet_logs table, AI nutrition recommendations | AI suggests meal plans |
| Health Savings Account (HSA) | Track HSA balance, contributions, payments | hsa_account table, transactions | Integrates with core banking TickPay for contributions |
| Medical Records | Store medical history, prescriptions, appointments | medical_records table, encrypted storage | HIPAA-compliant |
| Preventive Care | Schedule checkups, vaccinations, reminders | preventive_care table, notifications | AI can suggest preventive actions based on age & health |
| Telemedicine | Connect with doctors online | telemedicine table, session booking, messaging | Optional integration with telehealth providers |
| Wellness Programs | Yoga, meditation, fitness challenges | wellness_program table, enrollment | Optional integration with external providers |
| Gym Partnerships | Discounts, access to gyms | partners table, offer table | Supports QR codes or digital passes |
| Product Marketplace | Health products, supplements | product table, payment integration | Optional partner integration |
| AI Health Insights | Personalized recommendations for fitness, diet, wellness | AI integration, health metrics | Predict trends, suggest adjustments |
| Habit Tracker | Daily health-related habits (water, sleep, exercise) | habits table, progress updates, reminders | AI can suggest new habits |
| Reports & Analytics | Weekly/monthly health reports | analytics table, reporting engine | Can be exported or shared with doctor/coach |
| Notifications & Reminders | Alerts for workouts, meals, appointments | notification table, cron jobs | Push/email notifications |

---

## **3. Database Structure**

**Tables & Models:**

1. **health_metrics**
    - id: uuid
    - user_id: fk User.id
    - metric_type: enum (weight, sleep, steps, calories, heart_rate)
    - value: float
    - unit: string
    - recorded_at: datetime
2. **fitness_sessions**
    - id: uuid
    - user_id: fk User.id
    - type: enum (gym, run, swim, cycling, yoga)
    - duration: int (minutes)
    - calories_burned: float
    - recorded_at: datetime
3. **diet_logs**
    - id: uuid
    - user_id: fk User.id
    - meal_type: enum (breakfast, lunch, dinner, snack)
    - calories: float
    - nutrients: json
    - logged_at: datetime
4. **hsa_account**
    - id: uuid
    - user_id: fk User.id
    - balance: float
    - contributions: float
    - withdrawals: float
    - transactions: relation to hsa_transaction table
    - created_at, updated_at
5. **hsa_transaction**
    - id: uuid
    - hsa_account_id: fk HSA.id
    - type: enum (deposit, withdrawal, payment)
    - amount: float
    - currency: string
    - date: datetime
6. **medical_records**
    - id: uuid
    - user_id: fk User.id
    - record_type: enum (diagnosis, prescription, lab, vaccination)
    - description: text
    - document_url: string
    - recorded_at: datetime
7. **wellness_programs**
    - id: uuid
    - title: string
    - description: text
    - provider: string
    - schedule: datetime
    - status: enum (active, completed, canceled)
8. **gym_partners**
    - id: uuid
    - name: string
    - location: string
    - offer: text
    - QR_code: string
9. **notifications**
    - id: uuid
    - user_id: fk User.id
    - type: string
    - content: text
    - scheduled_at: datetime
    - status: enum (pending, sent, failed)

---

## **4. Backend Responsibilities**

- **API Endpoints**:
    - `GET /health/dashboard` – return health overview with metrics and reminders
    - `GET /health/metrics` – fetch recorded health metrics
    - `POST /health/metrics` – record new metric
    - `GET /health/fitness` – list workouts
    - `POST /health/fitness` – log new workout
    - `GET /health/diet` – list meal logs
    - `POST /health/diet` – log new meal
    - `GET /health/hsa` – fetch HSA account details
    - `POST /health/hsa/deposit` – add funds
    - `POST /health/hsa/withdraw` – withdraw funds
    - `GET /health/medical` – list medical records
    - `POST /health/medical` – add medical record
    - `GET /health/wellness` – list programs
    - `POST /health/wellness/enroll` – enroll in program
    - `GET /health/gyms` – list partner gyms and offers
    - `POST /health/habit` – log habit
    - `GET /health/reports` – generate analytics reports
    - `GET /health/notifications` – fetch upcoming reminders
- **Scheduled Jobs / Cron Tasks**:
    - Daily reminders for workouts, meals, HSA contributions
    - Weekly AI analysis of fitness & diet trends
- **Security & Compliance**:
    - HIPAA for medical records
    - GDPR for personal data
- **AI Integration**:
    - Suggest workouts, diet plans, preventive care tips
    - Predict health trends based on metrics

---

## **5. Integration Points**

- **Device & Fitness APIs**: Apple Health, Google Fit, Fitbit
- **Telemedicine Providers**: Optional integration for online appointments
- **Gym Partnerships**: Discounts, QR access, passes
- **Product Marketplace**: Health products, supplements, gym equipment
- **AI Engine**: Personalized insights and recommendations
- **HSA**: Integration with TickPay/core banking for deposits/withdrawals

---

## **6. Folder & Module Structure**

```
src/
 ├─ lifex/
 │   ├─ health/
 │   │   ├─ health.controller.ts
 │   │   ├─ health.service.ts
 │   │   ├─ health.routes.ts
 │   │   ├─ health.module.ts
 │   │   ├─ dto/
 │   │   │    ├─ logMetric.dto.ts
 │   │   │    ├─ createFitnessSession.dto.ts
 │   │   │    └─ ...
 │   │   ├─ entities/
 │   │   │    ├─ HealthMetric.entity.ts
 │   │   │    ├─ FitnessSession.entity.ts
 │   │   │    ├─ DietLog.entity.ts
 │   │   │    ├─ HsaAccount.entity.ts
 │   │   │    ├─ HsaTransaction.entity.ts
 │   │   │    └─ ...
 │   │   └─ utils/
 │   │        ├─ aiIntegration.ts
 │   │        ├─ scheduler.ts
 │   │        └─ notifications.ts

```

---

## **7. Recommended Pages for Mobile App (Health Life)**

| Page | Description |
| --- | --- |
| Health Dashboard | Overview of metrics, upcoming workouts, diet, HSA balance |
| Fitness Tracker | Log workouts, steps, calories burned |
| Workout Details | Add/edit workouts |
| Diet & Nutrition | Log meals, track nutrients |
| Meal Details | Add/edit meals, AI suggestions |
| Habit Tracker | Health-related habits (water, sleep, exercise) |
| Habit Details | Update progress, set reminders |
| HSA Overview | Show balance, recent transactions |
| HSA Deposit | Add funds to HSA |
| HSA Withdrawal | Withdraw or pay for medical services |
| Medical Records | Upload/view health records |
| Wellness Programs | Browse & enroll in programs |
| Gym Partner List | View gyms & discounts |
| Gym Details | QR code or offer info |
| AI Health Insights | Personalized recommendations |
| Notifications & Reminders | View alerts and upcoming tasks |
| Reports & Analytics | Weekly/monthly health progress reports |

> Total pages: ~16–18 for end-to-end coverage
>

---

This **Health Life module** documentation is ready for developers to implement backend, mobile UI, HSA integration, AI features, and partner connections.

---
