# Campfire - Backend Requirements

## Overview
露營行程規劃系統的後端需求，對應前端 `index.html` 的資料處理邏輯。

目前前端使用 `localStorage` 做資料持久化，後端需將這些狀態遷移至 server-side 儲存，以支援多人即時協作。

---

## Data Models

### 1. Members（成員）
```
Member {
  id: number
  name: string
  group: 'A' | 'B' | 'C'    // A=林口, B=高鐵站, C=楊梅
  avatar: string | null       // base64 or URL
  color: string               // hex color for default avatar
}
```
**API Endpoints:**
- `GET /api/members` — 取得所有成員
- `PUT /api/members/:id` — 更新成員名稱 / 頭像
- `POST /api/members/:id/avatar` — 上傳頭像圖片（需圖片處理 & 儲存）

### 2. Confirmation（行程確認）
```
Confirmation {
  memberName: string
  confirmed: boolean
  confirmedAt: datetime
}
```
**API Endpoints:**
- `GET /api/confirmations` — 取得所有確認狀態
- `POST /api/confirmations` — 確認行程（body: `{ name: string }`）

### 3. Packing Checklist（物品清單勾選）
```
PackingCheck {
  userId: string              // 識別使用者（cookie/session）
  itemKey: string             // e.g. "group-0-1", "personal-2-0"
  checked: boolean
}
```
**API Endpoints:**
- `GET /api/packing/:userId` — 取得該使用者的勾選狀態
- `PUT /api/packing/:userId` — 批次更新勾選狀態

---

## Static Data (Read-Only)

以下資料目前寫死在前端，可保留為前端常數或移至後端 config：

### Schedule（行程表）
- DAY 1: 10 個時間點（含高鐵班次表）
- DAY 2: 3 個時間點
- 含「待確認」標記的項目（午餐、晚餐菜單）

### THSR Trains（高鐵班次）
- 左營 → 桃園，3 個建議班次
- 含推薦標記

### Packing Lists（物品清單）
- 團體公用：4 類別，共 ~20 項
- 個人物品：4 類別，共 ~14 項

### Campsite Info（營地資訊）
- 地址、設備、交通路線、注意事項

---

## Real-time Features（建議）

若需多人即時協作，建議加入：
- **WebSocket / SSE** — 行程確認狀態即時同步
- **Optimistic UI** — 前端先更新再等後端回應

---

## Storage Considerations

| 資料 | 目前方式 | 建議方案 |
|------|---------|---------|
| 成員資料 | localStorage | DB (SQLite / PostgreSQL) |
| 頭像圖片 | base64 in localStorage | Object Storage (S3 / local uploads/) |
| 行程確認 | localStorage | DB |
| 物品勾選 | localStorage | DB (per-user) |
| 行程/營地資訊 | 前端常數 | JSON config 或 DB |

---

## Tech Stack Suggestion

- **Runtime:** Node.js / Python (FastAPI)
- **Database:** SQLite (MVP) → PostgreSQL (production)
- **File Storage:** Local `uploads/` → S3-compatible
- **Auth:** Simple cookie-based session (無需帳號系統，選名字即可)
