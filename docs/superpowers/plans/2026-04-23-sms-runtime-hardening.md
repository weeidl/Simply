# SMS Runtime Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Android SMS reception resilient by queueing unsynced SMS locally, centralizing sync logic, and cleaning the Android runtime configuration.

**Architecture:** Incoming SMS is normalized into an app payload, sent through a dedicated sync service, and persisted to a local secure queue whenever the remote write cannot complete. Auth/session bootstrap and runtime init both flush the queue once encryption and auth are available again.

**Tech Stack:** Flutter, Firebase Auth, Cloud Firestore, another_telephony, flutter_secure_storage, flutter_test

---

### Task 1: Add core SMS sync tests

**Files:**
- Create: `test/notification/incoming_sms_sync_service_test.dart`
- Create: `test/repositories/pending_incoming_sms_repository_test.dart`

- [ ] Write failing tests for queue-on-failure behavior.
- [ ] Write failing tests for flush-on-success behavior.
- [ ] Write failing tests for deduped queue persistence.

### Task 2: Add the normalized incoming SMS model and pending queue

**Files:**
- Create: `lib/models/incoming_sms_payload.dart`
- Create: `lib/repositories/pending_incoming_sms_repository.dart`
- Modify: `lib/security/secure_storage_service.dart`

- [ ] Implement the payload model and deterministic dedupe key.
- [ ] Implement secure-storage-backed pending queue helpers.
- [ ] Keep queue serialization compact and deterministic.

### Task 3: Centralize incoming SMS sync

**Files:**
- Create: `lib/bloc/notification/incoming_sms_sync_service.dart`
- Modify: `lib/bloc/notification/background_message.dart`
- Modify: `lib/screens/home/cubit/fcm_cubit.dart`

- [ ] Implement a sync service that either writes immediately or enqueues.
- [ ] Reuse the same service from foreground and background handlers.
- [ ] Flush pending SMS during runtime initialization.

### Task 4: Flush pending SMS during auth/session recovery

**Files:**
- Modify: `lib/screens/auth/cubit/auth_cubit.dart`
- Modify: `lib/screens/splash/cubit/splash_cubit.dart`

- [ ] Flush pending SMS after successful sign-in/sign-up.
- [ ] Flush pending SMS after restoring a valid encrypted session.

### Task 5: Clean Android config

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `android/app/build.gradle`
- Modify: `android/gradle.properties`

- [ ] Remove the nonexistent foreground service declaration.
- [ ] Raise `compileSdkVersion` to match plugin requirements.
- [ ] Keep build output warning noise under control without changing more than necessary.

### Task 6: Verify the runtime

**Files:**
- Modify: `docs/06_FIX_PROGRESS.md`

- [ ] Run targeted tests for the new queue and sync service.
- [ ] Run `dart analyze`.
- [ ] Run `./gradlew :app:assembleDebug`.
- [ ] Record the fix in docs once verification is complete.
