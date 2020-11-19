package io.ionic.starter;

import android.content.Intent;
import android.os.Bundle;
import co.boundstate.BranchDeepLinks;
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
                        add(BranchDeepLinks.class);
                    }
                }
            );
    }

    @Override
    protected void onNewIntent(Intent intent) {
        this.setIntent(intent);
        super.onNewIntent(intent);
    }
}
