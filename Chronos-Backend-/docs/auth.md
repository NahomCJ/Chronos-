# Auth Module

**Path:** `src/modules/auth/`

Handles user registration, login, email OTP verification, and JWT issuance. All other modules depend on the JWT this module produces.

---

## Endpoints

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| POST | `/auth/register` | No | Register a new user |
| POST | `/auth/login` | No | Login, returns JWT |
| POST | `/auth/verify-email` | No | Verify email with OTP |
| POST | `/auth/resend-otp` | No | Resend OTP to email |
| GET  | `/auth/me` | Yes | Get current user profile |
| POST | `/auth/logout` | Yes | Logout (client-side token drop) |

---

## JWT Structure

```json
{
  "userId": "uuid",
  "email": "user@example.com",
  "role": "USER" | "ADMIN"
}
```

Token is passed as `Authorization: Bearer <token>` on all protected routes.

---

## Middlewares

| Middleware | File | Description |
|-----------|------|-------------|
| `requireAuth` | `middlewares/auth.middleware.ts` | Verifies JWT, attaches `req.user` |
| `requireAdmin` | `middlewares/auth.middleware.ts` | Requires `role === ADMIN` |

---

## Roles

| Role | Access |
|------|--------|
| `USER` | Standard user — all user-facing routes |
| `ADMIN` | Everything + admin overrides (KYC approve/reject, account freeze) |

---

## Password Security

- Passwords hashed with **bcrypt** (rounds: 10)
- Plain-text passwords are never stored or logged

---

## OTP Flow

1. User registers → OTP generated and emailed
2. User POSTs OTP to `/auth/verify-email`
3. `isEmailVerified` set to `true` on the `User` model
4. OTP expires after a set TTL (`otpExpiresAt` field)

---

## Key Files

| File | Purpose |
|------|---------|
| `services/auth.service.ts` | Registration, login, OTP logic |
| `controllers/auth.controller.ts` | Route handlers |
| `middlewares/auth.middleware.ts` | `requireAuth`, `requireAdmin` |
| `types/auth.types.ts` | `JwtPayload` interface |
| `config/config.ts` | JWT secret, expiry config |
