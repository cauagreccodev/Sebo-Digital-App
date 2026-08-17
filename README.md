# Sebo Digital App

[Versão em Português](README_PT.md)

Flutter/Dart mobile application for Sebo Digital.

## API and Database

The mobile app uses the same API as the web version:

```text
https://sebo-digital-site.onrender.com
```

The database already exists and continues to be accessed through the Spring Boot backend.
The app does not create a database, perform seeding, or connect directly to PostgreSQL.

To change the API during development:

```powershell
flutter run -t lib/main.dart --dart-define=SEBO_API_URL=http://localhost:8080
```

## Running

```powershell
flutter pub get
flutter run -t lib/main.dart
```

In VS Code, use the **Sebo Digital App** launch configuration. It always points to
`lib/main.dart`, even when `test/widget_test.dart` is open.

## Demo Account

```text
Email: guest@exemplo.com
Password: guest123
```

## Features

### v0.4

- Default URL and production builds migrated to the backend hosted on Render (`https://sebo-digital-site.onrender.com`)
- Updated the Release APK workflow to build and connect to the new API

### v0.3

- GitHub Action release workflow that builds APKs on `v*` tags
- Automatic publication of the APK as an asset in the GitHub Release
- APK artifact also available in the workflow run

### v0.2

- Dark theme with preference persisted on the device
- Contrast adjustments for chips, cards, badges, and panels
- Horizontal carousels with touch/mouse drag support and navigation buttons

### v0.1

- Catalog connected to the existing API
- Search, categories, filters, and sorting
- Book details and offers
- Locally persisted cart
- Login, registration, and demo account
- Demo checkout sending orders to `/api/pedidos`
- Purchase history and order tracking

## Version

Current version:

```text
0.4.0+4
```

Current Git tag:

```text
v0.4
```
