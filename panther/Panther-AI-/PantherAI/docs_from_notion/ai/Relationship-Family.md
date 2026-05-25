# Relationship/Family

## **1. Overview**

**Relationships & Family Life** focuses on strengthening users’ personal and family connections through **AI-guided communication tools**, **shared calendars**, **family budgets**, **counseling sessions**, and **relationship growth programs**.

It will include **modules for couples, families, friendships, and mentors**, helping users nurture healthy emotional, spiritual, and relational wellbeing.

---

## **2. Core Objectives**

- Help users maintain strong emotional connections and meaningful relationships.
- Facilitate better communication and shared responsibilities among family members.
- Enable couples and families to set joint goals and track emotional progress.
- Integrate family finance tools and joint decision tracking.
- Offer counseling and mentorship resources (AI + partner therapists).

---

## **3. Features**

| Feature | Description | Backend Requirements | Notes |
| --- | --- | --- | --- |
| Relationship Dashboard | Overview of family and personal relationship activities | relationship_overview table | Shows partner status, events, emotional health |
| Family Hub | Family management center (shared calendar, tasks, notes) | family table, family_members table | Each family has a unique group ID |
| Shared Calendar | Track birthdays, anniversaries, family events | family_events table, reminders | Sync with Google Calendar or Apple Calendar |
| Relationship Goals | Set and track couple or family goals | relationship_goals table | Example: “Save for trip,” “Weekly date night” |
| Couple Journal | Private shared space for couples | couple_journal table | Encrypted and accessible to both users |
| AI Relationship Coach | AI companion giving advice on communication & emotional well-being | AI module, relationship_metrics table | Optional therapist integration |
| Counseling & Mentorship | Book sessions with therapists or mentors | counseling_sessions table, integration with partners | Optional video/chat feature |
| Communication Hub | Messaging, voice notes, daily check-ins | messages table | Can be private or group-based (family/friends) |
| Relationship Health Tracker | Emotional, communication, and trust indicators | relationship_metrics table | AI generates monthly “relationship report” |
| Parenting Tools | Track parenting activities, chores, progress | parenting_tasks table | Add children profiles |
| Family Budget | Shared financial management | family_budget table, TickPay integration | Connects to TickPay or Basilica core banking |
| Family Notifications | Alerts for events, goals, and reminders | notifications table | Family-based scheduling |
| Friends & Social Circles | Add friends, track important dates, stay in touch | friends table, interactions table | Option to send AI-generated messages |
| Shared Media Vault | Family or couple media storage | media_vault table, encrypted URLs | Cloud-based image/video storage |
| AI Gift & Date Planner | AI suggests personalized gifts or date ideas | ai_gift_planner module | Based on anniversaries & preferences |

---

## **4. Database Structure**

### **Tables & Entities**

1. **relationships**
    - id: uuid
    - user_id: fk User.id
    - partner_id: fk User.id
    - relationship_type: enum (couple, friendship, mentorship)
    - status: enum (active, paused, ended)
    - started_at, updated_at
2. **family**
    - id: uuid
    - family_name: string
    - created_by: fk User.id
    - created_at
3. **family_members**
    - id: uuid
    - family_id: fk Family.id
    - member_id: fk User.id
    - role: enum (parent, child, grandparent, relative)
4. **family_events**
    - id: uuid
    - family_id: fk Family.id
    - event_name: string
    - event_type: enum (birthday, anniversary, trip, family_meeting)
    - date: datetime
    - reminder: boolean
5. **relationship_goals**
    - id: uuid
    - relationship_id: fk Relationship.id
    - title: string
    - description: text
    - target_date: datetime
    - progress: int
6. **couple_journal**
    - id: uuid
    - relationship_id: fk Relationship.id
    - entry_title: string
    - content: text
    - date: datetime
    - encrypted: boolean
7. **relationship_metrics**
    - id: uuid
    - relationship_id: fk Relationship.id
    - communication_score: float
    - trust_score: float
    - happiness_score: float
    - recorded_at: datetime
8. **counseling_sessions**
    - id: uuid
    - user_id: fk User.id
    - provider_name: string
    - session_date: datetime
    - mode: enum (video, chat, audio)
    - notes: text
    - status: enum (scheduled, completed, canceled)
9. **parenting_tasks**
    - id: uuid
    - family_id: fk Family.id
    - task_name: string
    - assigned_to: fk family_member
    - due_date: datetime
    - status: enum (pending, done)
10. **family_budget**
- id: uuid
- family_id: fk Family.id
- category: enum (groceries, bills, kids, recreation)
- amount: float
- date: datetime
1. **media_vault**
- id: uuid
- family_id: fk Family.id
- media_url: string
- type: enum (photo, video, document)
- uploaded_by: fk User.id
- uploaded_at: datetime
1. **notifications**
- id: uuid
- user_id: fk User.id
- content: text
- type: string
- scheduled_at: datetime

