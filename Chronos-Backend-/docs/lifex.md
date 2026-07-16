# LifeX Module

**Path:** `src/modules/lifex/`

LifeX is Chronos's personal-development super-module. It covers education, financial planning, health & wellness, vision/goal tracking, social, spiritual, and family sub-modules — all tied to the same user account.

---

## Sub-modules

| Sub-module | Path | Description |
|-----------|------|-------------|
| Education | `lifex/modules/education/` | Courses, scholarships, tutors, student loans |
| Financial | `lifex/modules/financial/` | Budgets, financial plans, investment advice |
| Health | `lifex/modules/health/` | Metrics, fitness, diet, HSA, habits |
| Vision | `lifex/modules/vision/` | Vision boards, long-term goals, milestones |
| Social | `lifex/modules/social/` | Community groups |
| Spiritual | `lifex/modules/spiritual/` | Spiritual tracking |
| Family | `lifex/modules/family/` | Family account features |
| Activity | `lifex/modules/activity/` | Activity feed |
| AI | `lifex/modules/ai/` | AI-powered suggestions |
| Export | `lifex/modules/export/` | Data export (CSV/PDF) |

---

## Education

### Features
- Course catalog (Coursera, Udemy, local providers)
- Scholarship listings + applications
- Tutor marketplace + session booking
- Student loan tracking

### Key Endpoints

| Method | Route | Description |
|--------|-------|-------------|
| GET  | `/lifex/education/courses` | Browse courses |
| POST | `/lifex/education/courses/:id/enroll` | Enroll in a course |
| GET  | `/lifex/education/scholarships` | Browse scholarships |
| POST | `/lifex/education/scholarships/:id/apply` | Apply for scholarship |
| GET  | `/lifex/education/tutors` | Browse tutors |
| POST | `/lifex/education/tutors/:id/book` | Book a session |
| GET  | `/lifex/education/loans` | List student loans |

### Sync Jobs
- `course.sync.job.ts` — syncs course catalog from external providers
- `scholarship.sync.job.ts` — syncs scholarship listings

---

## Financial

### Features
- Financial plan creation (savings goals with frequency)
- Budget management by category
- Investment advice based on risk profile
- Credit score tracking
- Legacy transaction history

### Key Endpoints

| Method | Route | Description |
|--------|-------|-------------|
| POST | `/lifex/financial/plans` | Create a savings plan |
| GET  | `/lifex/financial/plans` | List financial plans |
| GET  | `/lifex/financial/budgets` | Get budgets |
| POST | `/lifex/financial/budgets` | Set a budget |
| GET  | `/lifex/financial/advice` | Get investment advice |
| GET  | `/lifex/financial/credit-score` | Get credit score history |

---

## Health

### Features
- Health metrics logging (weight, blood pressure, etc.)
- Fitness session tracking
- Diet + calorie logging
- HSA (Health Savings Account) management
- Habit tracking
- Wellness programs
- Gym partner directory

### Key Endpoints

| Method | Route | Description |
|--------|-------|-------------|
| POST | `/lifex/health/metrics` | Log a health metric |
| POST | `/lifex/health/fitness` | Log a fitness session |
| POST | `/lifex/health/diet` | Log a meal |
| GET  | `/lifex/health/hsa` | Get HSA account |
| POST | `/lifex/health/hsa/deposit` | HSA contribution |
| GET  | `/lifex/health/habits` | Get habits |
| POST | `/lifex/health/habits` | Create a habit |

---

## Vision

### Features
- Vision board with image URLs
- Long-term goal creation with categories (Career, Finance, Health, etc.)
- Milestone tracking per goal
- Habit tracker (separate from health habits)
- Mentorship programs
- Community groups

### Goal Categories

`CAREER` | `PERSONAL` | `FINANCE` | `HEALTH` | `SOCIAL` | `SPIRITUAL`

### Key Endpoints

| Method | Route | Description |
|--------|-------|-------------|
| POST | `/lifex/vision/board` | Create vision board |
| POST | `/lifex/vision/goals` | Create long-term goal |
| POST | `/lifex/vision/goals/:id/milestones` | Add milestone |
| PATCH | `/lifex/vision/goals/:id/milestones/:mid` | Update milestone status |
| GET  | `/lifex/vision/mentorship` | Browse mentorship programs |
| GET  | `/lifex/vision/community` | Browse community groups |

---

## Key Files

| File | Purpose |
|------|---------|
| `education/services/courses.service.ts` | Course catalog + enrollment |
| `education/services/scholarships.service.ts` | Scholarship management |
| `financial/financial.service.ts` | Financial plans, budgets |
| `health/health.service.ts` | All health data operations |
| `vision/` | Goals, milestones, vision boards |
