# Spark maintenance module

Maintenance is independent of price predictions. It uses km, integer PKR paisa,
and Asia/Karachi reminder times. It requires an authenticated Firebase account.

## Firebase setup (not deployed by the code change)

Review `firestore.rules` against the currently deployed rules before deploying.
The file preserves the repository's profile and evaluation paths, but a remote
project may have additional collections/fields that must be merged first.

After review, deploy with your Firebase CLI:

    firebase deploy --only firestore:rules,firestore:indexes --project autometric-ai

No Functions, Cloud Storage, billing upgrade, FCM server, or API secrets are used.
Index exemptions prevent image payloads, notes, and embedded schedules from
generating unnecessary indexes. Existing unrelated remote index overrides must
be preserved when merging. Until the maintenance paths are allowed by your live
rules, writes may return permission-denied.

## Resource bounds

- One garage metadata listener, bounded to 50 vehicles including archived cars.
- One reminder-preferences listener. Both are disposed with the account shell.
- Up to 20 active service types per vehicle, embedded in vehicle metadata.
- History loads 20 records at a time, only inside the selected car.
- Car photos are not supported; vehicles use a small purple car icon. Receipt
  images are fetched only when viewed and capped at 200 KB JPEG, with input files
  capped at 5 MB. Base64 adds overhead. Legacy car-photo documents are ignored,
  not downloaded or silently deleted; deleting a car still cleans its attachments.
- Images are optional compressed copies, not archival documents. Spark quotas
  still apply, including storage, reads, writes, and network transfer.
- Reminder states are derived from schedules, not duplicated in a polling inbox.
  Read state and snooze are persisted per service cycle.
- Hourly foreground checks use local arithmetic, not network polling.
- Native alarms are inexact, with a rolling maximum of 64 scheduled alarms.
  There is no continuously running Android service or location tracking.

## Mileage and schedules

Confirmed mileage is never overwritten by forecasts. A weekly driving estimate
is optional; two readings at least seven days apart provide a measured rate.
After 60 days without a reading, mileage forecasts are withheld. Distance and
calendar intervals are user-defined; whichever confirmed threshold is reached
first determines due status. Templates name service types, not universal service
intervals. Empty interval fields mean a one-off service. Schedule-only records
are explicitly distinguished from completed services.

Historical records cannot roll back current mileage or overwrite a newer service
schedule of the same type. Odometer corrections reset measured driving rate;
the user must review existing service thresholds after a replacement/correction.
Snoozing changes alert timing only. Marking read changes inbox state, not the
maintenance deadline. Vehicle deletion archives first, prevents new child writes,
deletes child collections in bounded batches, then deletes the parent and updates
the garage count. Failed deletion can be retried from the archived car.

## Notifications

Android uses a small platform channel backed by AlarmManager, private notification
content, persisted pending jobs, a notification permission request, and a boot/
package-update receiver. No exact-alarm permission is requested. Logout clears
scheduled reminders. Permission denial and OS/battery restrictions can prevent
delivery. Service changes on web are not known to a closed Android app until it
is reopened; notifications therefore ask the user to check service status.

Web alerts are optional, permission-gated, HTTPS-only, foreground-only, capped at
three per reconciliation, and deduplicated in localStorage. Some mobile browsers
do not support the foreground Notification constructor; the in-app centre is the
fallback. Cross-tab claims are best effort, not a transactional server guarantee.
There are **no automatic web reminders after the site closes** on this Spark-only
architecture. Local clocks drive status calculations; they are not a trusted
server clock. Reminder times are restricted to 08:00–20:00 Pakistan time.

## Verification

    flutter test
    node --test test/browser_reminders_test.cjs
    firebase emulators:exec --only firestore --project demo-autometric-maintenance --config firebase.emulator.json "node test/firestore_rules_test.cjs"

The demo-project emulator command never accesses live Firebase. It requires a
compatible Java runtime and may download the emulator. Repository tests use an
in-memory fake and are **not** substitutes for testing deployed security rules.
On this machine Gradle 8.12 needs the installed Java 21 rather than Android
Studio's Java 25; use a per-build JAVA_HOME override, not a global config change.

Before release, test notification permission denial, reboot restoration, tapping
notifications from closed/running app states, logout cancellation, and web alerts
on real devices/browsers. Those delivery behaviours cannot be proven by widget
tests or successful builds alone.
