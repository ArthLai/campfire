# Campfire - Backend Requirements

## Overview
露營行程規劃系統，前端使用 React (CDN) + Supabase 作為後端資料庫。

支援多人即時協作：成員資料（含簡介 bio）、行程確認狀態皆儲存在 Supabase，物品勾選保留在 localStorage（per-device）。

---

## Supabase Configuration

- **Project URL:** `https://hrulsakkhelwnsvpnakx.supabase.co`
- **Anon Key:** 已內嵌於 `index.html` 前端
- **Migration:** 請在 Supabase SQL Editor 執行 `supabase/migration.sql`

---

## Data Models

### 1. Members（成員）
```sql
members (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  "group" TEXT NOT NULL CHECK ("group" IN ('A', 'B', 'C')),
  avatar_url TEXT,
  color TEXT NOT NULL,
  bio TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
)
```

**Operations (via Supabase REST):**
- `SELECT * FROM members ORDER BY id` — 取得所有成員
- `UPDATE members SET name, bio, avatar_url WHERE id = ?` — 更新成員資料

### 2. Confirmations（行程確認）
```sql
confirmations (
  id SERIAL PRIMARY KEY,
  member_name TEXT NOT NULL UNIQUE,
  confirmed BOOLEAN DEFAULT TRUE,
  confirmed_at TIMESTAMPTZ DEFAULT NOW()
)
```

**Operations:**
- `SELECT * FROM confirmations` — 取得所有確認狀態
- `UPSERT INTO confirmations (member_name, confirmed)` — 確認行程

### 3. Packing Checklist（物品清單勾選）
```sql
packing_checks (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL,
  item_key TEXT NOT NULL,
  checked BOOLEAN DEFAULT FALSE,
  UNIQUE(user_id, item_key)
)
```

目前物品勾選保留在 localStorage（per-device），未來可遷移至 Supabase。

---

## Static Data (Read-Only)

以下資料寫在前端常數中：

- **Schedule（行程表）**: DAY 1 (11 項) + DAY 2 (3 項)
- **THSR Trains（高鐵班次）**: 左營→桃園 3 班次
- **Packing Lists（物品清單）**: 團體公用 4 類 + 個人物品 4 類
- **Campsite Info（營地資訊）**: 地址、設備、交通路線

---

## RLS (Row Level Security)

已設定 anon 角色可讀寫所有資料（簡易應用無需帳號系統）。

---

## Fallback 機制

當 Supabase 無法連線時，自動降級為 localStorage 離線模式，頁面右下角顯示同步狀態：
- ☁️ 已同步 — Supabase 連線正常
- 📱 離線模式 — 使用 localStorage
- 💾 儲存中... — 正在寫入 Supabase

---

## Setup Steps

1. 前往 [Supabase SQL Editor](https://hrulsakkhelwnsvpnakx.supabase.co)
2. 執行 `supabase/migration.sql` 建立 tables + seed data
3. 開啟 `index.html` 即可使用
