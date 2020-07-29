import Foundation
import Capacitor
import Branch

typealias JSObject = [String:Any]

@objc(BranchDeepLinks)
public class BranchDeepLinks: CAPPlugin {
    public override func load() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(branchDidStartSession(notification:)),
                name: NSNotification.Name.BranchDidStartSession,
                object: nil
        )
    }

    @objc public func branchDidStartSession(notification: Notification) {
        if let error = notification.userInfo?[BranchErrorKey] as? Error {
            notifyListeners("initError", data:[
                "error": error.localizedDescription
            ], retainUntilConsumed: true)
        } else {
            let linkprops = notification.userInfo?[BranchLinkPropertiesKey] as? BranchLinkProperties
            let universalobject = notification.userInfo?[BranchUniversalObjectKey] as? BranchUniversalObject

            var referringParams = JSObject()

            for (key, value) in linkprops?.controlParams ?? [:] {
                referringParams[key.base as! String] = value
            }

            for (key, value) in universalobject?.contentMetadata.customMetadata ?? [:] {
                referringParams[key as! String] = value
            }

            notifyListeners("init", data:[
                "referringParams": referringParams
            ], retainUntilConsumed: true)
        }
    }

    @objc func generateShortUrl(_ call: CAPPluginCall) {
        let analytics = call.getObject("analytics") ?? [:]
        let properties = call.getObject("properties") ?? [:]
        let linkProperties = BranchLinkProperties.init()
        
        for (key, value) in analytics {
            if key == "alias" {
                linkProperties.alias = value as? String
            } else if key == "campaign" {
                linkProperties.campaign = value as? String
            } else if key == "channel" {
                linkProperties.channel = value as? String
            } else if key == "duration" {
                linkProperties.matchDuration = value as? UInt ?? 0
            } else if key == "feature" {
                linkProperties.feature = value as? String
            } else if key == "stage" {
                linkProperties.stage = value as? String
            } else if key == "tags" {
                linkProperties.tags = value as? [Any]
            }
        }
        
        for (key, value) in properties {
            linkProperties.addControlParam(key, withValue: value as? String)
        }
        
        let params = NSMutableDictionary();
        params.addEntries(from: linkProperties.controlParams)
        
        Branch.getInstance().getShortUrl(withParams: params as? [AnyHashable : Any], andTags: linkProperties.tags, andAlias: linkProperties.alias, andMatchDuration: linkProperties.matchDuration, andChannel: linkProperties.channel, andFeature: linkProperties.feature, andStage: linkProperties.stage, andCampaign: linkProperties.campaign) { (url, error) in
            if (error == nil) {
                call.success([
                    "url": url ?? ""
                ])
            } else {
                call.reject(error?.localizedDescription ?? "Error generating short url")
            }
        }
    }

    @objc func getStandardEvents(_ call: CAPPluginCall) {
        let standardEvents: [BranchStandardEvent] = [
            BranchStandardEvent.achieveLevel,
            BranchStandardEvent.addPaymentInfo,
            BranchStandardEvent.addToCart,
            BranchStandardEvent.addToWishlist,
            BranchStandardEvent.completeRegistration,
            BranchStandardEvent.completeTutorial,
            BranchStandardEvent.initiatePurchase,
            BranchStandardEvent.purchase,
            BranchStandardEvent.rate,
            BranchStandardEvent.search,
            BranchStandardEvent.share,
            BranchStandardEvent.spendCredits,
            BranchStandardEvent.unlockAchievement,
            BranchStandardEvent.viewCart,
            BranchStandardEvent.viewItem,
            BranchStandardEvent.viewItems,
        ]

        call.success([
            "branch_standard_events": standardEvents
        ])
    }

    @objc func sendBranchEvent(_ call: CAPPluginCall) {
        guard let eventName = call.options["eventName"] as? String else {
          call.reject("Must provide an event name")
          return
        }
        let metaData = call.getObject("metaData") ?? [:]
        let event = BranchEvent.customEvent(withName: eventName)
        
        for (key, value) in metaData {
            if key == "transactionID" {
                event.transactionID = value as? String
            } else if key == "currency" {
                event.currency = (value as? String).map { BNCCurrency(rawValue: $0) }
            } else if key == "shipping" {
                event.shipping = NSDecimalNumber(decimal: (value as? NSNumber ?? 0).decimalValue)
            } else if key == "tax" {
                event.tax = NSDecimalNumber(decimal: (value as? NSNumber ?? 0).decimalValue)
            } else if key == "coupon" {
                event.coupon = value as? String
            } else if key == "affiliation" {
                event.affiliation = value as? String
            } else if key == "eventDescription" {
                event.eventDescription = value as? String
            } else if key == "revenue" {
                event.revenue = NSDecimalNumber(decimal: (value as? NSNumber ?? 0).decimalValue)
            } else if key == "searchQuery" {
                event.searchQuery = value as? String
            } else if key == "description" {
                event.eventDescription = value as? String
            } else if key == "customerEventAlias" {
                event.alias = value as? String
            } else if key == "customData" {
                event.customData = value as? [String : String] ?? [:]
            }
        }
        
        event.logEvent()

        call.success()
    }

    @objc func disableTracking(_ call: CAPPluginCall) {
        let isEnabled = call.getBool("isEnabled") ?? false
        Branch.setTrackingDisabled(isEnabled)
        call.success([
            "is_enabled": isEnabled
        ])
    }

    @objc func setIdentity(_ call: CAPPluginCall) {
        let newIdentity = call.getString("newIdentity")
        Branch.getInstance().setIdentity(newIdentity) { (referringParams, error) in
            if (error == nil) {
                call.success([
                    "referringParams": referringParams ?? [:]
                ])
            } else {
                call.reject(error?.localizedDescription ?? "Error setting identity")
            }
        }
    }

    @objc func logout(_ call: CAPPluginCall) {
        Branch.getInstance().logout { (loggedOut, error) in
            if (error == nil) {
                call.success([
                    "logged_out": loggedOut
                ])
            } else {
                call.reject(error?.localizedDescription ?? "Error logging out")
            }
        }
    }
}
