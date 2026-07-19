# Education

> Location: src/lifex/education/
>
>
> Purpose: manage courses, micro-courses, scholarships, student loan tracking, tutors/mentors, education goals, and partner integrations (Coursera, Udemy, LinkedIn Learning, scholarship feeds).
>

---

## 1 — Overview

**Education Life** helps users plan, discover, enroll in, and track education (micro-courses, certifications, scholarships), manage student loans, and book tutors. It integrates third-party course catalogs and scholarship feeds, and provides the AI Mentor (Kevin) with progress/skill-tracking inputs.

**Primary features (MVP):**

- Course discovery & recommendation (partner catalogs + local content)
- User learning plan & progress tracker
- Scholarship finder & application tracker
- Student loan tracker (link loans, schedule payments)
- Micro-course purchase/enrollment & completion tracking
- Tutor booking & session history
- Education goals & milestone management
- Admin endpoints for partner management & content ingestion

---

## 2 — Tech Stack & Dependencies

- Language: TypeScript / Node.js (Express or NestJS)
- DB: PostgreSQL + Prisma ORM
- Cache/Jobs: Redis + BullMQ (for scheduled notifications, course syncs)
- Search/Recommendations: Algolia or ElasticSearch (optional)
- External Integrations: Coursera/EdX/Udemy APIs, Google Calendar, Stripe (payments), Twilio/SendGrid (notifications)
- AI: Chronos AI (Kevin) via internal AI API for personalized course suggestions
- Hosting: AWS (ECS/Fargate), or GCP Cloud Run
- Tests: Jest + Supertest

---

## 3 — Folder Structure (suggested)

```
src/lifex/education/
├─ controllers/
│  ├─ courses.controller.ts
│  ├─ scholarships.controller.ts
│  ├─ loans.controller.ts
│  └─ tutors.controller.ts
├─ services/
│  ├─ courses.service.ts
│  ├─ recommendations.service.ts
│  ├─ scholarships.service.ts
│  ├─ loans.service.ts
│  └─ tutors.service.ts
├─ jobs/
│  ├─ course.sync.job.ts
│  └─ scholarship.sync.job.ts
├─ validators/
│  ├─ course.validator.ts
│  └─ loan.validator.ts
├─ models/
│  └─ prisma.ts (import)
├─ types/
│  └─ education.types.ts
├─ routes.ts
├─ education.scheduler.ts
└─ README.md

```

---

## 4 — Data Models (Prisma)

Add these to `prisma/schema.prisma` (education section):

```
model Course {
  id            String   @id @default(cuid())
  provider      String   // "coursera", "udemy", "local"
  providerId    String?  @unique // id from provider when present
  title         String
  description   String?
  url           String?
  durationHours Float?
  level         String?  // beginner/intermediate/advanced
  price         Decimal? @db.Decimal(18, 4)
  currency      String?  @default("USD")
  tags          String[] @default([])
  metadata      Json?
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  enrollments   Enrollment[]
}

model Enrollment {
  id         String   @id @default(cuid())
  userId     String
  courseId   String
  status     String   // "IN_PROGRESS","COMPLETED","PLANNED"
  progress   Float    @default(0) // 0..100
  startedAt  DateTime?
  completedAt DateTime?
  createdAt  DateTime @default(now())

  user       User     @relation(fields: [userId], references: [id])
  course     Course   @relation(fields: [courseId], references: [id])
}

model Scholarship {
  id          String   @id @default(cuid())
  provider    String
  title       String
  description String?
  url         String?
  country     String?
  amount      Decimal? @db.Decimal(18,4)
  deadline    DateTime?
  metadata    Json?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
}

model ScholarshipApplication {
  id            String   @id @default(cuid())
  scholarshipId String
  userId        String
  status        String   // "APPLIED","RECEIVED","AWARDED","DECLINED"
  appliedAt     DateTime?
  metadata      Json?
  createdAt     DateTime @default(now())

  user          User     @relation(fields: [userId], references: [id])
  scholarship   Scholarship @relation(fields: [scholarshipId], references: [id])
}

model Tutor {
  id         String   @id @default(cuid())
  name       String
  bio        String?
  subjects   String[] @default([])
  rating     Float?
  pricePerHour Decimal? @db.Decimal(18,4)
  metadata   Json?
  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt
  sessions   TutorSession[]
}

model TutorSession {
  id         String   @id @default(cuid())
  tutorId    String
  userId     String
  scheduledAt DateTime
  durationMinutes Int
  status     String   // "SCHEDULED","COMPLETED","CANCELLED"
  notes      String?
  createdAt  DateTime @default(now())

  tutor      Tutor    @relation(fields: [tutorId], references: [id])
  user       User     @relation(fields: [userId], references: [id])
}

model StudentLoan {
  id            String   @id @default(cuid())
  userId        String
  lender        String
  principal     Decimal  @db.Decimal(18,4)
  outstanding   Decimal  @db.Decimal(18,4)
  ratePercent   Float?
  dueDate       DateTime?
  status        String   // "ACTIVE","PAID","DEFAULTED"
  metadata      Json?
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt

  user          User     @relation(fields: [userId], references: [id])
}

```

