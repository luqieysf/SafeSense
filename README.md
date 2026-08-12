# SafeSense

A Flutter + Firebase mobile app that helps parents and caregivers support children with sensory sensitivities. SafeSense keeps everyone around a child on the same page — shared routines, a running log of overstimulation events, handover notes between home and care settings, calming audio for the child, and exportable PDF reports. Three roles — **parent**, **caregiver**, and **child** — each get an interface built for them.

## About

Children who are sensitive to sensory input — sound, light, crowds, changes in routine — can become overstimulated quickly, and the adults who care for them don't always share the same picture of what's going on. A parent might not know what triggered a hard afternoon at school, and a caregiver might not know which routine or calming strategy works best at home.

SafeSense closes that gap. It gives the parent and the caregiver a single shared record for each child: the routines to follow, a log of overstimulation events as they happen, and handover notes passed between home and the care setting so nothing is lost at drop-off or pick-up. The child gets their own simple, low-pressure screen — their routine for the day, calming audio to help them self-regulate, and a way to ask for help.

The goal is consistency and calm: when everyone around a child works from the same information, the child feels safer and more in control of their environment — which is where the name comes from.

## Features

- **Role-based app** — a role picker on launch routes to a tailored experience for parents, caregivers and children.
- **Child profiles** — parents create and edit profiles for each child, linked to the adults who look after them.
- **Routines & tasks** — daily routine tasks a child can follow, created by a parent or caregiver.
- **Overstimulation / event logging** — adults record events (with notes) so patterns are visible over time; shared between the parent and the caregiver.
- **Handover notes** — quick notes passed between home and the care setting so nothing gets lost at drop-off/pick-up.
- **Calming audio** — a child-facing screen plays white noise / calming sound to help with self-regulation.
- **PDF reports** — generate and print/share a report of a child's events and activity.
- **Push notifications** — in-app notification bell + Firebase Cloud Messaging so caregivers and parents are kept informed.
- **Class groups & token linking** — caregivers manage a group of children; children are linked to adults via a secure code.

## Roles

| Role | Signs in with | Can do |
|------|---------------|--------|
| **Parent** | Email + password | Register/manage children, create routines & tasks, log and review events, read/write handover notes, view notifications, export PDF reports. |
| **Caregiver** | Email + password | See the children in their class group, create tasks, log events, read/write handover notes, view notifications. |
| **Child** | 6-digit PIN | A simplified home with their routine, calming audio, and an alert/help screen. No email or password. |

## Tech stack

- **Flutter** (Dart SDK ^3.10) — Android (and other Flutter targets)
- **Firebase** — Authentication (email/password), Cloud Firestore (data), Storage (files), Cloud Messaging (push)
- **Provider** for state management
- **sqflite** + **shared_preferences** for local storage
- **pdf** / **printing** for report export, **audioplayers** for calming audio, **image_picker** / **file_picker** for attachments

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.10.4)
- Android Studio (or the Flutter CLI) and an Android device/emulator
- A Firebase project — this repo ships a `google-services.json` / `firebase_options.dart`, so it builds against an existing Firebase backend out of the box. To point it at **your own** Firebase project, replace those with your config (e.g. via `flutterfire configure`).

## Setup

```bash
flutter pub get
flutter run          # with a device/emulator connected
```

To build a release APK:

```bash
flutter build apk --release
```

## Signing in

- **Parents and caregivers** create their own account from the app: pick the role, tap **Register**, and sign in with that email and password. Forgotten passwords can be reset by email from the login screen.
- **Children** don't use a password. When a parent or caregiver adds a child, the child gets a **6-digit PIN**; the child taps **Child** on the role picker and enters that PIN to sign in.

## Project structure

- `lib/screens/` — UI, grouped by role: `parent/`, `caregiver/`, `child/`, plus `shared/`.
- `lib/providers/` — `auth`, `child`, `task`, `event` state (Provider / ChangeNotifier).
- `lib/services/` — `auth`, `firestore`, `storage`, `audio`, `pdf` service layer.
- `lib/models/` — data models (`child_profile`, `overstimulation_event`, `routine_task`, `handover_note`, `user_account`, …).
- `lib/routes/app_routes.dart` — named routes; `lib/theme/app_theme.dart` — app theming.
