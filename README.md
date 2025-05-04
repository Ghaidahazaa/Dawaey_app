# Dawaey App – Vision & Development Stages

## Vision
To create a smart, personalized medication reminder app that enhances treatment adherence for patients by using interactive notifications, logging behavior, and enabling future integration with doctors and health data systems.

## Stage 1: Core Functionality (Completed)
- Add new medications with detailed information:
  - Name
  - Dosage
  - Doses per day
  - Frequency (daily, weekly, monthly)
  - First dose time
  - Duration or permanent use
- Schedule notifications using `flutter_local_notifications` and `timezone`.
- Send local reminders with interactive actions ("Taken" / "Skipped").
- Log each medication intake with status and actual timestamp.
- Display today's scheduled doses.
- Save all logs in SQLite.

## Stage 2: UI/UX Enhancement (Next Phase)
- Apply clean UI theme using navy blue and white.
- Improve layout and navigation.
- Add visual illustrations/icons for medications and notifications.
- Ensure accessibility and ease of use for all age groups.

## Stage 3: Smart Features (In Planning)
- Automatically calculate intervals between doses.
- Use AI to provide dietary suggestions for each medication (e.g., avoid dairy with certain vitamins).
- Show personalized reminders based on time of day.

## Stage 4: Doctor Integration (Future Vision)
- Build a doctor-side portal/app to input prescriptions directly.
- Link prescriptions to patient accounts automatically.
- Create a supervision dashboard for nurses to track medication adherence in real-time.
- Alert medical staff when a patient misses a critical dose.

## Stage 5: Cloud Sync & Analytics
- Add Firebase or similar backend for data sync and login.
- Enable login and backup for users.
- Visualize medication adherence history with charts.
- Export reports for medical review.

---



**Maintainer:** Ghaidah Alhazzaa
