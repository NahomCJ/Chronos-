# LifeX Health Integration: Apple Health, Whoop, and Strava

This document outlines the strategy for integrating health data from Apple Health, Whoop, and Strava into the Chronos LifeX ecosystem.

## Feasibility Overview

| Service | Integration Type | Data Points |
| :--- | :--- | :--- |
| **Apple Health** | Client-Side (HealthKit) | Steps, Heart Rate, Sleep, Activity, Vitals |
| **Whoop** | Server-Side (REST API v2) | Recovery, Strain, Sleep, Sleep Performance |
| **Strava** | Server-Side (REST API) | Runs, Rides, Swims, PRs, Heatmaps |

## Technical Implementation

### 1. Apple Health (HealthKit)
*   **Mechanism:** Since HealthKit is local to iOS, the Chronos mobile app will request user permission to read specific data types.
*   **Data Flow:** Mobile App → Chronos Backend → Panther (LifeX Health Agent).
*   **Use Case:** Real-time health signals and vitals for the Health Health Score.

### 2. Whoop API
*   **Mechanism:** OAuth2 authentication. Panther's `Execution Agent` makes background requests to Whoop's servers.
*   **Data Flow:** Whoop Cloud → Chronos Backend → Panther.
*   **Use Case:** Correlating "Recovery" scores with financial stress or productive output.

### 3. Strava API
*   **Mechanism:** OAuth2 authentication. Webhooks can be used to notify Chronos when a new activity is uploaded.
*   **Data Flow:** Strava Cloud → Chronos Backend → Panther.
*   **Use Case:** Rewarding physical activity milestones with Chronos partner discounts or "Financial Health" boosts.

## Panther's Role (LifeX Health Expert)
Panther will ingest this data to:
1.  **Detect Patterns:** "You spend more on Uber Eats when your Whoop recovery is below 30%."
2.  **Suggest Actions:** "Your Strava volume is up. Consider using your HSA for a recovery massage at a partner spa."
3.  **Holistic Health Score:** Combine physical and financial data into a single "Chronos Vitality Score".
