# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**旅行邮箱 (Postcards)** is a travel postcard recording app built with UniApp (Vue 3 + TypeScript). It targets H5, WeChat Mini Program, Android, and iOS from a single codebase.

## Development Commands

```bash
# H5 web preview (fastest for development)
npm run dev:h5

# WeChat Mini Program
npm run dev:mp-weixin

# Android
npm run dev:app-android

# Production builds
npm run build:h5
npm run build:mp-weixin
npm run build:app-android
npm run build:app-ios
```

There are no test or lint commands configured — TypeScript type checking is the primary static validation.

## Android APK Packaging

Packaging requires HBuilderX (cloud build). See `PACKAGE.md` for the full guide. Key info:
- Keystore: keep `postcards.keystore` and passwords outside Git; use local release credentials only
- App ID: `__UNI__AFB5F4A`, package name `com.postcards.app`
- Supports `armeabi-v7a` and `arm64-v8a`

## Architecture

### Data Flow

All state lives in a single Pinia store (`src/stores/postcard.ts`). On app start, `initData()` loads from `uni.getStorageSync` (cross-platform local storage via `StorageUtil`). If no data exists, mock data from `src/data/mockData.ts` seeds the store automatically. Every mutation calls `saveToStorage()` immediately — there is no server backend.

### Core Models

- `Travel` (`src/model/Travel.ts`) — a trip with `TravelStatus` enum (planned/ongoing/completed/cancelled). The "current" travel is the one with `isCurrent: true` or status `ongoing`.
- `Postcard` (`src/model/Postcard.ts`) — belongs to a `Travel` via `travelId`. Has `stampDesign` (one of 6 themes), `isFavorite`, and timestamps `recordedAt`/`createdAt`.

### Pages (all use custom navigation bars)

Defined in `src/pages.json`. Tab bar pages: `home`, `timeline`, `record`, `map`, `profile`. Sub-pages: `detail` (view), `edit` (modify), `index` (splash screen that redirects after 2s).

### Styling

- Global SCSS variables auto-imported via Vite into every component (`@use "@/styles/variables.scss" as *`)
- Primary brand color: `$travel-blue: #2E7D58` (postal green)
- Page background: `$page-background: #FAF7F2` (warm off-white)
- All pages use a green gradient header (`#2E7D58 → #2E6E49`) with `border-radius: 0 0 48px 48px`
- All navigation bars use `navigationStyle: "custom"` — no native nav bars

### Icons

All icons come from `@phosphor-icons/vue`, re-exported with semantic aliases through `src/components/icons/index.ts`. Never write inline SVG; use this alias layer.

### UniApp Platform Notes

- Use `uni.*` APIs (not `wx.*` or native DOM) for storage, navigation, media, and geolocation
- `uni.navigateTo` / `uni.switchTab` for routing — no vue-router `push` on native platforms
- `StorageUtil` wraps `uni.getStorageSync/setStorageSync` — always use it instead of `localStorage`
- `src/utils/date.ts` and `src/utils/ui.ts` contain platform-safe helpers; avoid `Date.toLocaleString`, `Math.random()`, and other ArkTS-incompatible APIs

## Design Spec

`claude-design-prompt.md` contains the full UI/UX specification: color tokens, per-page layout rules, interaction patterns, stamp system (6 themes), and empty-state standards. Consult it when building or modifying any UI page.
