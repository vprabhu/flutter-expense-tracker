# Flutter Expense Tracker

**Brutally simple expense tracker MVP built with Flutter & Firebase. Shipped in 5 days as a live accountability challenge.**

## Features
- Add expense (amount, category, note)
- View expense list (date, amount, category)
- Edit and delete expenses
- Secure sign-in (Email/Auth)
- Cloud sync via Firestore

## Getting Started

1. **Clone the repo**
2. Open in VSCode/Android Studio
3. Add your Firebase keys (`google-services.json`)
4. Run on device/emulator

## Why this MVP?

To show what happens when you stop making excuses and actually ship—publicly, relentlessly, in 5 days. All progress, bugs, and fixes are live and documented.

## Roadmap

- Polish UI
- Add summary screen
- Take feature requests—build what users actually want

## Contributions & Feedback

Open issues, fork, or message me on LinkedIn. All feedback, critique, and feature requests wanted.

---

rules_version = '2';

service cloud.firestore {
match /databases/{database}/documents {

    // This rule allows anyone with your Firestore database reference to view, edit,
    // and delete all data in your Firestore database. It is useful for getting
    // started, but it is configured to expire after 30 days because it
    // leaves your app open to attackers. At that time, all client
    // requests to your Firestore database will be denied.
    //
    // Make sure to write security rules for your app before that time, or else
    // all client requests to your Firestore database will be denied until you Update
    // your rules
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 11, 24);
    }
}
}