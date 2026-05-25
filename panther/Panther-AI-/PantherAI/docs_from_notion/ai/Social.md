# Social

## **1. Overview**

The **Social Life** module within LifeX helps users build **meaningful social connections**, **discover events**, **find volunteering or local activities**, and **join communities** that align with their goals and lifestyle.

It merges **AI-driven recommendations**, **real-world social engagement**, and **interest-based networking** — designed to reduce loneliness, increase real-life interactions, and build a healthier digital community.

---

## **2. Core Objectives**

- Enable users to expand and maintain a positive social network.
- Recommend social events, clubs, volunteering opportunities, and digital communities.
- Support mental and social well-being through meaningful engagement.
- Provide tools for users to track and improve their social interactions and impact.
- Integrate gamified experiences and AI personalization.

---

## **3. Core Features**

| Feature | Description | Backend Requirement | Notes |
| --- | --- | --- | --- |
| **Social Dashboard** | Displays user’s social health, upcoming events, and new friend suggestions | social_dashboard table | Central hub for this domain |
| **Friend Network** | Add, remove, or interact with friends | friends table | Integrated with Relationship domain |
| **Communities & Clubs** | Join or create community groups around interests | communities table, community_members table | Includes local and virtual clubs |
| **Event Discovery** | Discover nearby or virtual events | events table, location services | Filtered by interests and location |
| **AI Social Recommender** | Suggests events, people, and communities | AI module, social_activity_metrics table | Uses user behavior + social graph |
| **Volunteering Programs** | Find and apply for volunteering opportunities | volunteering table | Integrated with NGOs |
| **Lifestyle Challenges** | Join social wellness or lifestyle challenges (fitness, reading, travel, etc.) | challenges table, participants table | Connects to Health Life & Education Life |
| **Meetups & Gatherings** | Create or join real-world meetups | meetups table, RSVP table | Uses location & calendar APIs |
| **AI Conversation Assistant** | Suggests message ideas, responses, or introductions | AI NLP module | Optional privacy mode |
| **Social Rewards System** | Reward social engagement via badges and points | rewards table | Points used for discounts in other LifeX modules |
| **Influence Score Tracker** | Measure and analyze engagement and social reach | social_score table | AI-based social analytics |
| **Digital Detox Mode** | Helps users limit screen time & schedule offline activities | user_preferences table | Connects to Health Life module |
| **Social Goals Tracker** | Track goals like “Make new friends” or “Attend more social events” | social_goals table | Weekly or monthly reminders |
| **Community Feed** | Discussion posts, updates, and photos | community_posts table | Optional moderation layer |
| **Partnership Integration** | Link with local brands, cafes, or coworking spaces for social perks | partners table | Enables affiliate programs |

---

## **4. Database Structure**

### **Tables & Entities**

1. **social_dashboard**
    - id: uuid
    - user_id: fk User.id
    - events_upcoming: int
    - friends_count: int
    - score: float
    - last_updated: datetime
2. **friends**
    - id: uuid
    - user_id: fk User.id
    - friend_id: fk User.id
    - status: enum (pending, accepted, blocked)
    - created_at: datetime
3. **communities**
    - id: uuid
    - name: string
    - category: enum (fitness, tech, reading, social_wellness, etc.)
    - description: text
    - created_by: fk User.id
    - created_at: datetime
4. **community_members**
    - id: uuid
    - community_id: fk communities.id
    - user_id: fk User.id
    - role: enum (admin, member)
    - joined_at: datetime
5. **community_posts**
    - id: uuid
    - community_id: fk communities.id
    - author_id: fk User.id
    - content: text
    - media_url: string
    - created_at: datetime
6. **events**
    - id: uuid
    - title: string
    - description: text
    - location: string
    - date: datetime
    - organizer_id: fk User.id
    - type: enum (online, offline)
    - category: enum (networking, volunteering, social, lifestyle)
7. **meetups**
    - id: uuid
    - name: string
    - description: text
    - host_id: fk User.id
    - location: string
    - date: datetime
    - capacity: int
8. **RSVP**
    - id: uuid
    - meetup_id: fk meetups.id
    - user_id: fk User.id
    - status: enum (interested, going, declined)
9. **volunteering**
    - id: uuid
    - title: string
    - organization: string
    - description: text
    - location: string
    - start_date: datetime
    - contact_email: string
