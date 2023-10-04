#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(BranchDeepLinks, "BranchDeepLinks",
           CAP_PLUGIN_METHOD(generateShortUrl, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(showShareSheet, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getStandardEvents, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(sendBranchEvent, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(handleATTAuthorizationStatus, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(disableTracking, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setIdentity, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(logout, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getBranchQRCode, CAPPluginReturnPromise);
)
