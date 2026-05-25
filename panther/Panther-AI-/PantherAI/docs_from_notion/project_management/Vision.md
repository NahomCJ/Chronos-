# Vision

## **1. Overview**

The Vision Life module helps users **set, track, and achieve their life and career visions**. It focuses on **personal growth, goal-setting, long-term planning, mentorship, and productivity**. Users can create structured vision boards, track progress, access coaching or courses, and receive AI-powered recommendations.

**Key Goals:**

- Help users define their long-term vision in multiple life aspects.
- Provide tools to track milestones and goals.
- Integrate mentorship, courses, and productivity resources.
- Provide AI insights and personalized recommendations for achieving goals.

---

## **2. Features**

| Feature | Description | Backend Requirements | Notes |
| --- | --- | --- | --- |
| Vision Board | Users can create a visual representation of life goals | vision_board table, images storage, goal mapping | Supports multiple boards per user |
| Long-Term Goals | Set goals for 1–10 years in personal/career/finance | goals table, progress tracker, milestone scheduler | Goals can be tagged for LifeX categories |
| Milestone Tracking | Break long-term goals into milestones | milestones table, progress updates | Supports reminders and notifications |
| Mentorship Programs | Users can join mentorship sessions or find mentors | mentor table, session scheduling, messaging | Optional integration with external coaching platforms |
| Productivity & Habit Tracker | Track daily habits that support vision | habits table, progress updates, reminders | AI can suggest habits based on goals |
| Courses & Learning Resources | Access online courses to achieve vision goals | course table, enrollment table, progress tracking | Integration with Coursera, Udemy, or internal resources |
| AI Recommendations | AI suggests personalized vision plans, habits, resources | AI integration, user activity logs | Suggest improvements & optimizations |
| Networking & Communities | Join groups aligned with vision goals | community table, group membership, messaging | Optional events integration |
| Calendar & Scheduling | Plan milestones, mentoring sessions, courses | calendar table, event scheduler | Notifications and sync with device calendar |
| Goal Progress Reports | Visual charts showing progress | reporting engine, analytics table | Can be exported or shared with mentor |
| Resource Marketplace | Buy tools, books, subscriptions for achieving vision | product table, payment integration | Optional partner integration for resources |
| Reminders & Notifications | Reminders for milestones, courses, mentor sessions | notification table, cron jobs | Supports push/email notifications |

---

## **3. Database Structure**

**Tables & Models:**

1. **vision_board**
    - id: uuid
    - user_id: fk User.id
    - title: string
    - description: text
    - image_urls: json[]
    - created_at, updated_at
2. **long_term_goal**
    - id: uuid
    - user_id: fk User.id
    - title: string
    - description: text
    - category: enum (career, personal, finance, health, social, spiritual)
    - start_date, end_date
    - status: enum (active, completed, paused)
3. **milestone**
    - id: uuid
    - goal_id: fk long_term_goal.id
    - title: string
    - description: text
    - due_date: datetime
    - status: enum (pending, completed, missed)
4. **habit_tracker**
    - id: uuid
    - user_id: fk User.id
    - habit_name: string
    - frequency: enum (daily, weekly, monthly)
    - progress: decimal
    - status: enum (active, completed, paused)
5. **mentorship_program**
    - id: uuid
    - title: string
    - description: text
    - mentor_id: fk User.id (mentor role)
    - schedule: datetime
    - status: enum (upcoming, completed, canceled)
6. **courses**
    - id: uuid
    - title: string
    - description: text
    - provider: string
    - url: string
    - duration: int (hours)
    - status: enum (active, archived)
7. **community_group**
    - id: uuid
    - name: string
    - description: text
    - category: enum (career, personal, health, social, spiritual)
    - members: json[]
8. **notifications**
    - id: uuid
    - user_id: fk User.id
    - type: string
    - content: text
    - scheduled_at: datetime
    - status: enum (pending, sent, failed)

---

## **4. Backend Responsibilities**

