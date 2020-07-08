package co.boundstate;

import android.content.Intent;
import android.net.Uri;
import androidx.annotation.Nullable;

import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

import org.json.JSONObject;

import io.branch.referral.Branch;
import io.branch.referral.BranchError;

@NativePlugin()
public class BranchDeepLinks extends Plugin {
    private static final String EVENT_INIT = "init";
    private static final String EVENT_INIT_ERROR = "initError";

    @Nullable
    private Uri mData;

    @Override
    protected void handleOnNewIntent(Intent intent) {
        super.handleOnNewIntent(intent);
        mData = intent.getData();
    }

    @Override
    protected void handleOnStart() {
        // Branch init
        Branch.getInstance().initSession(new Branch.BranchReferralInitListener() {
            @Override
            public void onInitFinished(JSONObject referringParams, BranchError error) {
                if (error == null) {
                    JSObject data = new JSObject();
                    data.put("referringParams", referringParams);
                    notifyListeners(EVENT_INIT, data, true);
                } else {
                    sendError(error.getMessage());
                }
            }
        }, mData, getActivity());
    }

    private void sendError(String error) {
        JSObject data = new JSObject();
        data.put("error", error);
        notifyListeners(EVENT_INIT_ERROR, data, true);
    }

    @PluginMethod()
    public void setIdentity(final PluginCall call) {
        String newIdentity = call.getString("newIdentity");

        Branch.getInstance().setIdentity(newIdentity, new Branch.BranchReferralInitListener() {
            @Override
            public void onInitFinished(JSONObject referringParams, BranchError error) {
                if (error == null) {
                    JSObject ret = new JSObject();
                    ret.put("referringParams", referringParams);
                    call.success(ret);
                } else {
                    call.reject(error.getMessage());
                }
            }
        });
    }

    @PluginMethod()
    public void logout(final PluginCall call) {
        Branch.getInstance().logout(new Branch.LogoutStatusListener() {
            @Override
            public void onLogoutFinished(boolean loggedOut, BranchError error) {
                if (error == null) {
                    JSObject ret = new JSObject();
                    ret.put("logged_out", loggedOut);
                    call.success(ret);
                } else {
                    call.reject(error.getMessage());
                }
            }
        });
    }
}
