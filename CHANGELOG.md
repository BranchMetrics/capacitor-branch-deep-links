Branch Capacitor SDK change log

- 9.0.0

  - Update Capacitor to 7. Thanks @hamadsuniverse
    - Minimum iOS deployment 14
    - Minimum Android SDK 23
  - Branch Android SDK bumped to 5.18.1
  - Branch iOS SDK bumped to 3.12.1

- 8.4.0

  - Exposed new method `setConsumerProtectionAttributionLevel` to set CPP level
  - Branch Android SDK bumped to 5.15.1
  - Branch iOS SDK bumped to 3.9.0
  - Updated @capacitor/ios to 6.2.0

- 8.3.0

  - Branch Android SDK bumped to 5.13.0
  - Branch iOS SDK bumped to 3.6.5

- 8.2.1

  - Branch Android SDK bumped to 5.12.4

- 8.2.0

  - Branch Android SDK bumped to 5.12.3
  - Branch iOS SDK bumped to 3.6.3

- 8.1.0

  - Added the handleUrl method to iOS and updated BranchUrlParams to include `branch` instead of `url`.

- 8.0.0

  - Updated the `addListener` method to return a `Promise<PluginListenerHandle>`.
  - Updates the core capacitor plugin to 6.0.0
  - Branch Android SDK bumped to 5.12.0
  - Branch iOS SDK bumped to 3.4.3

- 7.1.0

  - Added new method, setDMAParamsForEEA(), for setting DMA compliance parameters.
  - Branch Android SDK bumped to 5.9.0
  - Branch iOS SDK bumped to 3.2.0

- 7.0.0

  - Branch Android SDK bumped to 5.7.5
  - Branch iOS SDK bumped to 3.0.1
  - Added new methods, getLatestReferringParams() and getFirstReferringParams()

- 6.0.0

  - Updates the core capacitor plugin to 5.0.0 https://github.com/BranchMetrics/capacitor-branch-deep-links/pull/112
  - Branch Android SDK bumped to 5.6.1 https://github.com/BranchMetrics/capacitor-branch-deep-links/pull/113
    - Updated to Gradle 8 and resolved tooling errors
  - Branch iOS SDK bumped to 2.2.0 https://github.com/BranchMetrics/capacitor-branch-deep-links/pull/113
    - Namespace `Branch` changed to `BranchSDK`

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
