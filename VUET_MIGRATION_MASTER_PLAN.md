# Vuet Migration – Master Plan  
_Comprehensive blueprint for recreating the React / Django Vuet application as a Flutter / Supabase, multi-platform product._

---

## 1. SYSTEM ANALYSIS (Current React + Django)

| Layer | Key findings | Complexity hot-spots |
|-------|--------------|----------------------|
| **Frontend (React Native / Expo)** | • ~~250 screens/components, Redux store per domain slice.<br>• Navigators for auth, category, entity, tasks, settings.<br>• Rich form engine, camera/upload, push-notification handling. | • Deep component tree coupling to Redux actions. |
| **Backend (Django + DRF)** | • ~80 polymorphic models across `categories`, `entities`, `tasks`, `routines`, `lists`, `messages`, etc.<br>• JWT auth + phone/email validation.<br>• Celery cron + signals for reminders & notifications. | • Polymorphic `Entity` and `Task` hierarchies.<br>• Complex permission checks (family, friends, professionals). |
| **Data Relationships** | • 13 **core categories** + unlimited **professional categories** (user-defined).<br>• **Entity** is a polymorphic base; sub-classes per life domain (Car, Pet, Trip…).<br>• **Tasks**: `FixedTask` *or* `FlexibleTask` + optional `Recurrence`, `TaskAction`, `Reminder`, completion & overwrite records. | • Many-to-many between tasks ↔ entities ↔ users.<br>• Tagging, reference groups, timeblocks, routines. |
| **Real-time & Integrations** | • Push notifications (Expo + FCM/APNs).<br>• Calendar export/import (iCal).<br>• S3 image storage with presigned URLs. | • Multi-device sync, family membership filters. |

---

## 2. ARCHITECTURE MAPPING (React/Django ➜ Flutter/Supabase)

| Domain | React / Django Artifact | Flutter Counterpart | Supabase Counterpart |
|--------|-------------------------|---------------------|----------------------|
| Categories | `Category` model, Redux slice | Riverpod `categoriesProvider`, Category widgets | `categories` table (seeded), RLS: public read, owner write |
| Professional Categories | `ProfessionalCategory` + mapping | `profCategoriesProvider` | `professional_categories`, `professional_entity_category_mapping` |
| Entities | Polymorphic `Entity` + ~15 sub-models | `EntityModel` sealed class + subtype enums, JSON (de)serialisers | Single `entities` table with `type` & `subtype` columns, storage bucket for images |
| Tasks | `FixedTask`, `FlexibleTask`, `Recurrence`, `TaskAction` … | `TaskModel` sealed union + helpers | `tasks`, `recurrences`, `task_actions`, `task_reminders`, `task_members`, etc. |
| Users & Families | Django `User`, `EntityMembership`, `Family` relationships | Supabase Auth user object + row-level joins | `profiles`, `families`, `family_members`, RLS for shared access |
| Real-time | DRF + WebSockets for alerts | `supabaseRealtime` streams, Flutter notifications | Realtime enabled on `alerts`, `tasks`, `messages` |
| Media | S3 + presigned | `supabase.storage` | Storage buckets `entities`, `lists`, `messages` |

---

## 3. DATABASE SCHEMA (Supabase / PostgreSQL)

### Core reference tables
```sql
create table categories (
  id smallint primary key,
  name text not null unique,
  readable_name text not null,
  is_premium boolean default false
);

create table professional_categories (
  id bigserial primary key,
  user_id uuid references auth.users on delete cascade,
  name text not null
);
```

### Entities (polymorphic)
```sql
create table entities (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references auth.users on delete cascade,
  category_id smallint references categories,
  type text not null,          -- e.g. CAR, PET, TRIP
  subtype text,                -- free string for fine grained types
  name text not null,
  notes text default '',
  image_path text,             -- storage reference
  hidden boolean default false,
  parent_id uuid references entities,
  created_at timestamptz default now()
);
create index on entities (owner_id);
```

### Entity ↔ Professional category map
```sql
create table professional_entity_category_mapping (
  entity_id uuid references entities on delete cascade,
  professional_category_id bigint references professional_categories on delete cascade,
  user_id uuid references auth.users on delete cascade,
  primary key (user_id, entity_id)
);
```

