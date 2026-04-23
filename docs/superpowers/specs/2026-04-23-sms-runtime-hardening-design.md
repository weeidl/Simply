# SMS Runtime Hardening Design

**Date:** 2026-04-23

## Goal

Make Android SMS reception reliable in foreground and background, prevent silent
message loss when sync is temporarily impossible, and simplify the runtime
architecture so the SMS pipeline is easier to reason about and maintain.

## Problems

1. The current `FcmCubit` mixes unrelated responsibilities: SMS listener setup,
   local notification setup, and message persistence.
2. Incoming SMS writes can fail when auth or encryption state is not ready, and
   those failures are currently swallowed, which makes the app look "dead".
3. The manifest declares a foreground service that does not exist, while the app
   only shows an ongoing notification and does not actually start a foreground
   service.
4. The Android config is behind dependency requirements (`compileSdkVersion 34`
   while secure storage is built against newer SDKs).

## Design

### 1. Separate receive from sync

Introduce a dedicated SMS sync service that receives a normalized incoming SMS
payload and tries to persist it. If persistence fails, the payload is stored in
an encrypted local queue instead of being dropped.

### 2. Add a persistent pending queue

Add a small repository backed by secure storage for pending incoming SMS
payloads. This queue will be drained after auth/session restoration and when the
SMS runtime is initialized in the authenticated area of the app.

### 3. Normalize the incoming message shape

Create a small app-level payload model for incoming SMS so foreground and
background handlers share the same logic and do not duplicate mapping from the
plugin `SmsMessage` type into domain objects.

### 4. Clean Android runtime config

Remove the bogus foreground-service manifest entry, keep the visible
notification as an informational notification only, and align the project's
`compileSdkVersion` with the dependency floor.

## Intended Outcome

1. SMS reception continues to work even when Firestore writes temporarily fail.
2. Failed SMS writes are retried later instead of disappearing.
3. The runtime responsibilities are easier to test and easier to evolve.
4. Android build configuration stops drifting away from dependency expectations.