> Notes: Use Decimal fields for monetary values; tags for course categorization; metadata for provider-specific JSON.
>

---

## 5 — API Endpoints (proposed)

Base: `/api/v1/lifex/education`

### Courses

- `GET /courses` — query courses (filters: provider, tags, level, priceRange, q)
- `GET /courses/:id` — course detail
- `POST /courses/sync` — admin: trigger third-party sync
- `POST /courses` — admin create local course
- `GET /courses/:id/enrollments` — list enrollments

### Enrollments

- `POST /courses/:id/enroll` — enroll current user (create Enrollment)
    - body: `{ autoEnrollExternal?: boolean }` - if true and course from provider, redirect/enroll via provider API
- `GET /enrollments` — list current user's enrollments
- `PATCH /enrollments/:id/progress` — update progress (private/internal; used by mobile)
- `POST /enrollments/:id/complete` — mark as complete (triggers certificates/awards)

### Scholarships

- `GET /scholarships` — list & filter
- `GET /scholarships/:id` — detail
- `POST /scholarships/sync` — admin sync job
- `POST /scholarships/:id/apply` — create ScholarshipApplication (note: final apply may redirect to partner URL)

### Tutors

- `GET /tutors` — search tutors (filters: subject, rating, price)
- `GET /tutors/:id` — detail
- `POST /tutors/:id/schedule` — schedule a tutor session (integrate calendar)
    - body: `{ scheduledAt, durationMinutes, paymentMethod }`
- `GET /tutors/sessions` — user sessions
- `POST /tutors/:id/review` — leave rating/review

### Student Loans

- `POST /loans/link` — link an external loan account (via Akoya or manual entry)
- `GET /loans` — list user's loans
- `POST /loans/:id/repay` — manual repayment (records only; actual money moves via Core Banking)
- `GET /loans/:id/paymentSchedule` — view amortization / schedule

---

## 6 — Business Logic & Flows

### Course discovery & recommendations

- Periodic provider sync jobs (`course.sync.job.ts`) fetch new/updated courses.
- Index new items to search engine (Algolia/Elastic) for fast search.
- `recommendations.service.ts` uses:
    - User profile (skills, goals)
    - Past enrollments & progress
    - Chronos AI signals (spending, time availability)
    - Partner promotions
- For paid courses, use Stripe to create checkout session. On success, create `Enrollment` with status `IN_PROGRESS` or `PLANNED`.

### Scholarship finder & apply

- Sync scholarship feeds daily.
- Users can `save` scholarships, `apply` (either internal form or redirect to provider).
- Track `ScholarshipApplication` status; send reminders before deadlines.

### Tutor scheduling & payments

- When user schedules, check tutor availability, create `TutorSession` with status SCHEDULED.
- Integrate calendar invites (Google Calendar) and payment (Stripe) for paid sessions.
- On `COMPLETED`, allow user to rate and record session notes.

### Loan tracking

- Link loans via data aggregator (Akoya) to fetch loan balances and payment schedules.
- Provide dashboard to view outstanding, next due dates, interest rates.
- Optionally, integrate automated repayment via Core Banking (requires authorization).

