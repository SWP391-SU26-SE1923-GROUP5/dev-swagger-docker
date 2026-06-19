# AI Study Hub - Frontend Developer Guide

## Quick Start

### 1. Run Backend with Docker

```bash
# Start containers (API + Database)
docker-compose up -d

# Check status
docker ps
```

### 2. API Endpoint

```
http://localhost:5171
```

### 3. Swagger Documentation

```
http://localhost:5171/swagger
```

### 4. Connect from Frontend

Set your frontend's API base URL to:

```
http://localhost:5171
```

#### Example for React/Vue/Angular:

```env
# .env
VITE_API_BASE_URL=http://localhost:5171
```

```typescript
// api/client.ts
const API_BASE = 'http://localhost:5171';

// Login example
const response = await fetch(`${API_BASE}/api/Auth/login`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password })
});
```

---

## Container Status

| Container | Port | Status |
|-----------|------|--------|
| aistudyhub-api | 5171 | Running |
| aistudyhub-db | 1433 | Running |

---

## Useful Commands

```bash
# Stop containers
docker-compose down

# Restart containers
docker-compose restart

# View logs
docker logs aistudyhub-api

# Rebuild if needed
docker-compose up -d --build
```

---

## Default Admin Account

```
Email:    admin@aistudyhub.local
Password: ChangeThisAdmin123
```

---

## Need Help?

- API Documentation: http://localhost:5171/swagger
- Backend logs: `docker logs aistudyhub-api`
