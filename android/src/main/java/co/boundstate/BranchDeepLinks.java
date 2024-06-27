package co.boundstate;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.UserManager;
import android.util.Base64;
import androidx.annotation.NonNull;
import co.boundstate.capacitorbranchdeeplinks.BuildConfig;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import io.branch.indexing.BranchUniversalObject;
import io.branch.referral.Branch;
import io.branch.referral.BranchError;
import io.branch.referral.BranchShareSheetBuilder;
import io.branch.referral.BranchShortLinkBuilder;
import io.branch.referral.QRCode.BranchQRCode;
import io.branch.referral.SharingHelper;
import io.branch.referral.util.BRANCH_STANDARD_EVENT;
import io.branch.referral.util.BranchEvent;
import io.branch.referral.util.ContentMetadata;
import io.branch.referral.util.CurrencyType;
import io.branch.referral.util.LinkProperties;
import io.branch.referral.util.ShareSheetStyle;
import java.io.IOException;
import java.util.Iterator;
import java.util.Objects;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

@CapacitorPlugin(name = "BranchDeepLinks")
public class BranchDeepLinks extends Plugin {

    private static final String EVENT_INIT = "init";
    private static final String EVENT_INIT_ERROR = "initError";

    public static Branch getBranchInstance(@NonNull Context context) {
        Branch.registerPlugin("Capacitor", BuildConfig.CAPACITOR_BRANCH_VERSION);

        boolean isUnlocked = isUserUnlocked(context);

        if (isUnlocked) {
            // Branch object initialization
            return Branch.getAutoInstance(context);
        }

        return null;
    }

