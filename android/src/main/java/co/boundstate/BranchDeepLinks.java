package co.boundstate;

import android.app.Activity;
import android.content.Intent;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import io.branch.referral.Branch;
import io.branch.referral.BranchError;
import io.branch.referral.BranchShareSheetBuilder;
import io.branch.referral.BranchShortLinkBuilder;
import io.branch.referral.SharingHelper;
import io.branch.referral.util.BRANCH_STANDARD_EVENT;
import io.branch.referral.util.BranchEvent;
import io.branch.referral.util.CurrencyType;
import io.branch.referral.util.ShareSheetStyle;
import java.util.Iterator;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

@NativePlugin
public class BranchDeepLinks extends Plugin {
    private static final String EVENT_INIT = "init";
    private static final String EVENT_INIT_ERROR = "initError";

    private Activity activity;

    @PluginMethod
    public void handleUrl(PluginCall call) {
        // https://help.branch.io/developers-hub/docs/android-advanced-features#section-handle-links-in-your-own-app

        String branchUrl = call.getString("url");

        if (branchUrl != null && !branchUrl.equals("")) {
            Intent intent = new Intent(getActivity(), getActivity().getClass());

            intent.putExtra("branch", branchUrl);
            intent.putExtra("branch_force_new_session", true);

            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);

            getActivity().startActivity(intent);
        }
    }

    @PluginMethod
    public void generateShortUrl(final PluginCall call) throws JSONException {
        JSObject analytics = call.getObject("analytics", new JSObject());
        JSObject properties = call.getObject("properties", new JSObject());
        BranchShortLinkBuilder shortLinkBuilder = getShortLinkBuilder(analytics, properties);

        shortLinkBuilder.generateShortUrl(
            new Branch.BranchLinkCreateListener() {

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
            }
        );
    }

    @PluginMethod
    public void showShareSheet(PluginCall call) throws JSONException {
        JSObject analytics = call.getObject("analytics", new JSObject());
        JSObject properties = call.getObject("properties", new JSObject());
        String shareText = call.getString("shareText", "This stuff is awesome");

        ShareSheetStyle shareSheetStyle = getShareSheetStyle(shareText);
        BranchShortLinkBuilder shortLinkBuilder = getShortLinkBuilder(analytics, properties);
        BranchShareSheetBuilder shareLinkBuilder = getShareLinkBuilder(shortLinkBuilder, shareSheetStyle);
        shareLinkBuilder.shareLink();

        call.success();
    }

    @PluginMethod
    public void getStandardEvents(PluginCall call) {
        JSArray events = new JSArray();

        for (BRANCH_STANDARD_EVENT event : BRANCH_STANDARD_EVENT.values()) {
            events.put(event);
        }

        JSObject ret = new JSObject();
        ret.put("branch_standard_events", events);
        call.success(ret);
    }

    @PluginMethod
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
        } catch (IllegalArgumentException e) {
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

        event.logEvent(activity);

        call.success();
    }

    @PluginMethod
    public void disableTracking(PluginCall call) {
        this.activity = getActivity();
        Boolean isEnabled = call.getBoolean("isEnabled", false);
        Branch.getInstance().disableTracking(isEnabled);

        JSObject ret = new JSObject();
        ret.put("is_enabled", isEnabled);
        call.success(ret);
    }

    @PluginMethod
    public void setIdentity(final PluginCall call) {
        String newIdentity = call.getString("newIdentity");

        Branch
            .getInstance()
            .setIdentity(
                newIdentity,
                new Branch.BranchReferralInitListener() {

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
                }
            );
    }

    @PluginMethod
    public void logout(final PluginCall call) {
        Branch
            .getInstance()
            .logout(
                new Branch.LogoutStatusListener() {

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
                }
            );
    }

    private ShareSheetStyle getShareSheetStyle(String shareText) {
        String shareTitle = "Check this out";
        String copyToClipboard = "Copy";
        String clipboardSuccess = "Added to clipboard";
        String more = "Show More";
        String shareWith = "Share With";

        ShareSheetStyle shareSheetStyle = new ShareSheetStyle(activity, shareTitle, shareText)
            .setCopyUrlStyle(activity.getResources().getDrawable(android.R.drawable.ic_menu_send), copyToClipboard, clipboardSuccess)
            .setMoreOptionStyle(activity.getResources().getDrawable(android.R.drawable.ic_menu_search), more)
            .addPreferredSharingOption(SharingHelper.SHARE_WITH.FACEBOOK)
            .addPreferredSharingOption(SharingHelper.SHARE_WITH.EMAIL)
            .addPreferredSharingOption(SharingHelper.SHARE_WITH.MESSAGE)
            .addPreferredSharingOption(SharingHelper.SHARE_WITH.TWITTER)
            .setAsFullWidthStyle(true)
            .setSharingTitle(shareWith);

        return shareSheetStyle;
    }

    private BranchShortLinkBuilder getShortLinkBuilder(JSObject analytics, JSObject properties) throws JSONException {
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

        return shortLinkBuilder;
    }

    private BranchShareSheetBuilder getShareLinkBuilder(BranchShortLinkBuilder shortLinkBuilder, ShareSheetStyle shareSheetStyle) {
        BranchShareSheetBuilder shareLinkBuilder = new BranchShareSheetBuilder(activity, shortLinkBuilder);

        shareLinkBuilder.setSubject(shareSheetStyle.getMessageTitle()).setMessage(shareSheetStyle.getMessageBody());

        if (shareSheetStyle.getCopyUrlIcon() != null) {
            shareLinkBuilder.setCopyUrlStyle(
                shareSheetStyle.getCopyUrlIcon(),
                shareSheetStyle.getCopyURlText(),
                shareSheetStyle.getUrlCopiedMessage()
            );
        }
        if (shareSheetStyle.getMoreOptionIcon() != null) {
            shareLinkBuilder.setMoreOptionStyle(shareSheetStyle.getMoreOptionIcon(), shareSheetStyle.getMoreOptionText());
        }
        if (shareSheetStyle.getDefaultURL() != null) {
            shareLinkBuilder.setDefaultURL(shareSheetStyle.getDefaultURL());
        }
        if (shareSheetStyle.getPreferredOptions().size() > 0) {
            shareLinkBuilder.addPreferredSharingOptions(shareSheetStyle.getPreferredOptions());
        }
        if (shareSheetStyle.getStyleResourceID() > 0) {
            shareLinkBuilder.setStyleResourceID(shareSheetStyle.getStyleResourceID());
        }

        shareLinkBuilder.setDividerHeight(shareSheetStyle.getDividerHeight());
        shareLinkBuilder.setAsFullWidthStyle(shareSheetStyle.getIsFullWidthStyle());
        shareLinkBuilder.setDialogThemeResourceID(shareSheetStyle.getDialogThemeResourceID());
        shareLinkBuilder.setSharingTitle(shareSheetStyle.getSharingTitle());
        shareLinkBuilder.setSharingTitle(shareSheetStyle.getSharingTitleView());
        shareLinkBuilder.setIconSize(shareSheetStyle.getIconSize());

        if (shareSheetStyle.getIncludedInShareSheet() != null && shareSheetStyle.getIncludedInShareSheet().size() > 0) {
            shareLinkBuilder.includeInShareSheet(shareSheetStyle.getIncludedInShareSheet());
        }
        if (shareSheetStyle.getExcludedFromShareSheet() != null && shareSheetStyle.getExcludedFromShareSheet().size() > 0) {
            shareLinkBuilder.excludeFromShareSheet(shareSheetStyle.getExcludedFromShareSheet());
        }

        return shareLinkBuilder;
    }
}
