package io.branch.pods.testbed;

import android.content.Intent;
import android.os.Bundle;

import com.getcapacitor.BridgeActivity;

import co.boundstate.BranchDeepLinks;
import io.branch.referral.Branch;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
         Branch.getInstance().setRequestMetadata("insert_user_id", "value"); // if you need to append partner metadata before initializing Branch
         registerPlugin(BranchDeepLinks.class);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        this.setIntent(intent);
        super.onNewIntent(intent);
    }
}
