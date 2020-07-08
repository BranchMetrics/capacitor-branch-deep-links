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

    @objc func setIdentity(_ call: CAPPluginCall) {
        let newIdentity = call.getString("newIdentity")
        Branch.getInstance().setIdentity(newIdentity) { (referringParams, error) in
            if (error == nil) {
                call.success([
                    "referringParams": referringParams as Any
                ])
            } else {
                call.reject(error?.localizedDescription ?? "Error setting identity")
            }
        }
    }
}