10. **challenges**
- id: uuid
- name: string
- description: text
- category: enum (social, fitness, creativity, reading)
- duration_days: int
- reward_points: int
1. **participants**
- id: uuid
- challenge_id: fk challenges.id
- user_id: fk User.id
- status: enum (ongoing, completed)
1. **social_goals**
- id: uuid
- user_id: fk User.id
- goal_name: string
- progress: int
- target_date: datetime
1. **social_activity_metrics**
- id: uuid
- user_id: fk User.id
- events_joined: int
- friends_added: int
- posts_made: int
- updated_at: datetime
1. **rewards**
- id: uuid
- user_id: fk User.id
- points: int
- redeemed: boolean
- created_at: datetime
1. **social_score**
- id: uuid
- user_id: fk User.id
- influence_score: float
- engagement_rate: float
- updated_at: datetime

---

## **5. Backend API Endpoints**

| Category | Endpoint | Method | Description |
| --- | --- | --- | --- |
| Dashboard | `/social/dashboard` | GET | Get user’s social summary |
| Friends | `/social/friends` | GET/POST | Add or list friends |
| Communities | `/social/communities` | GET/POST | Create or join communities |
| Community Feed | `/social/communities/:id/posts` | GET/POST | Post in community feed |
| Events | `/social/events` | GET/POST | Discover or host events |
| Meetups | `/social/meetups` | GET/POST | Create/join local meetups |
| Volunteering | `/social/volunteering` | GET/POST | View/apply for volunteer programs |
| Challenges | `/social/challenges` | GET/POST | Join lifestyle challenges |
| Goals | `/social/goals` | GET/POST | Track social development goals |
| Rewards | `/social/rewards` | GET | View social points/rewards |
| AI Recommendations | `/social/ai-recommendations` | GET | AI suggests people/events/groups |
| Social Score | `/social/score` | GET | View social engagement insights |

---

## **6. AI Integration**

| AI Feature | Function | Data Source |
| --- | --- | --- |
| **AI Social Recommender** | Suggests new friends, events, or groups | User interests, social_activity_metrics |
| **AI Conversation Assistant** | Suggests messages & icebreakers | User chats (optional) |
| **AI Influence Analyzer** | Calculates engagement, impact & reach | social_score |
| **AI Social Coach** | Recommends ways to improve social health | social_goals, events_joined |
| **AI Event Matcher** | Matches user with best local/online events | location + interests |

---

## **7. Partner Integrations**

| Partner Type | Example Companies | Integration Purpose |
| --- | --- | --- |
| **Event Platforms** | Eventbrite, Meetup, Ticketmaster | Pull events data |
| **Volunteering Orgs** | VolunteerMatch, Idealist | Show opportunities |
| **Local Businesses** | Cafes, coworking spaces, clubs | Partner discounts |
| **Social Networks** | LinkedIn, Instagram | Import contacts & networking |
| **Travel & Experiences** | Airbnb Experiences, Viator | Enrich social activity options |
| **Health & Fitness** | Strava, Fitbit | Sync with group challenges |
| **NGOs & Foundations** | Red Cross, UNICEF, local NGOs | Community engagement |
| **AI Providers** | OpenAI, Google Vertex AI | NLP and recommendation system |

---

## **8. Folder & Module Structure**

```
src/
 ├─ lifex/
 │   ├─ social/
 │   │   ├─ social.controller.ts
 │   │   ├─ social.service.ts
 │   │   ├─ social.routes.ts
 │   │   ├─ social.module.ts
 │   │   ├─ dto/
 │   │   │    ├─ createCommunity.dto.ts
 │   │   │    ├─ joinEvent.dto.ts
 │   │   │    ├─ addGoal.dto.ts
 │   │   ├─ entities/
 │   │   │    ├─ Community.entity.ts
 │   │   │    ├─ Event.entity.ts
 │   │   │    ├─ Volunteering.entity.ts
 │   │   │    ├─ Challenge.entity.ts
 │   │   │    ├─ Reward.entity.ts
 │   │   └─ utils/
 │   │        ├─ aiRecommender.ts
 │   │        ├─ aiConversationHelper.ts
 │   │        └─ eventMatcher.ts

```

---

## **9. Mobile App Pages**

| Page | Description |
| --- | --- |
| Social Dashboard | Overview of user’s social stats and activities |
| Community Explorer | Browse & join communities |
| Community Feed | Post updates, like, comment |
| Events | View and join local or online events |
| Meetups | Host or attend gatherings |
| Volunteering | Find volunteer programs |
| Challenges | Participate in lifestyle challenges |
| Social Goals | Set & track social improvement targets |
| AI Social Recommender | Smart recommendations hub |
| Friends List | Manage connections |
| Rewards | View and redeem points |
| Social Score | Social influence analytics |
| Settings | Manage social privacy & preferences |

---

✅ **Total pages:** ~13–15

✅ **AI-integrated for personalized social experience**

✅ **Connects seamlessly with Health, Vision, and Relationship modules**