    private static boolean isUserUnlocked(@NonNull Context context) {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            return ((UserManager) Objects.requireNonNull(context.getSystemService(Context.USER_SERVICE))).isUserUnlocked();
        } else {
            return true;
        }
    }

    @Override
    protected void handleOnNewIntent(Intent intent) {
        super.handleOnNewIntent(intent);
        getActivity().setIntent(intent);
        Branch branch = getBranchInstance(getContext());
        if (branch != null) {
            // if activity is in foreground (or in backstack but partially visible) launching the same
            // activity will skip onStart, handle this case with sessionBuilder()...reInit()
            // will re-initialize only if ""branch_force_new_session=true"" intent extra is set
            Branch.sessionBuilder(getActivity()).withCallback(callback).reInit();
        }
    }

    @Override
    protected void handleOnStart() {
        super.handleOnStart();
        Uri data = getActivity().getIntent() != null ? getActivity().getIntent().getData() : null;
        Branch branch = getBranchInstance(getContext());
        if (branch != null) {
            Branch.sessionBuilder(getActivity()).withCallback(callback).withData(data).init();
        }
    }

    private final Branch.BranchReferralInitListener callback = new Branch.BranchReferralInitListener() {
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
    };

    private void sendError(String error) {
        JSObject data = new JSObject();
        data.put("error", error);
        notifyListeners(EVENT_INIT_ERROR, data, true);
    }

    @PluginMethod
    public void handleUrl(PluginCall call) {
        // https://help.branch.io/developers-hub/docs/android-advanced-features#section-handle-links-in-your-own-app

        String branchUrl = call.getString("branch");

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
                        call.resolve(ret);
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

        call.resolve();
    }

    @PluginMethod
    public void getStandardEvents(PluginCall call) {
        JSArray events = new JSArray();

        for (BRANCH_STANDARD_EVENT event : BRANCH_STANDARD_EVENT.values()) {
            events.put(event);
        }

        JSObject ret = new JSObject();
        ret.put("branch_standard_events", events);
        call.resolve(ret);
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
            } else if (key.equals("contentMetadata")) {
                JSONArray contentMetadata = metaData.getJSONArray("contentMetadata");

                for (int i = 0; i < contentMetadata.length(); i++) {
                    JSONObject item = contentMetadata.getJSONObject(i);

                    BranchUniversalObject universalObject = this.getContentItem(item);
                    event.addContentItems(universalObject);
                }
            }
        }

        event.logEvent(getActivity());

        call.resolve();
    }

    @PluginMethod
    public void disableTracking(PluginCall call) {
        Boolean isEnabled = call.getBoolean("isEnabled", false);
        Branch.getInstance().disableTracking(isEnabled);

        JSObject ret = new JSObject();
        ret.put("is_enabled", isEnabled);
        call.resolve(ret);
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
                            call.resolve(ret);
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
                            call.resolve(ret);
                        } else {
                            call.reject(error.getMessage());
                        }
                    }
                }
            );
    }

    @PluginMethod
    public void getBranchQRCode(final PluginCall call) throws JSONException {
        JSObject analytics = call.getObject("analytics", new JSObject());
        JSObject properties = call.getObject("properties", new JSObject());
        LinkProperties linkProperties = new LinkProperties();
        if (analytics.has("feature")) {
            linkProperties.setFeature(analytics.getString("feature"));
        }
        if (analytics.has("alias")) {
            linkProperties.setAlias(analytics.getString("alias"));
        }
        if (analytics.has("channel")) {
            linkProperties.setChannel(analytics.getString("channel"));
        }
        if (analytics.has("stage")) {
            linkProperties.setStage(analytics.getString("stage"));
        }
        if (analytics.has("campaign")) {
            linkProperties.setCampaign(analytics.getString("campaign"));
        }
        if (analytics.has("duration")) {
            linkProperties.setDuration(analytics.getInt("duration"));
        }
        if (analytics.has("tags")) {
            JSONArray array = (JSONArray) analytics.get("tags");
            for (int i = 0; i < array.length(); i++) {
                linkProperties.addTag(array.get(i).toString());
            }
        }

        Iterator<?> keys = properties.keys();
        while (keys.hasNext()) {
            String key = keys.next().toString();
            linkProperties.addControlParameter(key, properties.getString(key));
        }

        BranchUniversalObject buo = new BranchUniversalObject();

        BranchQRCode branchQRCode = new BranchQRCode();
        JSObject qrCodeSettings = call.getObject("settings", new JSObject());

        if (qrCodeSettings.has("codeColor")) {
            branchQRCode.setCodeColor(qrCodeSettings.getString("codeColor"));
        }
        if (qrCodeSettings.has("backgroundColor")) {
            branchQRCode.setBackgroundColor(qrCodeSettings.getString("backgroundColor"));
        }
        if (qrCodeSettings.has("centerLogo")) {
            branchQRCode.setCenterLogo(qrCodeSettings.getString("centerLogo"));
        }
        if (qrCodeSettings.has("width")) {
            branchQRCode.setWidth(qrCodeSettings.getInt("width"));
        }
        if (qrCodeSettings.has("margin")) {
            branchQRCode.setMargin(qrCodeSettings.getInt("margin"));
        }

        try {
            branchQRCode.getQRCodeAsData(
                getActivity(),
                buo,
                linkProperties,
                new BranchQRCode.BranchQRCodeDataHandler() {
                    @Override
                    public void onSuccess(byte[] qrCodeData) {
                        String qrCodeString = Base64.encodeToString(qrCodeData, Base64.DEFAULT);
                        JSObject ret = new JSObject();
                        ret.put("qrCode", qrCodeString);
                        call.resolve(ret);
                    }

                    @Override
                    public void onFailure(Exception e) {
                        call.reject(e.getMessage());
                    }
                }
            );
        } catch (IOException e) {
            call.reject(e.getMessage());
        }
    }

    private ShareSheetStyle getShareSheetStyle(String shareText) {
        String shareTitle = "Check this out";
        String copyToClipboard = "Copy";
        String clipboardSuccess = "Added to clipboard";
        String more = "Show More";
        String shareWith = "Share With";

        ShareSheetStyle shareSheetStyle = new ShareSheetStyle(getActivity(), shareTitle, shareText)
            .setCopyUrlStyle(getActivity().getResources().getDrawable(android.R.drawable.ic_menu_send), copyToClipboard, clipboardSuccess)
            .setMoreOptionStyle(getActivity().getResources().getDrawable(android.R.drawable.ic_menu_search), more)
            .addPreferredSharingOption(SharingHelper.SHARE_WITH.FACEBOOK)
            .addPreferredSharingOption(SharingHelper.SHARE_WITH.EMAIL)
            .addPreferredSharingOption(SharingHelper.SHARE_WITH.MESSAGE)
            .addPreferredSharingOption(SharingHelper.SHARE_WITH.TWITTER)
            .setAsFullWidthStyle(true)
            .setSharingTitle(shareWith);

        return shareSheetStyle;
    }

    private BranchUniversalObject getContentItem(JSONObject item) throws JSONException {
        BranchUniversalObject universalObject = new BranchUniversalObject();
        ContentMetadata contentMetadata = new ContentMetadata();
        Iterator<String> keys = item.keys();

        while (keys.hasNext()) {
            String key = keys.next();

            switch (key) {
                case "quantity":
                    contentMetadata.setQuantity(Double.parseDouble(item.getString(key)));
                    break;
                case "price":
                    contentMetadata.price = Double.parseDouble(item.getString(key));
                    break;
                case "currency":
                    String currencyString = item.getString(key);
                    CurrencyType currency = CurrencyType.getValue(currencyString);
                    if (currency != null) {
                        contentMetadata.currencyType = currency;
                    }
                    break;
                case "productName":
                    contentMetadata.setProductName(item.getString(key));
                    break;
                case "productBrand":
                    contentMetadata.setProductBrand(item.getString(key));
                    break;
                case "sku":
                    contentMetadata.setSku(item.getString(key));
                    break;
                default:
                    contentMetadata.addCustomMetadata(key, item.getString(key));
                    break;
            }
        }

        universalObject.setContentMetadata(contentMetadata);

        return universalObject;
    }

    private BranchShortLinkBuilder getShortLinkBuilder(JSObject analytics, JSObject properties) throws JSONException {
        BranchShortLinkBuilder shortLinkBuilder = new BranchShortLinkBuilder(getActivity());

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
        BranchShareSheetBuilder shareLinkBuilder = new BranchShareSheetBuilder(getActivity(), shortLinkBuilder);

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

    @PluginMethod
    public void getLatestReferringParams(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("referringParams", Branch.getInstance().getLatestReferringParams());
        call.resolve(ret);
    }

    @PluginMethod
    public void getFirstReferringParams(PluginCall call) {
        JSObject ret = new JSObject();
        ret.put("referringParams", Branch.getInstance().getFirstReferringParams());
        call.resolve(ret);
    }

    @PluginMethod
    public void setDMAParamsForEEA(PluginCall call) {
        Boolean eeaRegion = call.getBoolean("eeaRegion");
        Boolean adPersonalizationConsent = call.getBoolean("adPersonalizationConsent");
        Boolean adUserDataUsageConsent = call.getBoolean("adUserDataUsageConsent");

        if (eeaRegion == null || adPersonalizationConsent == null || adUserDataUsageConsent == null) {
            call.reject("Must provide valid eeaRegion, adPersonalizationConsent, and adUserDataUsageConsent");
            return;
        }

        Branch branch = Branch.getInstance();
        branch.setDMAParamsForEEA(eeaRegion, adPersonalizationConsent, adUserDataUsageConsent);

        call.resolve();
    }
}
