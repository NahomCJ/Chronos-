# Spiritual life

## **1. Overview**

The Spiritual Life module focuses on **faith, donations, charity, spiritual growth, and events**. Users can explore **religion-specific programs**, manage tithing or donations, plan trips, enroll in courses, track goals, and shop for spiritual items.

**Key Goals:**

- Provide a centralized hub for spiritual activities.
- Integrate with external partners for donations, trip bookings, events, and courses.
- Enable personalized experiences based on religion and spiritual interests.

---

## **2. Features**

| Feature | Description | Backend Requirements | Notes |
| --- | --- | --- | --- |
| Donation Management | Users can donate to charities or tithing, track contributions | donation table, payment gateway integration, recurring donation scheduler | Supports single & recurring donations |
| Charity Crowdfunding | Users can participate in campaigns | crowdfunding table, payment gateway integration, campaign analytics | Display campaign details, backer info |
| Spiritual Trip Planning | Plan trips, pilgrimages, retreats | trip table, booking integration API, calendar sync | Connect with travel/retreat providers |
| Faith Calendar | Calendar for religious events and personal spiritual tasks | events table, recurring events scheduler | Users can filter by religion and region |
| Spiritual Goal Setting | Set spiritual growth goals (daily prayer, meditation, study) | goals table, progress tracker, reminder scheduler | Supports multiple goal types per user |
| Faith Event Programs | Browse and register for spiritual events | events table, registration table, notifications | Option to link Zoom or in-person events |
| Spiritual Items Purchasing | Buy spiritual books, items, merchandise | product table, inventory, payment integration | Optional affiliate partner integration |
| Spiritual Courses | Enroll in online courses (meditation, scriptures) | course table, enrollment table, progress tracker | Can be external course platform integration |
| Religion Personalization | Dropdown to select religion, tailor content | user_profile table, preferences field | Filters events, courses, trips by religion |
| Notifications & Reminders | Daily spiritual reminders, donation alerts | notification table, cron jobs, push notifications | Scheduled daily, weekly, monthly |

---

## **3. Database Structure**

**Tables & Models:**

1. **donation**
    - id: uuid
    - user_id: fk User.id
    - amount: decimal
    - currency: string
    - type: enum (single, recurring)
    - charity_id: fk Charity.id (optional)
    - status: enum (pending, completed, failed)
    - created_at, updated_at
2. **charity_crowdfunding**
    - id: uuid
    - name: string
    - description: text
    - target_amount: decimal
    - raised_amount: decimal
    - start_date, end_date
    - status: enum (active, completed, canceled)
3. **spiritual_trip**
    - id: uuid
    - name: string
    - description: text
    - location: string
    - start_date, end_date
    - capacity: int
    - booked_count: int
    - status: enum (upcoming, completed, canceled)
4. **faith_calendar_event**
    - id: uuid
    - user_id: fk User.id (optional for personal events)
    - title: string
    - description: text
    - start_datetime, end_datetime
    - recurring: enum (none, daily, weekly, monthly)
    - religion_tag: string
5. **spiritual_goal**
    - id: uuid
    - user_id: fk User.id
    - goal_type: enum (prayer, meditation, study, other)
    - title: string
    - progress: decimal
    - target: decimal
    - status: enum (active, completed, paused)
6. **faith_event_program**
    - id: uuid
    - title: string
    - description: text
    - location: string
    - start_datetime, end_datetime
    - registration_limit: int
    - registered_count: int
7. **spiritual_course**
    - id: uuid
    - title: string
    - description: text
    - provider: string
    - url: string
    - duration: int (hours)
8. **spiritual_product**
    - id: uuid
    - title: string
    - description: text
    - price: decimal
    - currency: string
    - inventory_count: int
    - image_url: string
9. **user_profile_preferences**
    - id: uuid
    - user_id: fk User.id
    - religion: string
    - language: string
    - preferred_content: json
10. **notifications**
    - id: uuid
    - user_id: fk User.id
    - type: string
    - content: text
    - scheduled_at: datetime
    - status: enum (pending, sent, failed)

