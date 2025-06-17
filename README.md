# Showdrop: Upcoming TV Show Aggregator

Showdrop is a Ruby on Rails API-only application that aggregates upcoming TV show releases from the TVMaze API. It provides authenticated endpoints to browse shows, filter by metadata, and retrieve serialized data for use in frontend or mobile clients.

---

## Table of Contents

- [Ruby Version](#ruby-version)
- [Rails Version](#rails-version)
- [System Dependencies](#system-dependencies)
- [Database Creation](#database-creation)
- [Database Design](#database-design)
- [Testing Strategy](#testing-strategy)
- [Authentication](#authentication)
- [Sidekiq Background Jobs](#sidekiq-background-jobs)
- [Running the Application](#running-the-application)
- [API Overview](#api-overview)
- [Trade-offs and Design Decisions](#trade-offs-and-design-decisions)
- [Deployment Plan ](#deployment-plan)

---

## Ruby Version

**3.3.6**

## Rails Version

**8.0.0 (API-only)**

---

## System Dependencies

- PostgreSQL
- Redis (for Sidekiq)
- Sidekiq (background jobs)
- JWT (Devise + JWT for API auth)

---
## Database Creation
```bash
rails db:create
rails db:migrate
```
## Database Design

![Schema](https://github.com/user-attachments/assets/05494be6-0e39-48ef-89e8-fd09120ca4e7)

This application consists of four primary entities:

- TvShow: Represents a show, uniquely identified by its provider_identifier (TVMaze ID).

- Distributor: Represents a TV network or streaming platform, such as Netflix or HBO.

- Release: Represents the airing of a specific episode, linked to a show and a distributor.

- User: Authenticated users, managed by Devise and JWT.

**Schema Relationships**
```
A TvShow has many Releases.

A Distributor has many Releases.

A Release belongs to a TvShow and a Distributor.
```
**Indexes and Constraints**
| Table         | Field(s)                          | Reason                                                                 |
|---------------|-----------------------------------|------------------------------------------------------------------------|
| `tv_shows`    | `provider_identifier (UNIQUE)`    | Ensures we don’t import duplicate shows from the TVMaze API           |
| `tv_shows`    | `premiered`                       | Speeds up filtering by premiere date range                            |
| `distributors`| `name + country (UNIQUE)`         | Prevents duplicates like "Netflix US" and "Netflix US"                |
| `releases`    | `episode_id (UNIQUE)`             | Ensures idempotency; each episode from TVMaze is imported once        |
| `releases`    | `tv_show_id`                      | Foreign key for querying releases per show                            |
| `releases`    | `distributor_id`                  | Foreign key for filtering by distributor                              |
| `users`       | `email (UNIQUE)`                  | Devise requirement for login                                          |
| `users`       | `jti (UNIQUE)`                    | Used for JWT token revocation                                         


**Design Justifications**
UUIDs are used for all primary keys for global uniqueness, especially useful when integrating external APIs or distributed systems.

Normalized structure: Distributors are separated into their own table to allow reusability and filtering.

Indexing on premiered, provider_identifier, and episode_id ensures the app can handle large volumes of data efficiently, especially as the import process scales to 90+ days of releases.

Relational integrity: Foreign key constraints ensure no orphaned releases exist without associated shows or distributors.

## Testing Strategy
The application is covered with RSpec, using factories (FactoryBot), request specs for endpoints, and unit tests for service classes.
- How to Run the Test Suite:
```bash
bundle exec rspec
```
## Authentication
Authentication is handled via Devise with JWT.

**Signup** 
**Endpoint: POST /signup**

Payload:
```json
{
  "user": {
    "email": "test@example.com",
    "password": "password",
    "password_confirmation": "password"
  }
}
```
**Login**
**Endpoint: POST /login**

Response Header:
```json
Authorization: Bearer <JWT_TOKEN>
```
Use this token in all subsequent requests to access protected endpoints.

## Sidekiq Background Jobs

The job ImportTvShowsJob runs daily (or on-demand) and fetches upcoming TV shows for the next 90 days from the TVMaze API. It persists:

- TV Shows

- Distributors

- Episode Releases

To trigger the job manually:
```bash
bundle exec sidekiq
```
Or enqueue manually from the rails console:
```bash
ImportTvShowsJob.perform_async
```

## Running the Application

```bash
bin/rails server
```
Visit:
```bash
http://localhost:3000/api/v1/tv_shows
```

## API Overview
The application exposes a RESTful JSON API for browsing upcoming TV shows. All endpoints are authenticated via JWT.
```bash
GET /api/v1/tv_shows
```
```bash
curl -X GET http://localhost:3000/api/v1/tv_shows \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json"
```
Response example:
```json
{
    "data": [
        {
            "data": {
                "type": "tv_show",
                "id": "4deaaa83-f77c-425d-81e1-b65b195bfb01",
                "attributes": {
                    "name": "1000-lb Roomies",
                    "language": "English",
                    "premiered": "2025-06-03",
                    "status": "Running",
                    "rating": null,
                    "summary": "1000-lb Roomies a bold, unfiltered and heart-filled new series that proves friendship really is the best medicine. Join Jasmine aka \"Jaz\" and Nesha, two vibrant personalities who went from online strangers to inseparable friends and roommates, as they embark on a mission to reclaim their health.",
                    "image": "https://static.tvmaze.com/uploads/images/medium_portrait/567/1419956.jpg"
                },
                "relationships": {
                    "distributors": [
                        {
                            "id": "b88c90f2-f8b9-4c82-81a8-ec537a13854a",
                            "name": "TLC",
                            "country": "United States",
                            "kind": "network"
                        }
                    ],
                    "episodes": [
                        {
                            "id": "f32485bb-0d34-43f5-a1cd-2018796f35fc",
                            "episode_id": 3271039,
                            "episode_name": "TBA",
                            "airdate": "2025-06-17",
                            "airstamp": "2025-06-18T02:00:00.000Z",
                            "runtime": 60,
                            "season": 1,
                            "number": 3
                        },
                        {
                            "id": "d1b95871-408e-47ac-8f31-05c47a0a8025",
                            "episode_id": 3271040,
                            "episode_name": "Give Me S'More",
                            "airdate": "2025-06-24",
                            "airstamp": "2025-06-25T02:00:00.000Z",
                            "runtime": 60,
                            "season": 1,
                            "number": 4
                        }
                    ]
                }
            }
        }
.............
```

**Fetch a given TV Show**
```bash
GET /api/v1/tv_shows/:id
curl -X GET http://localhost:3000/api/v1/tv_shows/YOUR_TV_SHOW_ID_HERE \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json"

```

Response example:
```json
{
    "data": {
        "type": "tv_show",
        "id": "4deaaa83-f77c-425d-81e1-b65b195bfb01",
        "attributes": {
            "name": "1000-lb Roomies",
            "language": "English",
            "premiered": "2025-06-03",
            "status": "Running",
            "rating": null,
            "summary": "<p><b>1000-lb Roomies </b>a bold, unfiltered and heart-filled new series that proves friendship really is the best medicine. Join Jasmine aka \"Jaz\" and Nesha, two vibrant personalities who went from online strangers to inseparable friends and roommates, as they embark on a mission to reclaim their health.</p>",
            "image": "https://static.tvmaze.com/uploads/images/medium_portrait/567/1419956.jpg"
        },
        "relationships": {
            "distributors": [
                {
                    "id": "b88c90f2-f8b9-4c82-81a8-ec537a13854a",
                    "name": "TLC",
                    "country": "United States",
                    "kind": "network"
                }
            ],
            "episodes": [
                {
                    "id": "f32485bb-0d34-43f5-a1cd-2018796f35fc",
                    "episode_id": 3271039,
                    "episode_name": "TBA",
                    "airdate": "2025-06-17",
                    "airstamp": "2025-06-18T02:00:00.000Z",
                    "runtime": 60,
                    "season": 1,
                    "number": 3
                },
                {
                    "id": "d1b95871-408e-47ac-8f31-05c47a0a8025",
                    "episode_id": 3271040,
                    "episode_name": "Give Me S'More",
                    "airdate": "2025-06-24",
                    "airstamp": "2025-06-25T02:00:00.000Z",
                    "runtime": 60,
                    "season": 1,
                    "number": 4
                }
            ]
        }
    }
}
```

**Query Parameters**

You can pass the following query parameters to the GET /api/v1/tv_shows endpoint to filter the results:

| Name         | Type    | Description                                                                 |
|--------------|---------|-----------------------------------------------------------------------------|
| `date_from`  | String  | Filter by premiere start date (format: `YYYY-MM-DD`)                        |
| `date_to`    | String  | Filter by premiere end date (format: `YYYY-MM-DD`)                          |
| `language`   | String  | Show language (e.g., `"English"`)                                           |
| `distributor`| String  | Distributor name (e.g., `"Netflix"`)                                        |
| `country`    | String  | Distributor country (e.g., `"US"`)                                          |
| `page`       | Integer | Page number for pagination (default depends on backend pagination settings) |


## Trade-offs and Design Decisions

### Data Import Strategy
The application fetches upcoming TV show episodes from the TVMaze API over a configurable number of future days (default: 90). This is handled by a dedicated background job via Sidekiq.

Design decisions:

Daily Granularity: Rather than bulk-fetching all future shows in a single request (which could lead to very large payloads or request failures), we fetch data day-by-day to keep payloads small and retries safer.

Rate Limiting: Since TVMaze's free tier has strict rate limits, we introduce a small sleep delay (0.5s) between each daily API call. This avoids triggering 429 errors while preserving reliability.

Single Responsibility Services: Each part of the import pipeline (fetching, transforming, and persisting) is handled by a dedicated service class. This allows for easier testing and maintainability.

### Data Persistence: Upserts vs. Batches
Each episode returned by TVMaze is parsed and stored by extracting:

The TV show details

Its distributor (network or web channel)

The specific episode release info

Trade-offs:

Use of upsert: We use ActiveRecord.upsert operations for TvShow, Distributor, and Release records to ensure idempotency, allowing repeated imports without duplicating data.

Why not upsert_all?: While upsert already bypasses validations and callbacks, it operates on individual records, making multiple round-trips to the database. upsert_all, on the other hand, enables batch inserts in a single query, significantly reducing DB load.

However, upsert_all requires building bulk data arrays manually and lacks error-level granularity, if one row fails validation at the DB level, the entire batch can fail. Additionally, because the import logic involves nested associations and value object parsing, batching would increase complexity.

Future Consideration: If performance becomes a bottleneck (e.g., thousands of records per day), we could refactor the StoreBroadcastData service to accumulate rows and perform batched upsert_all operations for each model (TvShow, Distributor, Release).

### Authentication with Devise + JWT
This is an API-only Rails application, so we chose Devise with JWT for token-based authentication.

Why JWT?

Stateless: No need to maintain server-side sessions, which aligns with our goal of a lightweight, scalable API.

Frontend Compatibility: Easily consumed by single-page apps (SPAs) or mobile clients via Authorization: Bearer <token> headers.

Easy Expiry & Revocation: JWTs can be configured with TTLs or blacklisted via token revocation strategies if needed.

Additional Notes:

Current User Endpoint: A GET /current_user endpoint is available to allow frontend clients to retrieve the authenticated user's details after login.

Structured Responses: All authentication responses (signup, login, logout) return consistent JSON payloads, allowing easy consumption by React Native, Flutter, or browser-based UIs.

## Deployment Plan

### Required AWS Services

| Service                          | Purpose                                                                  |
|----------------------------------|---------------------------------------------------------------------------|
| `EC2 or ECS (Fargate)`           | Runs the Rails app (API-only). ECS Fargate preferred for scaling.        |
| `RDS (PostgreSQL)`               | Managed relational database for app data.                                |
| `ElastiCache (Redis)`            | Used for Sidekiq background jobs.                                        |
| `S3`                             | *(Optional)* Store logs, backups, or future uploads.                      |
| `CloudWatch`                     | Centralized logs and alerting.                                           |
| `Secrets Manager`                | Secure storage for Rails credentials, DB passwords, JWT secrets.         |
| `IAM`                            | Minimal-permission roles for services (e.g., ECS task roles).            |
| `VPC + Subnets`                  | Isolated, secure networking. Public/private subnet split.                |
| `ALB (Application Load Balancer)`| HTTP(S) load balancing and routing.                                      |
| `Route 53`                       | DNS management for custom domain (e.g., `api.showdrop.io`).              |
| `ACM (SSL Certificates)`         | Free TLS certificates for HTTPS (used with ALB).                         |

### Deployment Process (CI/CD)
CI/CD Stack Example:

- GitHub + GitHub Actions

- Docker-based deploys

- Secrets via GitHub Actions → AWS Secrets Manager
```text
1. Developer pushes to `main` branch
2. GitHub Actions pipeline:
   - Runs tests (RSpec, rubocop, etc.)
   - Builds Docker image
   - Pushes to ECR (Elastic Container Registry)
   - Deploys to ECS (Fargate) or EC2 via SSH
3. Post-deploy hook:
   - Runs DB migrations
```

### Authentication & Authorization
- JWT-based Auth using Devise + JWT

- Token expiration + jti blacklist (handled in User model)

- Authorization logic handled at controller/service level

- HTTPS enforced via ACM + ALB

- Secrets like DEVISE_JWT_SECRET_KEY stored in AWS Secrets Manager

- CORS configured to allow only trusted frontend domains

### Cost-Awareness Notes
- Use Fargate for autoscaling + no server maintenance

- Select t4g.micro/t4g.small for Sidekiq (low-cost ARM instances)

- RDS with automatic backups but smaller instance class for dev/staging

- CloudWatch log retention policy to avoid long-term costs

- Use Savings Plan or Compute Optimizer recommendations for prod traffic