---

## **5. Backend API Structure**

### **Endpoints**

| Category | Endpoint | Method | Description |
| --- | --- | --- | --- |
| Relationship | `/relationship/dashboard` | GET | Overview of user’s relationships |
| Relationship | `/relationship/create` | POST | Start new relationship (invite partner) |
| Relationship | `/relationship/goals` | GET/POST | Manage goals |
| Couple Journal | `/relationship/journal` | GET/POST | Add/view journal entries |
| Family Hub | `/family/create` | POST | Create a new family group |
| Family Hub | `/family/members` | GET/POST | Manage family members |
| Family Events | `/family/events` | GET/POST | Add and list family events |
| Parenting | `/family/parenting/tasks` | GET/POST | Assign parenting duties |
| Budget | `/family/budget` | GET/POST | Track shared family finances |
| Counseling | `/counseling/sessions` | GET/POST | Book counseling sessions |
| Coaching | `/relationship/ai-coach` | GET | Get AI advice or feedback |
| Media Vault | `/family/media` | GET/POST | Upload and view shared media |
| Notifications | `/relationship/notifications` | GET | Fetch reminders |
| Friends | `/friends/list` | GET/POST | Manage friend circle |

---

## **6. AI Integration**

| AI Feature | Purpose | Data Source |
| --- | --- | --- |
| AI Relationship Coach | Give emotional & communication advice | relationship_metrics, journals |
| AI Gift & Date Planner | Suggest date ideas, gifts | user preferences, calendar |
| AI Family Budget Optimizer | Suggest budget allocations | family_budget |
| AI Emotional Report | Generate weekly “relationship report” | relationship_metrics |

---

## **7. Integrations**

| Partner Type | Example Companies | Integration Type |
| --- | --- | --- |
| **Counseling Platforms** | BetterHelp, Talkspace | Counseling API |
| **Calendar Services** | Google Calendar, Outlook | Event sync |
| **Financial Tools** | TickPay (internal), Revolut | Family budget integration |
| **Communication APIs** | Twilio, Agora | Voice/Video sessions |
| **Cloud Storage** | AWS S3, Firebase | Media Vault |
| **Parenting Platforms** | Cozi, OurFamilyWizard | Optional collaboration |
| **Gift/Shopping** | Amazon, Etsy, Uber Eats | Gift suggestions |
| **Therapist Networks** | Local clinics, mental health NGOs | Human coaching integration |

---

## **8. Folder & Module Structure**

```
src/
 ├─ lifex/
 │   ├─ relationships/
 │   │   ├─ relationship.controller.ts
 │   │   ├─ relationship.service.ts
 │   │   ├─ relationship.routes.ts
 │   │   ├─ relationship.module.ts
 │   │   ├─ dto/
 │   │   │    ├─ createRelationship.dto.ts
 │   │   │    ├─ addGoal.dto.ts
 │   │   │    ├─ logJournal.dto.ts
 │   │   ├─ entities/
 │   │   │    ├─ Relationship.entity.ts
 │   │   │    ├─ Family.entity.ts
 │   │   │    ├─ FamilyMember.entity.ts
 │   │   │    ├─ FamilyEvent.entity.ts
 │   │   │    ├─ RelationshipGoal.entity.ts
 │   │   │    ├─ RelationshipMetrics.entity.ts
 │   │   │    └─ CounselingSession.entity.ts
 │   │   └─ utils/
 │   │        ├─ aiRelationshipCoach.ts
 │   │        ├─ datePlanner.ts
 │   │        └─ notifications.ts

```

---

## **9. Mobile App Pages**

| Page | Description |
| --- | --- |
| Relationship Dashboard | Overview of relationships & emotional stats |
| Couple Journal | Private space for partners |
| Relationship Goals | Create & track relationship goals |
| Family Hub | Overview of family activities |
| Family Members | Manage member profiles |
| Family Calendar | Shared calendar & reminders |
| Parenting Tasks | Assign & track family duties |
| Family Budget | Manage shared finances |
| Counseling Sessions | Book or view sessions |
| AI Relationship Coach | Receive personalized advice |
| Media Vault | Upload & share family photos/videos |
| Friends Hub | Manage friendships & social circles |
| Notifications | View relationship/family alerts |
| Reports | AI-generated relationship progress report |

---

✅ **Total pages:** ~14–16

✅ **Fully API-ready & modular**

✅ **Includes AI, social, counseling, and financial aspects**

✅ **Expandable for couples, families, and friends**
