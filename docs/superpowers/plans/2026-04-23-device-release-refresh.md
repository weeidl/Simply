# Device Release Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a release-quality refresh of the messages and devices experience with compact navigation, richer Android device metadata, source-aware SMS sync, and redesigned device cards.

**Architecture:** Extend the existing Firestore-backed models in a backward-compatible way, isolate Android-only telephony/SIM collection behind a dedicated runtime service, and rebuild the devices UI from those normalized fields instead of ad-hoc widget logic. Keep iOS on a safe receiver-only path with graceful fallbacks for older docs.

**Tech Stack:** Flutter, flutter_bloc, cloud_firestore, another_telephony, battery_plus, device_info_plus, Kotlin MethodChannel, flutter_test

---

### Task 1: Metadata foundation

**Files:**
- Modify: `lib/models/device.dart`
- Modify: `lib/models/conversation.dart`
- Modify: `lib/models/message.dart`
- Modify: `lib/models/incoming_sms_payload.dart`
- Create: `lib/models/device_sim_card.dart`
- Create: `lib/services/device_runtime_service.dart`
- Create: `android/app/src/main/kotlin/com/weeidl/simply/MainActivity.kt`

- [ ] Add backward-compatible model fields for SIM/runtime/source metadata and daily device activity.
- [ ] Isolate Android SIM/subscription lookup behind a runtime service with iOS-safe fallbacks.
- [ ] Persist current device context locally so foreground/background SMS sync can enrich payloads.

### Task 2: Repository and sync flow

**Files:**
- Modify: `lib/repositories/device_repository.dart`
- Modify: `lib/repositories/messages_repository.dart`
- Modify: `lib/security/messages_codec.dart`
- Modify: `lib/screens/devices/add_new_device/check_device_cubit.dart`
- Modify: `lib/screens/home/cubit/fcm_cubit.dart`
- Modify: `lib/bloc/notification/incoming_sms_sync_service.dart`
- Modify: `lib/security/secure_storage_service.dart`

- [ ] Thread the new metadata through device save/update flows.
- [ ] Enrich incoming SMS payloads with source device + SIM context before persistence.
- [ ] Update Firestore writes to store per-device daily counters and sparkline buckets without breaking existing docs.

### Task 3: Devices redesign

**Files:**
- Modify: `lib/screens/devices/cubit/device_cubit.dart`
- Modify: `lib/screens/devices/cubit/device_state.dart`
- Modify: `lib/screens/devices/screen/devices_screen.dart`
- Modify: `lib/screens/devices/widget/device_widget.dart`
- Modify: `lib/screens/devices/widget/device_info_widget.dart`

- [ ] Build a hero summary card based on live device/message aggregates.
- [ ] Split device cards into sender/full and receiver-only variants.
- [ ] Add subtle motion, sparkline rendering, and better empty/loading/error states.

### Task 4: Messages and navigation polish

**Files:**
- Modify: `lib/screens/messages_list/screen/messages_list_screen.dart`
- Modify: `lib/screens/messages_list/widget/messages_list_widget.dart`
- Modify: `lib/screens/messages_list/widget/avatar_with_indicator.dart`
- Modify: `lib/screens/widget/warm/warm_search_field.dart`
- Modify: `lib/screens/widget/warm/pill_tab_bar.dart`
- Modify: `lib/screens/settings/settings_screen.dart`
- Modify: `lib/themes/colors.dart`
- Modify: `lib/themes/shadows.dart`

- [ ] Reduce nav/search vertical height and tune outer spacing.
- [ ] Add a very light glass treatment to the nav bar.
- [ ] Increase message row breathing room and surface the new source metadata.
- [ ] Update the footer copy to the new weeidl wording.

### Task 5: Verification

**Files:**
- Create: `test/models/device_and_sms_metadata_test.dart`

- [ ] Add focused model/serialization tests for the new metadata flow.
- [ ] Run `dart format`, `flutter test`, and `flutter analyze`.
- [ ] Fix any issues found before wrapping up.