### Tasks & Scheduling
```sql
create table tasks (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  type text not null,          -- TASK, APPOINTMENT, ...
  hidden_tag text,
  notes text,
  location text,
  contact_name text,
  contact_email text,
  contact_phone text,
  duration integer,            -- minutes (for flexible tasks or fixed when no end)
  earliest_action_date date,
  due_date date,
  start_datetime timestamptz,
  end_datetime timestamptz,
  start_date date,
  end_date date,
  created_at timestamptz default now()
);
create table task_members (
  task_id uuid references tasks on delete cascade,
  member_id uuid references auth.users on delete cascade,
  primary key (task_id, member_id)
);

create table recurrences (
  id bigserial primary key,
  task_id uuid references tasks on delete cascade unique,
  recurrence text not null,        -- DAILY, WEEKLY...
  interval_length int default 1,
  earliest_occurrence timestamptz,
  latest_occurrence timestamptz
);

create table task_actions(
  id bigserial primary key,
  task_id uuid references tasks on delete cascade,
  action_timedelta interval not null default interval '1 day'
);

create table task_reminders(
  id bigserial primary key,
  task_id uuid references tasks on delete cascade,
  timedelta interval not null default interval '1 day'
);
```

### RLS strategy
* `entities`: `SELECT` where `owner_id = auth.uid() OR auth.uid() IN (select member_id from entity_members where entity_id = id)`
* `tasks`: similar with `task_members`
* Admin service role bypasses policies for background jobs.

---

## 4. FLUTTER ARCHITECTURE

```
vuet_flutter/
├─ lib/
│  ├─ core/                # shared utils, constants
│  ├─ data/
│  │   ├─ models/          # freezed data classes
│  │   ├─ services/        # Supabase repositories
│  ├─ features/
│  │   ├─ auth/
│  │   ├─ categories/
│  │   ├─ entities/
│  │   ├─ tasks/
│  │   ├─ calendar/
│  │   └─ notifications/
│  ├─ routing/             # GoRouter setup
│  └─ main.dart
├─ test/
├─ web/                    # flutter_web index.html tweaks
```

* **State Management**: **Riverpod 2** (scalable, testable, supports code-gen).  
* **Data Layer**: `supabase_flutter` + repository pattern.  
* **Navigation**: **GoRouter** (Navigator 2 API, deep linking).  
* **Responsive UI**: `flutter_screenutil` + adaptive layouts; Material 3.  
* **Form Engine**: `reactive_forms` replicates complex React forms.  
* **Local Cache / Offline**: `hive` for critical entities/tasks.

---

## 5. IMPLEMENTATION PHASES

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| P0 ‑ Foundation | 1 w | • Repo setup, CI pipeline<br>• Supabase schema + RLS migration scripts<br>• Auth flow (email, phone)<br>• Category seeding script |
| P1 ‑ Core Data | 2 w | • Entity CRUD UI + image upload<br>• Task CRUD (fixed + flexible)<br>• Riverpod providers, repository tests |
| P2 ‑ Scheduling & Recurrence | 1.5 w | • Recurrence builder UI<br>• Supabase edge fn for occurrence generation<br>• Calendar view widgets |
| P3 ‑ Collaboration | 1 w | • Family sharing, member permissions<br>• Realtime listeners for tasks & alerts |
| P4 ‑ Ancillary Features | 1 w | • References, routines, timeblocks<br>• Push notifications via Supabase Functions + FCM/APNs |
| P5 ‑ QA & Web Deploy | 0.5 w | • Widget tests, integration tests (Driver)<br>• Deploy Flutter Web to Cloudflare Pages; invite stakeholders for testing |
| P6 ‑ Mobile Polishing | 0.5 w | • Platform-specific tweaks (camera, share sheets)<br>• App icons, splash, onboarding |
| P7 ‑ Store Release | 1 w (overlap) | • Play Store AAB & TestFlight builds<br>• App Store review material |

_Total development estimate: **~8 weeks** including buffer._

---

## 6. DEPLOYMENT STRATEGY

| Platform | Toolchain | Hosting / Store | CI Stage |
|----------|-----------|-----------------|----------|
| **Web** | `flutter build web` | Cloudflare Pages (or Supabase Hosted) | push → GitHub Actions → Pages |
| **Android** | `flutter build appbundle` | Google Play (Internal track → Production) | GitHub Actions w/ signing-keystore secrets |
| **iOS** | `flutter build ipa` | TestFlight → App Store | GitHub Actions + manual notarization |
| **Database Migrations** | `supabase db push` + migrations folder | Supabase | Pre-deploy step |
| **Edge Functions** | `supabase functions deploy` | Supabase | Post-migrate step |
| **Versioning** | Conventional commits + semantic release | – | auto-tagging, changelog |

---

## Approval Checklist

- [ ] Master plan accepted  
- [ ] Service Role key supplied (for CI migrations & edge functions)  
- [ ] App Store / Play Store developer accounts (for publishing)  

Once approved I will:

1. Push schema SQL migrations and initial seed script to Supabase.
2. Scaffold the Flutter project exactly as per section 4.
3. Drive development through the implementation phases, demoing Web build after P5.

Let me know if any adjustment is required!
