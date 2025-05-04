# ingredients-tracker-ios

An iOS application for tracking ingredients, managing devices, groups, products, and recipes with user authentication.

## Table of Contents
- [Features](#features)
- [Stack](#stack)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Setup Instructions](#setup-instructions)
- [Configuration](#configuration)

## Features
- User registration and login with JWT-based authentication.
- Manage user profiles and roles, including admin functionalities.
- Create, update, and view groups and group members.
- Add, activate, and manage devices associated with groups.
- Manage product inventory with search and count update capabilities.
- Browse, search, view details, and cook recipes.
- Localization support (English and Ukrainian).
- Asynchronous network calls with error handling.
- Secure token storage in Keychain.

## Stack
- Swift & SwiftUI for frontend UI and app logic.
- JWTDecode library for handling JWT tokens.
- Custom networking layer built with Swift async/await.
- Property lists (`.plist`) for configuration.
- MVVM-like architecture with services managing API interactions.

## Installation

### Prerequisites
- Xcode 15 or later.
- iOS 16 or later deployment target recommended.
- Swift 5.8 or newer.
- Access to the backend API server (default URLs are configured but can be customized).

### Setup Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/Shchoholiev/ingredients-tracker-ios.git
   cd ingredients-tracker-ios
   ```

2. Open the Xcode workspace:
   ```bash
   open IngredientsTracker.xcodeproj
   ```

3. Build and run the project on a simulator or connected iOS device.

4. The app will load and prompt for login or registration on launch.

## Configuration

The app uses a `Config.plist` file located in the `IngredientsTracker` folder to set up important endpoints:

- **ApiUrl**: Base URL for the backend API (default: `https://ingredients-tracker.azurewebsites.net`)
- **ImageStorageUrl**: URL used for fetching/storing images related to recipes (default: `https://recipes.l7l2.c16.e2-2.dev`)

To customize:

1. Open `IngredientsTracker/Config.plist`.
2. Modify the `ApiUrl` and/or `ImageStorageUrl` to match your backend environment.
3. Save changes and rebuild the app.

Authentication tokens are securely stored in the Keychain. User session and roles are managed globally via the `GlobalUser` singleton. Ensure your backend issues valid JWT tokens compatible with the app claims extraction.
