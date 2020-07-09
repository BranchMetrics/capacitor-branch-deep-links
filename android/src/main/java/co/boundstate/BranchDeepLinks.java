package co.boundstate;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import androidx.annotation.Nullable;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Arrays;
import java.util.Iterator;

import io.branch.referral.Branch;
import io.branch.referral.BranchError;
import io.branch.referral.util.BranchEvent;
import io.branch.referral.util.BRANCH_STANDARD_EVENT;
import io.branch.referral.util.CurrencyType;

@NativePlugin()
public class BranchDeepLinks extends Plugin {
    private static final String EVENT_INIT = "init";
    private static final String EVENT_INIT_ERROR = "initError";

    @Nullable
    private Uri mData;

    private Activity activity;

    @Override
    protected void handleOnNewIntent(Intent intent) {
        super.handleOnNewIntent(intent);
        mData = intent.getData();
    }

    @Override
    protected void handleOnStart() {
        this.activity = getActivity();
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
        }, mData, activity);
    }

    private void sendError(String error) {
        JSObject data = new JSObject();
        data.put("error", error);
        notifyListeners(EVENT_INIT_ERROR, data, true);
    }

    @PluginMethod()
    public void getStandardEvents(PluginCall call) {
        JSArray events = new JSArray();

        for (BRANCH_STANDARD_EVENT event : BRANCH_STANDARD_EVENT.values()) {
            events.put(event);
        }

        JSObject ret = new JSObject();
        ret.put("branch_standard_events", events);
        call.success(ret);
    }

    @PluginMethod()
    public void sendBranchEvent(PluginCall call) throws JSONException {
        if (!call.getData().has("eventName")) {
            call.reject("Must provide an event name");
            return;
        }

        String eventName = call.getString("eventName");
        JSObject metaData = call.getObject("metaData", new JSObject());
        BranchEvent event;

        try {
            BRANCH_STANDARD_EVENT standardEvent = BRANCH_STANDARD_EVENT.valueOf(eventName);
            event = new BranchEvent(standardEvent);
        } catch(IllegalArgumentException e) {
            event = new BranchEvent(eventName);
        }

        Iterator<String> keys = metaData.keys();
        while (keys.hasNext()) {
            String key = keys.next();
            if (key.equals("revenue")) {
                event.setRevenue(Double.parseDouble(metaData.getString("revenue")));
            } else if (key.equals("currency")) {
                String currencyString = metaData.getString("currency");
                CurrencyType currency = CurrencyType.getValue(currencyString);
                if (currency != null) {
                    event.setCurrency(currency);
                }
            } else if (key.equals("transactionID")) {
                event.setTransactionID(metaData.getString("transactionID"));
            } else if (key.equals("coupon")) {
                event.setCoupon(metaData.getString("coupon"));
            } else if (key.equals("shipping")) {
                event.setShipping(Double.parseDouble(metaData.getString("shipping")));
            } else if (key.equals("tax")) {
                event.setTax(Double.parseDouble(metaData.getString("tax")));
            } else if (key.equals("affiliation")) {
                event.setAffiliation(metaData.getString("affiliation"));
            } else if (key.equals("description")) {
                event.setDescription(metaData.getString("description"));
            } else if (key.equals("searchQuery")) {
                event.setSearchQuery(metaData.getString("searchQuery"));
            } else if (key.equals("customerEventAlias")) {
                event.setCustomerEventAlias(metaData.getString("customerEventAlias"));
            } else if (key.equals("customData")) {
                JSONObject customData = metaData.getJSObject("customData");
                keys = customData.keys();

                while (keys.hasNext()) {
                    String keyValue = (String) keys.next();
                    event.addCustomDataProperty(keyValue, customData.getString(keyValue));
                }
            }
        }

        event.logEvent(this.activity);

        call.success();
    }

    @PluginMethod()
    public void disableTracking(PluginCall call) {
        this.activity = getActivity();
        Boolean isEnabled = call.getBoolean("isEnabled", false);
        Branch.getInstance().disableTracking(isEnabled);

        JSObject ret = new JSObject();
        ret.put("is_enabled", isEnabled);
        call.success(ret);
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
