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

### Configure Branch Dashboard

Follow the first few steps in the [Branch Documentation](https://help.branch.io/developers-hub/docs/android-basic-integration#configure-branch-dashboard) the configure your dashboard,

_Stop_ when the docs ask you to install stuff in the native code. At the moment of writing that is "Install Branch". Get along with the steps below.

### Update dependencies

Within `build.grade` change the following:

```diff
apply plugin: 'com.android.application'

android {
    defaultConfig {
        // ...
+       multiDexEnabled true
        // ...
    }
}

dependencies {
+    implementation 'com.android.support:multidex:1.0.3'

+    // Branch: required for all Android apps
+    implementation 'io.branch.sdk.android:library:5.0.3'

+    // Branch: required if your app is in the Google Play Store (tip: avoid using bundled play services libs)
+    implementation 'com.google.firebase:firebase-appindexing:19.1.0' // App indexing
+    implementation 'com.google.android.gms:play-services-ads:19.4.0' // GAID matching

+    // Branch: optional
+    implementation 'androidx.browser:browser:1.2.0' // Chrome Tab matching (enables 100% guaranteed matching based on cookies)
+    // Replace above with the line below if you do not support androidx
+    // implementation 'com.android.support:customtabs:28.0.0'
}
```

### Add variables

Update `src/main/res/values/strings.xml`:

```diff
  <?xml version='1.0' encoding='utf-8'?>
  <resources>
      <!-- ... ->
+     <string name="applink_host">example.app.link</string>
+     <string name="applink_host_alternate">example-alternate.app.link</string>
+     <string name="deeplink_scheme">example</string>
+     <string name="branch_key">key_live_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</string>
+     <string name="branch_test_key">key_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</string>
+     <string name="branch_test_mode">false</string>
+     <!-- set above to "true" to use test key -->
  </resources>
```

Optionally you can _probably_ safely delete the following:

```diff
<?xml version='1.0' encoding='utf-8'?>
<resources>
    <!-- ... _>
-   <string name="custom_url_scheme">com.example</string>
</resources>
```

### Register the plugin in your Activity

```diff
package com.example;

+ import android.content.Intent;
import android.os.Bundle;
+ import co.boundstate.BranchDeepLinks;
import com.getcapacitor.BridgeActivity;
import com.getcapacitor.Plugin;
import java.util.ArrayList;

public class MainActivity extends BridgeActivity {

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    // Initializes the Bridge
    this.init(
        savedInstanceState,
        new ArrayList<Class<? extends Plugin>>() {
          {
            // Additional plugins you've installed go here
            // Ex: add(TotallyAwesomePlugin.class);
+           add(BranchDeepLinks.class);
          }
        }
      );
  }
+
+  @Override
+  protected void onNewIntent(Intent intent) {
+    this.setIntent(intent);
+    super.onNewIntent(intent);
+  }
}
```

### Add CustomApplicationClass

Add a `CustomApplicationClass.java` to your project with the following content:

```diff
+ package com.example;
+
+ import android.content.Context;
+ import androidx.multidex.MultiDex;
+ import androidx.multidex.MultiDexApplication;
+ import io.branch.referral.Branch;
+
+ public class CustomApplicationClass extends MultiDexApplication {
+
+   @Override
+   public void onCreate() {
+     super.onCreate();
+
+     // Branch logging for debugging
+     Branch.enableLogging();
+
+     // Branch object initialization
+     Branch.getAutoInstance(this);
+   }
+
+   @Override
+   protected void attachBaseContext(Context base) {
+     super.attachBaseContext(base);
+     MultiDex.install(this);
+   }
+ }
```

### Update your AndroidManifest.xml

Update your `AndroidManifest.xml` as follows:

```diff
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example">

    <application
+       android:name=".CustomApplicationClass"
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/AppTheme">

        <!-- ... -->

+       <meta-data
+           android:name="com.google.android.gms.ads.AD_MANAGER_APP"
+           android:value="true"/>

        <activity
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|smallestScreenSize|screenLayout|uiMode"
            android:name="com.example.MainActivity"
            android:label="@string/title_activity_main"
            android:theme="@style/AppTheme.NoActionBarLaunch"
            android:launchMode="singleTask">

+           <intent-filter>
+               <action android:name="android.intent.action.MAIN" />
+               <category android:name="android.intent.category.LAUNCHER" />
+           </intent-filter>

+           <!-- BEGIN BRANCH -->
+           <intent-filter android:autoVerify="true">
+               <action android:name="android.intent.action.VIEW" />
+               <category android:name="android.intent.category.DEFAULT" />
+               <category android:name="android.intent.category.BROWSABLE" />
+               <data
+                   android:scheme="http"
+                   android:host="@string/applink_host" />
+               <data
+                   android:scheme="https"
+                   android:host="@string/applink_host" />
+               <data
+                   android:scheme="http"
+                   android:host="@string/applink_host_alternate" />
+               <data
+                   android:scheme="https"
+                   android:host="@string/applink_host_alternate" />
+           </intent-filter>
+
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
-               <data android:scheme="@string/custom_url_scheme"/>
+               <data android:scheme="@string/deeplink_scheme"/>
            </intent-filter>
+           <!-- END BRANCH -->

        </activity>

+       <!-- BEGIN BRANCH -->
+       <!-- Branch init -->
+       <meta-data android:name="io.branch.sdk.BranchKey" android:value="@string/branch_key" />
+       <meta-data android:name="io.branch.sdk.BranchKey.test" android:value="@string/branch_test_key" />
+       <meta-data android:name="io.branch.sdk.TestMode" android:value="@string/branch_test_mode" />
+       <!-- END BRANCH -->
+
        <!-- ... -->

    </application>

    <!-- ... -->

</manifest>
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
>  (skip the _Get the SDK files_ and _Start a Branch session_ steps)

Update the project:

```bash
npx cap update ios
```

Make the following changes to your `AppDelegate.swift` file:

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

+ func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
+   Branch.getInstance().handlePushNotification(userInfo)
+ }
```

[Test that it works!](https://docs.branch.io/apps/ios/#test-deep-link)
