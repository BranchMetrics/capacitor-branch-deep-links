# capacitor-branch-deep-links

Capacitor plugin for [branch.io](https://branch.io/) deep links.

[![Bound State Software](https://static.boundstatesoftware.com/github-badge.png)](https://boundstatesoftware.com)

```sh
npm install capacitor-branch-deep-links
```

## Usage

```diff
+ import { Plugins } from '@capacitor/core';
+ import { BranchInitEvent } from 'capacitor-branch-deep-links';

+ const { BranchDeepLinks } = Plugins;

  @Component({
    selector: 'app-root',
    templateUrl: 'app.component.html',
    styleUrls: ['app.component.scss']
  })
  export class AppComponent {
    constructor(
      private platform: Platform,
      private splashScreen: SplashScreen,
      private statusBar: StatusBar
    ) {
      this.initializeApp();
    }

    initializeApp() {
      this.platform.ready().then(() => {
        this.statusBar.styleDefault();
        this.splashScreen.hide();
+       BranchDeepLinks.addListener('init', (event: BranchInitEvent) => {
+         // Retrieve deeplink keys from 'referringParams' and evaluate the values to determine where to route the user
+         // Check '+clicked_branch_link' before deciding whether to use your Branch routing logic
+         console.log(event.referringParams);
+       });

+       BranchDeepLinks.addListener('initError', (error: any) => {
+         console.error(error);
+       });
      });
    }
  }
```

## Android setup

Follow the Branch docs to:

1. [Configure Branch](https://docs.branch.io/apps/android/#configure-branch)

If your app is in the Google Play Store, update `build.gradle` with the necessary dependencies:

```diff
  dependencies {
+   implementation 'com.android.installreferrer:installreferrer:1.1'
+   implementation 'com.google.android.gms:play-services-appindexing:9.+' // App indexing
+   implementation 'com.google.android.gms:play-services-ads:9+' // GAID matching
  }
```

Update `src/main/res/values/strings.xml` with your configuration:

```diff
  <?xml version='1.0' encoding='utf-8'?>
  <resources>
      <string name="app_name">Ionic Starter</string>
      <string name="title_activity_main">Ionic Starter</string>
      <string name="package_name">io.ionic.starter</string>
      <string name="fileprovider_authority">io.ionic.starter.fileprovider</string>
+     <string name="custom_url_scheme">io.ionic.starter</string>
+     <string name="branch_key">key_live_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</string>
+     <string name="branch_test_key">key_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</string>
  </resources>
```

Register the plugin in your Activity:

```diff
+ import android.content.Intent;
+ import co.boundstate.BranchDeepLinks;

  public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);

      // Initializes the Bridge
      this.init(savedInstanceState, new ArrayList<Class<? extends Plugin>>() {{
        // Additional plugins you've installed go here
        // Ex: add(TotallyAwesomePlugin.class);
+       add(BranchDeepLinks.class);
      }});
    }

+   @Override
+   protected void onNewIntent(Intent intent) {
+     this.setIntent(intent);
+     super.onNewIntent(intent);
+   }
  }
```

Declare `BranchApp` as your application class in `src/main/AndroidManifest.xml`:

```diff
  <application
+     android:name="io.branch.referral.BranchApp"
```

Provide your Branch config within `<application>`:
    
```xml
<meta-data android:name="io.branch.sdk.BranchKey" android:value="@string/branch_key" />
<meta-data android:name="io.branch.sdk.BranchKey.test" android:value="@string/branch_test_key" />
<meta-data android:name="io.branch.sdk.TestMode" android:value="false" /> <!-- Set to true to use test key -->
```

Add your Branch App Links (optional) in a new `<intent-filter>` within `<activity>`:

```xml
<activity android:name="io.ionic.starter.MainActivity">
  <!-- App Link your activity to Branch links-->
  <intent-filter android:autoVerify="true">
      <action android:name="android.intent.action.VIEW" />
      <category android:name="android.intent.category.DEFAULT" />
      <category android:name="android.intent.category.BROWSABLE" />
      <data android:scheme="https" android:host="xxxx.app.link" />
      <data android:scheme="https" android:host="xxxx-alternate.app.link" />
  </intent-filter>
</activity>
```

[Test that it works!](https://docs.branch.io/apps/android/#test-deep-link)

## iOS setup

Follow the Branch docs to:

1. [Configure Branch](https://docs.branch.io/apps/ios/#configure-branch)
2. [Configure bundle identifier](https://docs.branch.io/apps/ios/#configure-bundle-identifier)
3. [Configure associated domains](https://docs.branch.io/apps/ios/#configure-associated-domains)
4. [Configure entitlements](https://docs.branch.io/apps/ios/#configure-entitlements)
5. [Configure Info.plist](https://docs.branch.io/apps/ios/#configure-infoplist)

> You can use the [Branch wizard](https://dashboard.branch.io/start/existing-users/ios) to walk you through the process  
  (skip the *Get the SDK files* and *Start a Branch session* steps)

Update the project:

```bash
npx cap update ios
```
Sync the project:

```bash
npx cap sync ios
```
Make the following changes to your `AppDelegate.swift` file:
> To consider: Read the official documentation. The import method is different depending on the swift version. Capacitor version 1.4.0 uses Swift version 4.2. 
[Check version](https://github.com/ionic-team/capacitor/blob/master/.swift-version)

```diff
+ import Branch

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
+   Branch.setUseTestBranchKey(true) // if you are using the TEST key
+   Branch.getInstance().initSession(launchOptions: launchOptions)
    return true
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    // Called when the app was launched with a url. Feel free to add additional processing here,
    // but if you want the App API to support tracking app url opens, make sure to keep this call
+   Branch.getInstance().application(app, open: url, options: options)
    return CAPBridge.handleOpenUrl(url, options)
  }

  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    // Called when the app was launched with an activity, including Universal Links.
    // Feel free to add additional processing here, but if you want the App API to support
    // tracking app url opens, make sure to keep this call
+   Branch.getInstance().continue(userActivity)
    return CAPBridge.handleContinueActivity(userActivity, restorationHandler)
  }


+ // Branch push notification handler (optional)
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
+  Branch.getInstance().handlePushNotification(userInfo)
}
```

[Test that it works!](https://docs.branch.io/apps/ios/#test-deep-link)
