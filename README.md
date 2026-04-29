<div align="center">
  <h1>💰 Kipera</h1>
  <p><strong>Your Ultimate Savings Habits Companion</strong></p>

  <p>
    <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
    <img src="https://img.shields.io/badge/Riverpod-000000?style=for-the-badge&logo=dart&logoColor=white" alt="Riverpod" />
    <img src="https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  </p>
</div>

---

## 📖 About Kipera

**Kipera** is a beautifully crafted Flutter mobile application designed to help you build and maintain healthy savings habits. Through interactive saving methods, timely notifications, and an engaging achievements system, reaching your financial goals has never been this fun.

One of Kipera's core features is **Couple Goals**, allowing two users to share a savings goal and synchronize their progress in real-time through an intuitive invitation system, all powered by a robust *Offline-First* architecture.

## ✨ Key Features

- 🔄 **Offline-First Architecture:** Save your progress offline using SQLite (Drift) and automatically sync to the cloud once you regain internet connection.
- 👫 **Couple Goals:** Invite your partner or friends to share a savings goal. Progress is synchronized in real-time.
- 🎯 **Multiple Saving Methods:** 
  - *Free:* Progressive, Fixed Daily, Weekly Challenge.
  - *Premium:* Reverse Progressive, Random Envelopes, Multiplier, Bi-Weekly Steps, Penalty.
- 🏆 **Achievements & Trophies:** Celebrate your saving milestones (25%, 50%, 75%, 100%) with animations and badges.
- 📱 **Native Widgets:** Interactive home screen widgets for iOS (SwiftUI) and Android (Kotlin) to track your progress at a glance.
- 🔔 **Smart Reminders:** Custom local notifications ensuring you never miss your daily check-ins.
- 🌍 **Multilingual Support:** Fully localized in English and Spanish.

## 🛠️ Technology Stack & Architecture

Kipera is built using the best tools in the Flutter ecosystem:

- **Frontend:** [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/)
- **State Management:** [Riverpod](https://riverpod.dev/) (`Provider`, `StateNotifierProvider`, etc.)
- **Routing:** [GoRouter](https://pub.dev/packages/go_router) with `StatefulShellRoute` support for bottom tab navigation.
- **Local Database:** [Drift (SQLite)](https://drift.simonbinder.eu/) for offline persistence.
- **Backend & Auth:** [Supabase](https://supabase.com/) (Auth, Postgres Database, Realtime Sync).
- **Notifications:** `flutter_local_notifications` and `firebase_messaging`.
- **Charts & UI:** `fl_chart`, `flutter_animate`, `google_fonts` (ClashDisplay, Poppins).

### 🔄 Sync Engine (SyncService)
The system employs a *push-then-pull* pattern with *last-write-wins* conflict resolution based on `updated_at`. Local mutations are queued in a `sync_queue` table and pushed to Supabase when the user is online, guaranteeing zero data loss even if modifications occur without internet access.

## 🚀 Getting Started (Development)

Follow these steps to set up and run the project in your local environment.

### 📋 Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.9.2)
- [Supabase](https://supabase.com/) (Configured project)
- Firebase Account (for push notifications, optional for basic development)

### ⚙️ Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/TheGameApp/kipera.git
   cd kipera
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   Create a `.env` file in the root of the project based on `.env.example`:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Generate code (Drift, Freezed, JSON Serializable)**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
   *(Tip: Use `watch` instead of `build` to regenerate code in real-time during development).*

5. **Run the application**
   ```bash
   flutter run
   ```

## 📁 Project Structure

The application follows a Feature-Driven architecture to maintain scalability and readability:

```text
lib/
├── core/                   # Configurations, router, painters, global providers
├── database/               # Drift tables, DAOs, and local migration logic
├── features/               # App modules isolated by domain context
│   ├── auth/               # User authentication
│   ├── goals/              # Creation, management, and listing of savings goals
│   ├── invitations/        # Invitation system for couple goals
│   ├── sync/               # Core offline/online synchronization engine
│   └── widget/             # Bridge logic for iOS/Android Native Widgets
├── l10n/                   # ARB files for translations (en, es)
└── main.dart               # Application entry point
```

## 🌐 Localization

To add new languages or update translations, edit the `.arb` files inside the `lib/l10n/` directory.
After making changes, run the sorting script and regenerate the internationalization resources:

```bash
python3 scripts/sort_arb.py
flutter gen-l10n
```

## 📱 Screenshots

> **Tip:** Place images of your app inside `docs/images/` and update this section to showcase your UI to the world.
> 
> *Example:*
> ```markdown
> <p align="center">
>   <img src="docs/images/home.png" width="250" />
>   <img src="docs/images/couple_goal.png" width="250" />
>   <img src="docs/images/stats.png" width="250" />
> </p>
> ```

## 🤝 Contributing

Contributions are welcome! If you'd like to improve Kipera:
1. **Fork** the project.
2. Create a branch for your new feature or fix (`git checkout -b feature/NewFeature`).
3. Commit your changes (`git commit -m 'Add NewFeature'`).
4. Push to the branch (`git push origin feature/NewFeature`).
5. Open a **Pull Request**.

Please ensure you run `flutter analyze` and `flutter test` before submitting your code.

---
<div align="center">
  <p>Built with ❤️ by the Kipera team</p>
</div>