---

## 7 — Integrations (detailed)

- **Coursera / EdX / Udemy** — provider catalogs (use public APIs or partner data feeds). If provider APIs don't support direct enrollment via API, relay the user to external link and store enrollment record locally.
- **Stripe** — payments for paid courses and tutor sessions.
- **Akoya** — data aggregation for student loans (if partner supports loan accounts).
- **Algolia / ElasticSearch** — course/search index.
- **Google Calendar API** — add tutor sessions to user/tutor calendars.
- **Twilio / SendGrid** — notify user of deadlines, sessions, course launches.
- **Chronos AI (Kevin)** — for personalized course recommendations, learning plan, and progress nudges.

---

## 8 — Scheduler & Jobs

- `course.sync.job.ts` — daily or hourly sync from providers
- `scholarship.sync.job.ts` — daily scholarship ingestion
- `reminder.job.ts` — email/SMS reminders for deadlines and scheduled sessions
- `progress.analytics.job.ts` — weekly analytics to feed AI recommender

Use **BullMQ** (Redis backed) to handle retries, job concurrency, and backoff.

---

## 9 — Security & Privacy

- PII & educational records are sensitive — encrypt `metadata` at rest if it contains personal docs.
- OAuth flows for provider enrollments must be secure; store provider tokens encrypted.
- Logging should omit student personal data; use masked identifiers in logs.
- GDPR: provide data export & deletion endpoints for users’ education data.

---

## 10 — Testing

- **Unit tests**: services (courses, scholarships, tutors).
- **Integration tests**: API endpoints with test DB (Prisma SQLite) and mocked provider responses.
- **E2E tests**: enroll → payment → progress update → completion.
- **Load tests**: course sync job with bulk ingestion (simulate thousands of provider items).

---

## 11 — Metrics & Admin

Important metrics to surface:

# of active learners

- Avg completion rate per course

# of scholarships applied / awarded

- Tutor booking conversion rate
- Revenue from paid courses/tutors

Admin endpoints:

- Trigger sync jobs
- Approve/Reject tutor registration
- Curate featured courses (admin-managed flag)

---

## 12 — Sample Requests & Responses

**Search courses**

```
GET /api/v1/lifex/education/courses?q=react&tags=web,frontend&page=1
Response: { items: [ { id, title, provider, price, tags, url } ], meta: {...} }

```

**Enroll**

```
POST /api/v1/lifex/education/courses/{id}/enroll
Body: { autoEnrollExternal: false }
Response: 201 { enrollment: { id, status: 'IN_PROGRESS' } }

```

---

## 13 — Prioritized TODOs (MVP)

1. Add Prisma models and migrations for Course/Enrollment/Scholarship/Tutor/StudentLoan.
2. Implement `courses.service` (list, detail, admin create).
3. Implement provider sync job with 1 provider (Coursera or Udemy).
4. Implement `enroll` endpoint (local enroll first; later external enroll).
5. Implement scholarship sync & `apply` flow (store app state; redirect if needed).
6. Tutor listing and schedule (mock tutor dataset, integrate Google Calendar later).
7. Basic recommendations service with stubbed AI calls to Kevin.
8. Unit & integration tests for core flows.
9. Add admin endpoints for course curation and sync triggers.

---

## 14 — Environment variables

```
DATABASE_URL=...
REDIS_URL=...
ALGOLIA_APP_ID=
ALGOLIA_API_KEY=
STRIPE_SECRET=
COURSE_PROVIDER_KEY=
GOOGLE_CALENDAR_CLIENT_ID=
NOTIFY_SENDGRID_KEY=

```

---

## 15 — Documentation & Onboarding notes for Engineer

- Follow repo conventions (controllers → services → validators).
- Use `prisma` instance from `src/models/prisma.ts`.
- Avoid writing business logic in controllers — keep logic in `services`.
- Push incremental PRs to `tickpay-dev` or `lifex-education` branch with tests.
- Use `BullMQ` for job orchestration and schedule cron triggers in `server.ts` only when running in staging/production.
