# 04 - Security and Row Level Security (RLS) Guide

This document outlines mandatory security protocols based on the `/security` skill guidelines for both Frontend and Backend layers.

---

## 1. Secret Segregation & API Keys

- **Client Safe**: `VITE_SUPABASE_ANON_KEY` is public and restricted by Row-Level Security (RLS).
- **Prohibited in Client**: `SUPABASE_SERVICE_ROLE_KEY` must **NEVER** appear in client-side code, `.env`, or Vite bundles.
- **Git Protection**: Never commit secrets, service role keys, or personal tokens.

---

## 2. Row Level Security (RLS) Baseline

Every public database table **MUST** enforce RLS:

```sql
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
```

### Table Policy Matrix
- **Public Feed (`posts`, `products`)**:
  - `SELECT`: `USING (true)` (Anyone can view active posts)
  - `INSERT`: `WITH CHECK (auth.uid() = seller_id)`
  - `UPDATE`: `USING (auth.uid() = seller_id)`
  - `DELETE`: `USING (auth.uid() = seller_id)`
- **Private Data (`orders`, `notifications`)**:
  - `SELECT`: `USING (auth.uid() = buyer_id OR auth.uid() = seller_id)`
  - `INSERT`: `WITH CHECK (auth.uid() = buyer_id)`
  - `UPDATE`: `USING (auth.uid() = buyer_id OR auth.uid() = seller_id)`

---

## 3. Frontend Vulnerability Checklist

1. **XSS Prevention**:
   - Never use `dangerouslySetInnerHTML` or raw DOM injection without strict sanitization.
   - Text interpolation in React JSX is safe by default.
2. **Input Validation**:
   - Quantities and prices must be validated `> 0` on the client and guarded by database `CHECK (price >= 0)` constraints.
3. **PWA Storage Security**:
   - Do not store raw passwords or sensitive credentials in `localStorage`.
   - Use Supabase GoTrue session tokens handled via official SDK.
4. **Clickjacking Defense**:
   - Enforce `X-Frame-Options: DENY` in `vercel.json` or HTTP headers.
