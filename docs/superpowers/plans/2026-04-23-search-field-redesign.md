# Search Field Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the reusable search field so it looks like a single polished pill control and becomes the standard search component for the app.

**Architecture:** Evolve `WarmSearchField` in place into a true reusable search control with a cleaner API and consistent interaction states, then apply it to the current messages-list usage without changing search logic.

**Tech Stack:** Flutter, flutter_test

---

### Task 1: Add widget tests for the new search control API

**Files:**
- Create: `test/widget/warm_search_field_test.dart`

- [ ] Add a failing test for trailing action support.
- [ ] Add a failing test for input change propagation.
- [ ] Add a failing test for read-only tap handling.

### Task 2: Redesign `WarmSearchField`

**Files:**
- Modify: `lib/screens/widget/warm/warm_search_field.dart`

- [ ] Refactor the component API to support proper trailing actions and interaction hooks.
- [ ] Redesign the shell so the field reads as one cohesive pill control.
- [ ] Keep the component generic enough for future screens.

### Task 3: Apply the component to the messages screen

**Files:**
- Modify: `lib/screens/messages_list/screen/messages_list_screen.dart`

- [ ] Update the current usage to the new API.
- [ ] Tune spacing if needed so the field matches the intended visual hierarchy.

### Task 4: Verify

**Files:**
- None

- [ ] Run the new widget test.
- [ ] Run `dart analyze`.
- [ ] Run `flutter test`.
