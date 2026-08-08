# Dory Task Tracker

A full-stack task management application where each user has their own account and can create, organize, filter, search, and manage tasks within categories. Built as a submission for the Inovers Full-Stack Developer Coding Exam.

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Ruby on Rails 8.1.3 (monolith: server-rendered views, no separate frontend app) |
| Frontend | Rails ERB views + Turbo/Stimulus (Hotwire, bundled with Rails 8) + Tailwind CSS |
| Backend | Rails controllers (Ruby 3.2.2) |
| Database | PostgreSQL 18.4 |
| ORM | Active Record (Rails' built-in ORM) |
| Authentication | Rails session/cookie-based auth (see "Design Decisions" below) |
| Password hashing | `bcrypt` (Rails default gem, via `has_secure_password`) |

### Why this stack instead of the exam's default (React + Express + MySQL)

The exam explicitly allows an alternative stack under Section 2 ("Using a Different Stack"), provided the schema, functional requirements, and API shape stay equivalent, and the choice is declared here and in the submission email; this section serves that requirement.

I chose Ruby on Rails as a **full monolith** (not a React frontend + Rails API split) to demonstrate depth in a single, cohesive framework rather than splitting effort across two separate applications. Rails' "convention over configuration" philosophy also let me build faster within a one-day window without sacrificing structure: routes, models, controllers, and views all follow well-established, readable patterns rather than custom-wired glue code.

Additionally, in my professional background as freelance developer, I have used Ruby on Rails on the projects that I handle in day to day setting.

**PostgreSQL over MySQL:** PostgreSQL is Rails' most natural and best-supported database pairing (better native support for things like `ILIKE` case-insensitive search, used in this app's task search feature), and Rails' generators/migrations work identically well with either engine; the choice was about ecosystem fit, not a functional requirement change.

### Design Decisions (including the JWT substitution)

**No pre-built auth/authorization gems.** This project deliberately avoids gems like Devise (authentication) or Pundit (authorization) that would scaffold sign up/sign in/permissions automatically. Every piece of the auth flow (registration, login, logout, password hashing via `has_secure_password`, and per-request access control) is hand-written and fully explainable. The only gems used (`bcrypt`, `pg`) are narrow-purpose utilities (hashing, database driver), not frameworks-within-a-framework.

**Session-based auth instead of JWT.** The exam's Section 4.2 specifies JWT-based authentication (`POST /api/auth/login` returning a JWT). JWTs exist specifically to solve authentication for a *decoupled* setup: a separate frontend (e.g., a React SPA) and a separate backend API that don't naturally share cookies, so the frontend must store a token and manually attach it to every request.

Because this project is a **Rails monolith** (the "frontend" and "backend" are the same application, serving the same origin), that problem doesn't exist. Rails' built-in session/cookie mechanism (`session[:user_id]`) provides the equivalent security guarantee (identifying a request as belonging to a specific authenticated user, protecting routes, preventing cross-user access) through a simpler, more idiomatic mechanism for this architecture:

- On successful login, `session[:user_id] = user.id` is stored in an encrypted, tamper-proof cookie (Rails encrypts and signs this automatically; a visitor cannot read or forge it).
- Every request automatically includes this cookie; `current_user` (in `ApplicationController`) looks up the user from it on each request.
- `before_action :require_login` in `ApplicationController` protects every route by default (a "locked unless explicitly opened" pattern, safer than defaulting open), with `skip_before_action :require_login` explicitly opting out only the public sign-up/sign-in pages.

This substitution does not change the API shape's *behavior*: protected endpoints still reject unauthenticated requests, users still cannot access each other's data. Only the transport mechanism for proving identity changes, which is the correct mechanism for this architecture.

**Categories are shared, not per-user.** Per the exam's schema (Section 4.1), the `Category` table has no `user_id`: categories are a shared, global list available to all users, while `Task` rows are individually owned via `user_id`. This is intentional and matches the specified schema exactly.

---

## Local Setup & Run Instructions

### Prerequisites
- Ruby 3.2.2 (or compatible 3.2.x)
- Rails 8.1.3
- PostgreSQL (running locally, accessible via `psql`)

### Steps

1. Clone the repository:
```bash
   git clone <repo-url>
   cd dory_task_tracker
```

2. Install dependencies:
```bash
   bundle install
```

3. Create and migrate the database:
```bash
   bin/rails db:create
   bin/rails db:migrate
```

`config/database.yml` connects to PostgreSQL using the default local role and no password in development/test, matching a standard local Postgres install. No `.env` file is required to run the app locally; the only environment variable read at runtime is `DORY_TASK_TRACKER_DATABASE_PASSWORD`, used solely in the production database config.

4. Seed test accounts and sample data:
```bash
   bin/rails db:seed
```
This creates two ready-to-use accounts (credentials in the "Test Account" section below), a shared set of categories, and a few sample tasks. Seeding is idempotent, safe to run more than once.

5. Start the server:
```bash
   bin/rails server
```

6. Visit `http://localhost:3000` in your browser.

---

## Features

- Sign up / Sign in / Sign out (session-based)
- Protected routes: signed-out visitors are redirected to Sign In
- Category management: view all categories, add a new one
- Task CRUD: create, view, edit, delete (with confirmation before delete)
- Tasks are scoped to the logged-in user: one user can never view or modify another user's tasks
- Filter tasks by status and/or category
- Search tasks by title (case-insensitive, partial match)
- Pagination on the task list (configurable page size via `?limit=`)
- Friendly empty states (no tasks yet, no search results) and validation error messages throughout
- Flash messages (success/error) shown globally via the shared layout

---

## Routes (equivalent to the exam's API endpoint list)

Since this is a server-rendered monolith rather than a JSON API, routes serve full HTML pages rather than JSON responses. Functional equivalents to the exam's Section 4.2 endpoint list:

| Purpose | Route |
|---|---|
| Health check | `GET /up` (Rails' built-in health check) |
| Sign up (form) | `GET /signup` |
| Sign up (submit) | `POST /signup` |
| Sign in (form) | `GET /login` |
| Sign in (submit) | `POST /login` |
| Sign out | `DELETE /logout` |
| List categories | `GET /categories` |
| Create category | `POST /categories` |
| List tasks (supports `?status=`, `?category_id=`, `?search=`, `?page=`, `?limit=`) | `GET /tasks` |
| New task form | `GET /tasks/new` |
| Create task | `POST /tasks` |
| View one task | `GET /tasks/:id` |
| Edit task form | `GET /tasks/:id/edit` |
| Update task | `PATCH /tasks/:id` |
| Delete task | `DELETE /tasks/:id` |

---

## Known Limitations / Trade-offs

- Pagination is hand-rolled (plain `OFFSET`/`LIMIT` math) rather than using a pagination gem: a deliberate choice to keep the dependency footprint minimal and every line explainable.
- No automated test suite was written given the one-day time constraint (listed as a bonus challenge in the exam, not a core requirement). Rails' generated test/fixture files are present but contain no assertions yet.
- Category deletion was intentionally not implemented in the UI, since the schema has no ownership on categories and no cascade behavior was specified for tasks referencing a deleted category, avoiding an ambiguous destructive action.
- Styling uses Tailwind utility classes applied directly in views rather than a component library: functional and clean, not a full design system.

---

## Test Account

Running `bin/rails db:seed` creates the following accounts:

| Email | Password | Notes |
|---|---|---|
| `test@example.com` | `password123` | Pre-loaded with a few sample tasks across statuses |
| `reviewer@example.com` | `password123` | Empty account, useful for confirming per-user data isolation |

Alternatively, register your own account via `/signup`.
