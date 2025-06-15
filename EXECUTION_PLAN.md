# EXECUTION_PLAN.md
_Comprehensive hour-by-hour schedule for delivering an **exact Flutter/Supabase replica** of the current Vuet React-Native / Django application (Web, Android, iOS).  
Start time assumed **T = 0h** (immediately after plan approval)._

| Hr | Task Group | Concrete Actions | Deliverable / Milestone |
|----|------------|------------------|-------------------------|
| **0 → 1** | Environment bootstrap | • `flutter create vuet_flutter` (web enabled)  <br>• Add core deps: `supabase_flutter`, `flutter_riverpod`, `go_router`, `freezed`, `json_serializable`, `flutter_screenutil`, `reactive_forms`, `image_picker`, `flutter_local_notifications`, `timezone`, `firebase_messaging`, `file_picker`, `intl`. <br>• Configure Firebase for FCM keys (Android/iOS) <br>• Git repo & CI skeleton (GitHub Actions). | Repo pushed, CI green on `flutter test`. |
| **1 → 2** | Supabase schema push | • Create SQL migration file containing all tables in _Master Plan §3_. <br>• `supabase db push` using **service_role** key. <br>• Seed 13 core categories. <br>• Enable Storage buckets (`entities`, `lists`, `messages`). <br>• Add RLS policies (owner & family sharing). | Schema visible in Supabase dashboard; categories table populated. |
| **2 → 3** | Auth flow | • Implement `AuthRepository` (`signUpEmail`, `signInPassword`, `signInPhone`, `verifyOTP`). <br>• Riverpod `authProvider` w/ state & user profile fetch. <br>• Skeleton UI screens (login, signup, phone verify). | Able to register / login via email & phone; session persists. |
| **3 → 5** | Core app shell | • Set up `AppRouter` with guards (auth/unauthed). <br>• Layout scaffold: side-drawer (web), bottom-nav (mobile). <br>• Themes & responsive breakpoints with `ScreenUtil`. | Blank main dashboard reachable post-login. |
| **5 → 7** | Categories feature | • `CategoryModel` (freezed). <br>• `categoriesProvider` (cache categories). <br>• UI: Category grid identical to React version (icons, colours). <br>• Professional category CRUD dialogs. | Categories list & add/edit professional categories works (data persisted). |
| **7 → 11** | Entity system | • Single `EntityModel` with subtype enum + `fromJson`. <br>• `EntityRepository` CRUD incl. image upload to Storage & presigned URL retrieval. <br>• `entitiesProvider` (family filtered). <br>• Screens: Entity list, detail, create/edit forms (re-implement dynamic field sets per subtype). | Create, edit, delete entities (cars, pets, trips…) incl. photo in both web & mobile. |
| **11 → 16** | Task engine | _Split into 2 threads_  <br>**A (backend-edge)**  <br>• Write Supabase Edge Function `generate_recurrences` (cron triggered) replicating Django scheduler logic. <br>• Unit test locally via `supabase functions serve`.  <br>**B (frontend)**  <br>• `TaskModel` + `RecurrenceModel` + `task_actions`, `task_reminders`. <br>• `tasksProvider` with stream channel (Realtime). <br>• Forms: FixedTask, FlexibleTask, Recurrence builder modal (calendar pickers). <br>• Task list screens: overdue, today, upcoming. | Tasks can be created (fixed, flexible, recurring); generated occurrences appear; edits sync real-time. |
| **16 → 17** | Calendar & timezones | • Integrate `syncfusion_flutter_calendar` for Month / Agenda views. <br>• Feed tasks provider into calendar. <br>• Add iCal export edge function. | Calendar mirrors existing React “Calendar” screen. |
| **17 → 18** | Family sharing & permissions | • Tables `families`, `family_members`, RLS updates. <br>• UI: invite member (email/phone), accept flow. <br>• Member filters on entity/task lists. | Able to share family & see shared tasks/entities. |
| **18 → 19** | Notifications | • Edge function for push notifications on `INSERT` tasks/actions (FCM/APNs). <br>• Configure `firebase_messaging` in Flutter; background handler. | Test push arrives on device when task/action is due. |
| **19 → 20** | Ancillary modules | • References (groups + items) CRUD. <br>• Routines & Timeblocks basic screens. <br>• Lists & shopping delegation (core functions only). | Ancillary data mirrors original functionality. |
| **20 → 21** | Messages / chat | • Table `message_threads`, `messages`. <br>• Realtime subscription. <br>• Simple chat UI with sender bubbles identical to RN. | Send/receive messages across devices in real-time. |
| **21 → 22** | Settings & preferences | • Blocked/Preferred days, flexible task prefs UIs. <br>• Persist as rows in `user_settings`. | All settings pages match legacy app. |
| **22 → 23** | QA pass | • Run `flutter test` & widget tests. <br>• Manual smoke test web + Android emulator + iOS sim. <br>• Fix critical bugs, polish UI parity (spacing, colours). | Zero blocker defects. |
| **23 → 24** | Deployment | • `flutter build web` → deploy to Supabase hosting (`supabase@edge`). <br>• `flutter build appbundle` → upload to Play Console internal. <br>• `flutter build ipa` (CI keeps .ipa artefact). <br>• Tag release `v1.0.0`. | Web URL ready for user test; mobile builds in stores (internal/testing). |

---

## Risk & Contingency

| Risk | Mitigation |
|------|------------|
| Edge function performance for recurrence generation | Batch in chunks, index tasks table, use PG `generated column` for next occurrence. |
| iOS push certificate issues | Pre-create APNs key, use Expo-notifications as fallback. |
| Form engine complexity | Leverage `reactive_forms` + JSON driven configs matching existing form field types. |

---

## Notes for Overnight Work

* **Automated CI** posts build status to Slack every 2 h.  
* After Hr 12 (entity completion) a web link will be auto-deployed for interim review.  
* All secrets (service_role, anon, FCM keys, Apple key) stored in repo actions secrets.  

_User can check progress any time by opening the deployed web URL; milestones commit tagged `mX` in repo._

---  
**ETA to fully functional parity:** **24 hours** continuous build as per schedule above.  
Any unforeseen blocker may slip final polish (icons, store screenshots) to +4 h buffer.  
