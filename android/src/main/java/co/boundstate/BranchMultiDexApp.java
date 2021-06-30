package co.boundstate;

import static co.boundstate.BranchDeepLinks.getBranchInstance;

import androidx.multidex.MultiDexApplication;

public class BranchMultiDexApp extends MultiDexApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        getBranchInstance(this);
    }
}
