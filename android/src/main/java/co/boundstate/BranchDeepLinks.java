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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;

import io.branch.referral.Branch;
import io.branch.referral.BranchError;
import io.branch.referral.BranchShortLinkBuilder;
import io.branch.referral.util.BranchEvent;
import io.branch.referral.util.BRANCH_STANDARD_EVENT;
import io.branch.referral.util.CurrencyType;
import io.branch.referral.util.LinkProperties;

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
    public void generateShortUrl(final PluginCall call) throws JSONException {
        JSObject analytics = call.getObject("analytics", new JSObject());
        JSObject properties = call.getObject("properties", new JSObject());
        BranchShortLinkBuilder shortLinkBuilder = new BranchShortLinkBuilder(activity);

        // Add analytics properties
        if (analytics.has("feature")) {
            shortLinkBuilder.setFeature(analytics.getString("feature"));
        }
        if (analytics.has("alias")) {
            shortLinkBuilder.setAlias(analytics.getString("alias"));
        }
        if (analytics.has("channel")) {
            shortLinkBuilder.setChannel(analytics.getString("channel"));
        }
        if (analytics.has("stage")) {
            shortLinkBuilder.setStage(analytics.getString("stage"));
        }
        if (analytics.has("campaign")) {
            shortLinkBuilder.setCampaign(analytics.getString("campaign"));
        }
        if (analytics.has("duration")) {
            shortLinkBuilder.setDuration(analytics.getInt("duration"));
        }
        if (analytics.has("tags")) {
            JSONArray array = (JSONArray) analytics.get("tags");
            for (int i = 0; i < array.length(); i++) {
                shortLinkBuilder.addTag(array.get(i).toString());
            }
        }

        // Add and iterate control parameters properties
        Iterator<?> keys = properties.keys();

        while (keys.hasNext()) {
            String key = keys.next().toString();
            shortLinkBuilder.addParameters(key, properties.getString(key));
        }

        shortLinkBuilder.generateShortUrl(new Branch.BranchLinkCreateListener() {
            @Override
            public void onLinkCreate(String url, BranchError error) {
                if (error == null) {
                    JSObject ret = new JSObject();
                    ret.put("url", url);
                    call.success(ret);
                } else {
                    call.reject(error.getMessage());
                }
            }
        });
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
