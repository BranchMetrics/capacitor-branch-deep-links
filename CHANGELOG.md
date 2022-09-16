Branch Capacitor SDK change log

- 5.0.1

  - Update iOS deployment target from 12 to 13 to prevent compilation error in xcode

- 5.0.0

  - Updates the core capacitor plugin to 4.0.1
  - Android minSdk bumped to 22
  - iOS platform bumped to 13
  - Android Branch SDK updated to 5.2.3 which targets 32 as well.
  - Android Branch SDK dependency type changed from `implementation` to `api` to keep references consistent and integration simpler

- 4.2.0

  - Update Android SDK to 5.2.0 https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases/tag/5.2.0
  - Update iOS SDK to 1.43.1 https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases/tag/1.43.1
  - Added getBranchQRCode() method to generate Branch QR codes.

- 4.1.1

  - Update Android SDK to 5.0.15 https://github.com/BranchMetrics/android-branch-deep-linking-attribution/releases/tag/5.0.15
  - Update iOS SDK to 1.40.2 https://github.com/BranchMetrics/ios-branch-deep-linking-attribution/releases/tag/1.40.2
  - Update Capacitor Core to 3.3.2

- 3.0.2

  - Update Android SDK to 5.0.8

- 3.0.1

  - Update Android SDK 5.0.7 and iOS SDK 1.39.2

- 3.0.0

  - Update Branch Android SDK to 5.0.3
  - Update and improve README.md
  - Integrate Branch function on Android: `handleUrl`: handle links in app (https://help.branch.io/developers-hub/docs/android-advanced-features#handle-links-in-your-own-app)

- 2.0.0
  - Integrate Branch functions: create deeplink, share deeplink, send branch event, disable tracking, set identity, logout
  - Update Android SDK 4.3.2 and iOS SDK 0.35.0
  - Update plugin to most recent capacitor structure
