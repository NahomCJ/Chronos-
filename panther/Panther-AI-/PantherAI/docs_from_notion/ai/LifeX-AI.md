# LifeX AI

## **1. Overview**

Panther powers **LifeX**, providing **personalized insights, guidance, and recommendations** across the seven domains of life:

1. **Education** – Learning paths, course recommendations
2. **Financial** – Budgeting, BNPL guidance, savings goals
3. **Relationships & Family** – Advice, reminders, family goal tracking
4. **Spiritual** – Faith calendar, spiritual goal setting, donations
5. **Vision & Life Goals** – Progress tracking, motivational insights
6. **Health** – Gym partnerships, HSA tracking, wellness recommendations
7. **Social** – Community events, networking suggestions

**Purpose:**

- Enhance user experience through AI-guided life management
- Provide actionable insights per domain
- Connect users with external partners and services where appropriate
- Enable Kevin (chat assistant) to deliver personalized advice

---

## **2. Architecture**

```
          ┌─────────────────────────────┐
          │        LifeX App/UI         │
          └─────────────┬──────────────┘
                        │
                        ▼
          ┌─────────────────────────────┐
          │       Panther Agent Layer    │
          │ ─ Domain Routing Agent       │
          │ ─ Life Domain Expert Agents │
          │ ─ Recommendation Engine     │
          │ ─ Execution & Data Fetch    │
          └─────────────┬──────────────┘
                        │
                        ▼
       ┌────────────────────────────────────────┐
       │        LifeX Data Layer / APIs         │
       │ - User profile & goals                  │
       │ - Educational content & course APIs    │
       │ - Health partner APIs (gyms, HSA)     │
       │ - Spiritual resources                   │
       │ - Social events / community APIs       │
       └────────────────────────────────────────┘

```

---

## **3. Panther LifeX Agents**

| Agent | Responsibility | Description |
| --- | --- | --- |
| **Domain Routing Agent** | Routes user queries to the correct domain agent | Determines whether a request is education, financial, health, etc. |
| **Domain Expert Agents** | Handles domain-specific analysis and recommendations | Personalized insights for each life domain |
| **Recommendation Engine** | Provides suggestions and action items | Connects user goals with external services & partner data |
| **Execution & Data Fetch Agent** | Interfaces with LifeX APIs and partner services | Retrieves, formats, and filters relevant data |

---

## **4. Key Features per Domain**

### **4.1 Education**

- Suggests courses, books, and resources
- Tracks learning progress
- Connects to partner platforms for certifications
- Personalized learning roadmap

### **4.2 Financial**

- Monitors spending, savings, and goals
- Suggests BNPL or budgeting adjustments
- Offers actionable recommendations on investments & payments
- Connects to TickPay & BlockHub where applicable

### **4.3 Relationships & Family**

- Tracks family goals and reminders
- Provides AI guidance for relationships
- Suggests events or activities for bonding
- Sends reminders for important dates

### **4.4 Spiritual**

- Displays personalized faith calendar
- Tracks spiritual goals and milestones
- Suggests donations and charitable contributions
- Connects to spiritual content & programs

### **4.5 Vision & Life Goals**

- Tracks progress on long-term goals
- Provides motivational insights
- Suggests achievable micro-goals
- Sends periodic progress reports

### **4.6 Health**

- Tracks gym attendance and HSA balances
- Suggests diet & exercise plans
- Connects with partnered gyms & wellness programs for discounts
- Monitors health milestones

### **4.7 Social**

- Suggests local/community events
- Connects with interest-based groups
- Tracks networking & social engagement goals
- Recommends online/offline activities

---

## **5. Data Sources**

| Source | Data Access | Purpose |
| --- | --- | --- |
| User Profile & Goals | LifeX backend | Personalization per domain |
| Partner APIs (Education, Health, Spiritual, Social) | Courses, discounts, events | Recommendations & goal achievement |
| Financial Data (Chronos/BlockHub) | Transactions, balances | Financial guidance |
| Behavioral Data | App usage, engagement | Personalized insights & recommendations |

---

## **6. Agent Workflows**

### **6.1 Life Domain Query Flow**

1. Kevin receives a user request (e.g., “Show me my weekly health plan”)
2. Domain Routing Agent identifies the relevant domain
3. Life Domain Expert Agent generates insights & recommendations
4. Execution Agent fetches required partner data or APIs
5. Recommendation Engine provides actionable guidance
6. Kevin delivers result to the user

### **6.2 Personalized Recommendation Flow**

1. Panther evaluates user goals and preferences
2. Checks available partner services and external APIs
3. Calculates optimal suggestions based on data & constraints
4. Sends prioritized recommendations via Kevin

---

## **7. Deliverables for AI Engineer (LifeX Focus)**

| Month | Task |
| --- | --- |
| Month 1 | Build Domain Routing Agent, Life Domain Expert Agents skeleton |
| Month 2 | Implement insights engines for Education, Financial, and Health |
| Month 3 | Implement Relationships, Spiritual, Vision, and Social agents |
| Month 4 | Build Recommendation Engine, integrate partner APIs, connect to Kevin |
| Month 5 | Test, optimize, launch Phase 1 MVP |

---

## **8. Prompts & Templates**

### **Education Domain Prompt**

```
You are Panther — LifeX Education Expert.
- Recommend courses, resources, and learning paths.
- Personalize suggestions based on user profile and goals.
- Track progress and suggest next actions.

```

### **Financial Domain Prompt**

```
You are Panther — LifeX Financial Expert.
- Analyze user spending, savings, and BNPL usage.
- Suggest actionable steps for budgeting and goal achievement.
- Provide safe recommendations aligned with Chronos financial data.

```

### **Health Domain Prompt**

```
You are Panther — LifeX Health Expert.
- Track user fitness, HSA data, and milestones.
- Suggest exercise plans, diet, and wellness actions.
- Recommend partner programs or discounts where applicable.

```

*(Similar prompts exist for Spiritual, Social, Relationships, Vision domains)*

---

## **9. Summary**

**Panther x LifeX AI** is a **modular, domain-driven personal life assistant** that:

- Provides tailored insights across 7 life domains
- Connects users to external partners & services
- Suggests actionable steps for personal growth
- Integrates with Kevin to deliver recommendations in-app

---