---

## **4. Backend Responsibilities**

- **API Endpoints**:
    - `GET /spiritual/home` – return home dashboard with all services
    - `GET /spiritual/donations` – list donations & active campaigns
    - `POST /spiritual/donations` – create donation
    - `GET /spiritual/crowdfunding` – list campaigns
    - `POST /spiritual/crowdfunding/back` – back a campaign
    - `GET /spiritual/trips` – list trips
    - `POST /spiritual/trips/book` – book a trip
    - `GET /spiritual/events` – list faith calendar & programs
    - `POST /spiritual/events/register` – register for an event
    - `GET /spiritual/goals` – list spiritual goals
    - `POST /spiritual/goals` – create goal
    - `PUT /spiritual/goals/:id/progress` – update goal progress
    - `GET /spiritual/courses` – list courses
    - `POST /spiritual/courses/enroll` – enroll in course
    - `GET /spiritual/products` – list spiritual products
    - `POST /spiritual/products/purchase` – buy item
- **Scheduled Jobs / Cron Tasks**:
    - Daily reminders for spiritual goals & events
    - Recurring donation processing
    - Event registration reminders
    - Course progress notifications
- **Security & Compliance**:
    - GDPR for user preferences and donations
    - PCI DSS for donation & product payments
    - Audit logs for donations & trip bookings
- **AI Integration**:
    - Suggest personalized events, courses, and trips based on religion & activity history

---

## **5. Integration Points**

- **Payment Gateways**: Stripe, PayPal for donations and product purchases
- **Trip / Event Booking APIs**: Integration with external providers for retreats and events
- **Course Providers**: Coursera, Udemy, or internal courses platform
- **AI Personalization Engine**: Suggest content based on user preferences and history

---

## **6. Folder & Module Structure**

```
src/
 ├─ lifex/
 │   ├─ spiritual/
 │   │   ├─ spiritual.controller.ts
 │   │   ├─ spiritual.service.ts
 │   │   ├─ spiritual.routes.ts
 │   │   ├─ spiritual.module.ts
 │   │   ├─ dto/
 │   │   │    ├─ createDonation.dto.ts
 │   │   │    ├─ createTripBooking.dto.ts
 │   │   │    └─ ...
 │   │   ├─ entities/
 │   │   │    ├─ Donation.entity.ts
 │   │   │    ├─ SpiritualTrip.entity.ts
 │   │   │    ├─ SpiritualGoal.entity.ts
 │   │   │    ├─ FaithEvent.entity.ts
 │   │   │    └─ ...
 │   │   └─ utils/
 │   │        ├─ scheduler.ts
 │   │        ├─ aiIntegration.ts
 │   │        └─ notifications.ts

```

---

## **7. Recommended Pages for Mobile App (Spiritual Life)**

| Page | Description |
| --- | --- |
| Spiritual Home | Overview dashboard with all services |
| Donation List | Active & past donations, recurring options |
| Donation Details | Individual donation details and receipt |
| Charity Crowdfunding | Campaigns list |
| Campaign Details | Back campaign, see progress |
| Trip Overview | List of trips |
| Trip Booking | Trip booking page |
| Faith Calendar | View events & personal schedule |
| Event Program List | Upcoming spiritual events |
| Event Registration | Register for an event |
| Spiritual Goal List | List all spiritual goals |
| Goal Creation | Create new spiritual goal |
| Goal Progress | Update progress, set reminders |
| Courses List | Spiritual courses offered |
| Course Enrollment | Enroll in course & track progress |
| Product Store | Browse spiritual items |
| Product Purchase | Buy item, checkout flow |
| Religion Personalization | Dropdown to select religion for tailored content |
| Notifications & Reminders | View upcoming alerts, manage preferences |

> Total pages: ~18–20 for end-to-end coverage
>

---

This is a **full developer-ready documentation** for **Spiritual Life**, covering all features, backend requirements, database, AI integration, and mobile pages.

[Financial ](../backend/Financial.md)
