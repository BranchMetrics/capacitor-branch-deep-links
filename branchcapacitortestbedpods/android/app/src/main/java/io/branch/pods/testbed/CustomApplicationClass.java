package io.branch.pods.testbed;

import static android.os.Build.VERSION.SDK_INT;

import android.content.Context;
import android.os.UserManager;

import androidx.multidex.MultiDex;
import androidx.multidex.MultiDexApplication;

import io.branch.referral.Branch;

public class CustomApplicationClass extends MultiDexApplication {
    @Override
         public void onCreate() {
         super.onCreate();

         // Branch logging for debugging
        Branch.enableLogging();

        if (SDK_INT >= 24) {
            UserManager um = getApplicationContext().getSystemService(UserManager.class);
            if (um == null || !um.isUserUnlocked()) return;
        }

        // Branch object initialization
        Branch.getAutoInstance(this);
         }

         @Override
         protected void attachBaseContext(Context base) {
         super.attachBaseContext(base);
         MultiDex.install(this);
         }
}