- **API Endpoints**:
    - `GET /vision/home` – return dashboard with all Vision Life services
    - `GET /vision/boards` – list user’s vision boards
    - `POST /vision/boards` – create a new vision board
    - `GET /vision/goals` – list long-term goals
    - `POST /vision/goals` – create a goal
    - `PUT /vision/goals/:id` – update goal
    - `GET /vision/milestones` – list milestones for a goal
    - `POST /vision/milestones` – create milestone
    - `PUT /vision/milestones/:id` – update milestone status/progress
    - `GET /vision/habits` – list habits
    - `POST /vision/habits` – create habit
    - `PUT /vision/habits/:id` – update habit progress
    - `GET /vision/mentorship` – list mentorship programs
    - `POST /vision/mentorship/register` – enroll in mentorship
    - `GET /vision/courses` – list courses
    - `POST /vision/courses/enroll` – enroll in course
    - `GET /vision/community` – list groups
    - `POST /vision/community/join` – join group
    - `GET /vision/reports` – fetch progress reports
    - `GET /vision/resources` – list marketplace items
    - `POST /vision/resources/purchase` – purchase resource
- **Scheduled Jobs / Cron Tasks**:
    - Reminder notifications for milestones, habits, mentorship, and courses
    - AI suggestion updates weekly based on user activity
- **Security & Compliance**:
    - GDPR for personal goals, progress, and mentorship
    - Audit logging for purchases and mentorship sessions
- **AI Integration**:
    - Suggest personalized goals, habits, mentors, courses, and communities
    - Predict completion likelihood for goals and milestones

---

## **5. Integration Points**

- **Course Providers**: Coursera, Udemy, internal platforms
- **Mentorship Platforms**: Zoom, Calendly, or proprietary system
- **Marketplace Partners**: Books, productivity tools, subscriptions
- **AI Recommendation Engine**: Suggests goals, habits, resources, mentorships

---

## **6. Folder & Module Structure**

```
src/
 ├─ lifex/
 │   ├─ vision/
 │   │   ├─ vision.controller.ts
 │   │   ├─ vision.service.ts
 │   │   ├─ vision.routes.ts
 │   │   ├─ vision.module.ts
 │   │   ├─ dto/
 │   │   │    ├─ createGoal.dto.ts
 │   │   │    ├─ createMilestone.dto.ts
 │   │   │    └─ ...
 │   │   ├─ entities/
 │   │   │    ├─ VisionBoard.entity.ts
 │   │   │    ├─ LongTermGoal.entity.ts
 │   │   │    ├─ Milestone.entity.ts
 │   │   │    ├─ Habit.entity.ts
 │   │   │    ├─ Course.entity.ts
 │   │   │    └─ ...
 │   │   └─ utils/
 │   │        ├─ scheduler.ts
 │   │        ├─ aiIntegration.ts
 │   │        └─ notifications.ts

```

---

## **7. Recommended Pages for Mobile App (Vision Life)**

| Page | Description |
| --- | --- |
| Vision Home | Dashboard with all services overview |
| Vision Board List | List of user-created boards |
| Create Vision Board | Upload images, add goals |
| Board Details | View/edit board and associated goals |
| Goal List | List all long-term goals |
| Goal Creation | Create new goal |
| Goal Details | Update goal, add milestones |
| Milestone Tracker | Track progress of each milestone |
| Habit Tracker | List and create daily/weekly habits |
| Habit Progress | Update progress and set reminders |
| Mentorship Programs | List programs, available mentors |
| Mentorship Registration | Book sessions |
| Courses List | Available courses for vision achievement |
| Course Enrollment | Enroll and track progress |
| Community Groups | Browse and join groups |
| Resource Marketplace | Buy tools, books, subscriptions |
| Resource Purchase | Purchase checkout flow |
| AI Recommendations | Personalized vision suggestions |
| Notifications & Reminders | View alerts and scheduled tasks |

> Total pages: ~18–20 for end-to-end coverage
>

---
