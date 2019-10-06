# capacitor-branch-deep-links

Capacitor plugin for [branch.io](https://branch.io/) deep links.

> This is a work in progress and currently only Android is supported!

```sh
npm install capacitor-branch-deep-links
```

## Usage

```typescript
import { Plugins } from '@capacitor/core';
import { Platform } from '@ionic/angular';
import { BranchInitEvent } from 'capacitor-branch-deep-links';

const { BranchDeepLinks, SplashScreen } = Plugins;

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
})
export class AppComponent {
  constructor(private platform: Platform) {
    this.initializeApp();
  }

  initializeApp() {
    this.platform.ready().then(() => {
      BranchDeepLinks.addListener('init', (event: BranchInitEvent) => {
        // Retrieve deeplink keys from 'referringParams' and evaluate the values to determine where to route the user
        // Check '+clicked_branch_link' before deciding whether to use your Branch routing logic
        console.log(event.referringParams);
      });

      BranchDeepLinks.addListener('initError', (error: any) => {
        console.error(error);
      });

      SplashScreen.hide();
    });
  }
}
```

## Android setup

Follow the Branch docs to:

1. [Configure Branch](https://docs.branch.io/apps/android/#configure-branch)

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

Add your Branch App Links (optional) in a new `<intent-filter>` within `<application>`:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="xxxx.app.link" />
    <data android:scheme="https" android:host="xxxx-alternate.app.link" />
</intent-filter>
```

[Test that it works!](https://docs.branch.io/apps/android/#test-deep-link)
