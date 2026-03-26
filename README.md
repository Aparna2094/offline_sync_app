# Offline Sync Flutter App

##  Overview

This project demonstrates a **local-first Flutter app** with:

* Offline reads (cached data)
* Offline writes (queue-based sync)
* Retry mechanism with backoff
* Idempotent operations
* Conflict resolution (Last Write Wins)

---

##  Tech Stack

* Flutter
* Firebase Firestore
* Hive (local database)
* State Management: (Bloc / Riverpod)

---


##  Features

###  Local-first UX

* Cached data shown instantly
* Background sync updates UI

### Offline Writes

* Add note
* Like note
* Stored in Hive queue when offline

###  Retry Mechanism

* 1 retry with 2-second delay

###  Idempotency

* Unique IDs prevent duplicate writes

###  Conflict Resolution

* Last Write Wins using `updatedAt`

###  Observability

* Logs for:

  * Queue size
  * Sync success/failure
  * Retry attempts

---



##  Demo Scenarios

### Scenario 1: Offline Add Note

* Turn off internet
* Add note
* Appears instantly
* Queue updated

###  Scenario 2: Offline Like

* Like note while offline
* Stored in queue

### Scenario 3: Retry

* Simulate failure
* Retry triggers
* No duplicate created

###  Scenario 4: Sync

* Turn internet ON
* Click Sync
* Queue becomes empty

---

## Sample Logs

```
 Sync started...
 Queue size: 5
 Failed: add_note
 Retrying...
 Retry success
 Queue after sync: 0
```

---

##  Design Decisions

### Idempotency

Used Firestore document ID to avoid duplicate writes.

### Conflict Strategy

Used Last Write Wins based on timestamp.

### Queue Persistence

Hive ensures queue survives app restart.

---



Setup Instructions
1. Clone the Repository

	git clone https://github.com/Aparna2094/offline_sync_app
	cd offline-sync-app

2. Install Dependencies

	flutter pub get

3. Configure Firebase

	Create a project in Firebase Console
	Add Android/iOS app
	Download google-services.json (Android) or GoogleService-Info.plist (iOS)
	Place files in respective directories
	Enable Firestore Database
4. Run the App

	flutter run

Firestore Rules (For Testing)

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}

##  AI Prompt Log

AI Prompt Log

1. Prompt:

   * How to implement offline queue in Flutter using Hive?

   Key response summary:

   * Suggested storing actions in a local queue with retry mechanism.

   Decision:

   * Accepted

   Why:

   * Matches offline-first requirement.

2. Prompt:

   * How to implement idempotency in Firebase?

   Key response summary:

   * Use document ID to avoid duplicates.

   Decision:

   * Accepted

   Why:

   * Ensures safe retries without duplication.

3. Prompt:

   * How to handle sync retries in Flutter?

   Key response summary:

   * Use retry count and delay (backoff).

   Decision:

   * Modified

   Why:

   * Limited to one retry as per assignment.


##  Demo Video

https://drive.google.com/file/d/1XGJKepNceM9wdqKdTUvow0r-BuQC3RnA/view?usp=sharing
