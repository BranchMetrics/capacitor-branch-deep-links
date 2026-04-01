import Foundation
import Capacitor
import BranchSDK

@objc public class BranchConfigHelper: NSObject {

    /// Call this from AppDelegate BEFORE Branch.getInstance().initSession()
    /// Reads capacitor.config.json and applies pre-initialization settings
    @objc public static func applyConfigBeforeInit() {
        guard let configPath = Bundle.main.path(forResource: "capacitor.config", ofType: "json"),
              let configData = try? Data(contentsOf: URL(fileURLWithPath: configPath)),
              let configJson = try? JSONSerialization.jsonObject(with: configData) as? [String: Any],
              let plugins = configJson["plugins"] as? [String: Any],
              let branchConfig = plugins["BranchDeepLinks"] as? [String: Any],
              let iosConfig = branchConfig["ios"] as? [String: Any] else {
            // No config found, return silently
            return
        }

        // Apply sdkWaitTime
        if let sdkWaitTime = iosConfig["sdkWaitTime"] as? Double {
            Branch.setSDKWaitTimeForThirdPartyAPIs(sdkWaitTime)
            print("✅ Branch: Set SDK wait time to \(sdkWaitTime) from capacitor.config.json")
        }

        // Apply anonID
        if let anonID = iosConfig["anonID"] as? String {
            Branch.setAnonID(anonID)
            print("✅ Branch: Set anon ID to \(anonID) from capacitor.config.json")
        }

        // Apply odmInfo
        if let odmInfo = iosConfig["odmInfo"] as? [String: Any],
           let odmValue = odmInfo["value"] as? String,
           let timestamp = odmInfo["firstOpenTimestamp"] as? Double {
            let firstOpenDate = Date(timeIntervalSince1970: timestamp)
            Branch.setODMInfo(odmValue, andFirstOpenTimestamp: firstOpenDate)
            print("✅ Branch: Set ODM info from capacitor.config.json")
        }

        // FUTURE EXPANSION POINT:
        // Add new pre-init configuration here following the same pattern
        // Example:
        // if let someNewSetting = iosConfig["someNewSetting"] as? String {
        //     Branch.someNewMethod(someNewSetting)
        //     print("✅ Branch: Set someNewSetting from capacitor.config.json")
        // }
    }
}
