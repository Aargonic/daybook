# Daybook

An all-in-one journal, habit tracker, calendar and task manager.

- **Journal**: type entries, or photograph a handwritten page and have Claude transcribe it. To-dos and dated plans found on the page can be added to Tasks and the Calendar.
- **Habits**: weekly check-offs, streaks, a month grid, and scanning of paper habit trackers.
- **Calendar**: month view with a day agenda showing events, tasks due and journal entries.
- **Tasks**: lists, due dates, an important flag, and Open / Today / Upcoming / Done filters.
- **Themes**: Paper, Night, Lagoon and Scrapbook, or match the device.

## Files

| Path | What it is |
| --- | --- |
| `daybook.html` | The app, published as a Claude artifact. It uses the artifact runtime for sync (`db`, `user`), photo storage (`assets`) and handwriting reading (`sample`), so it runs inside claude.ai. |
| `daybook-android/` | A small Android launcher (Android 8+) that opens the Daybook artifact in a Chrome Custom Tab, so it shares Chrome's claude.ai sign-in. |

## Building the Android app

Needs JDK 17 and the Android SDK (`platforms;android-34`, `build-tools;34.0.0`) under `%LOCALAPPDATA%\Android\Sdk`. No Gradle.

```powershell
powershell -ExecutionPolicy Bypass -File daybook-android\build.ps1
```

The first build creates a signing key (`daybook.jks` and `keystore.properties`). Both are git-ignored. Back them up somewhere safe: updates only install over the existing app when signed with the same key.

The APK is attached to each GitHub release.
