import Foundation
import Capacitor
import Branch

typealias JSObject = [String:Any]

@objc(BranchDeepLinks)
public class BranchDeepLinks: CAPPlugin {
    var branchService = BranchService()

    public override func load() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(branchDidStartSession(notification:)),
                name: NSNotification.Name.BranchDidStartSession,
                object: nil
        )
        
        Branch.getInstance().registerPluginName("Capacitor", version: "4.1.1")
    }

    @objc public func setBranchService(branchService: Any) {
        self.branchService = branchService as! BranchService
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
        let linkProperties = getLinkProperties(analytics: analytics, properties: properties)
        let params = NSMutableDictionary();
        params.addEntries(from: linkProperties.controlParams)

        branchService.generateShortUrl(params: params as? [AnyHashable : Any] ?? [:], linkProperties: linkProperties) { (url, error) in
            if (error == nil) {
                call.resolve([
                    "url": url ?? ""
                ])
            } else {
                call.reject(error?.localizedDescription ?? "Error generating short url")
            }
        }
    }

    @objc func showShareSheet(_ call: CAPPluginCall) {
        let analytics = call.getObject("analytics") ?? [:]
        let properties = call.getObject("properties") ?? [:]
        let shareText = call.getString("shareText", "Share Link")
        let linkProperties = getLinkProperties(analytics: analytics, properties: properties)

        let params = NSMutableDictionary();
        params.addEntries(from: linkProperties.controlParams)

        let buo = BranchUniversalObject.init()
        DispatchQueue.main.async {
            buo.showShareSheet(with: linkProperties, andShareText: shareText, from: self.bridge?.viewController, completion: nil)
        }

        call.success()
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
            BranchStandardEvent.unlockAchievement,
            BranchStandardEvent.viewCart,
            BranchStandardEvent.viewItem,
            BranchStandardEvent.viewItems,
        ]

        call.resolve([
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
            } else if key == "contentMetadata" {
                if let items = value as? NSMutableArray {
                    var contentItems: [BranchUniversalObject] = []
                    
                    items.forEach { (item) in
                        let item = item as? [String:Any] ?? [:]
                        contentItems.append(getContentItemObject(item: item))
                    }
                    event.contentItems = contentItems
                }
            }
        }

        event.logEvent()
        call.success()
    }

    @objc func disableTracking(_ call: CAPPluginCall) {
        let isEnabled = call.getBool("isEnabled") ?? false
        branchService.disableTracking(isEnabled: isEnabled) { (enabled) in
            call.resolve([
                "is_enabled": enabled
            ])
        }
    }

    @objc func setIdentity(_ call: CAPPluginCall) {
        let newIdentity = call.getString("newIdentity") ?? ""
        branchService.setIdentity(newIdentity: newIdentity) { (referringParams, error) in
            call.resolve([
                "referringParams": referringParams ?? [:]
            ])
        }
    }

    @objc func logout(_ call: CAPPluginCall) {
        branchService.logout() {(loggedOut, error) in
            if (error == nil) {
                call.resolve([
                    "logged_out": loggedOut as Any
                ])
            } else {
                call.reject(error?.localizedDescription ?? "Error logging out")
            }
        }
    }

    func getLinkProperties(analytics: [String: Any], properties: [String: Any]) -> BranchLinkProperties {
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

        return linkProperties
    }
    
    func getContentItemObject(item: [String:Any]) -> BranchUniversalObject {
        let object = BranchUniversalObject.init()

        for (key, value) in item {
            
            switch key {
            case "productName":
                object.contentMetadata.productName = value as? String
            case "productBrand":
                object.contentMetadata.productBrand = value as? String
            case "sku":
                object.contentMetadata.sku = value as? String
            case "price":
                object.contentMetadata.price = NSDecimalNumber(decimal: (value as? NSNumber ?? 0).decimalValue)
            case "currency":
                object.contentMetadata.currency = (value as? String).map { BNCCurrency(rawValue: $0) }
            case "quantity":
                object.contentMetadata.quantity = Double.init(truncating: value as? NSNumber ?? 0)
            default:
                object.contentMetadata.customMetadata[key] = value
            }
        }
        
        return object
    }

    @objc func getBranchQRCode(_ call: CAPPluginCall) {
        let analytics = call.getObject("analytics") ?? [:]
        let properties = call.getObject("properties") ?? [:]
        let linkProperties = getLinkProperties(analytics: analytics, properties: properties)

        let buo = BranchUniversalObject.init()
        
        let qrCodeSettingsMap = call.getObject("settings") ?? [:]
        let qrCode = BranchQRCode()
        
        if let codeColor = qrCodeSettingsMap["codeColor"] as? String {
            qrCode.codeColor = colorWithHexString(hexString: codeColor)
        }
        if let backgroundColor = qrCodeSettingsMap["backgroundColor"] as? String {
            qrCode.backgroundColor = colorWithHexString(hexString: backgroundColor)
        }
        if let centerLogo = qrCodeSettingsMap["centerLogo"] as? String{
            qrCode.centerLogo = centerLogo
        }
        if let margin = qrCodeSettingsMap["margin"] as? NSNumber {
            qrCode.margin = margin
        }
        if let width = qrCodeSettingsMap["width"] as? NSNumber {
            qrCode.width = width
        }
        if let imageFormat = qrCodeSettingsMap["imageFormat"] as? String {
            if imageFormat == "JPEG" {
                qrCode.imageFormat = .JPEG
            } else if imageFormat == "PNG" {
                qrCode.imageFormat = .PNG
            }
        }
        
        branchService.getBranchQRCode(branchQRCode: qrCode, buo: buo, linkProperties: linkProperties) { qrCodeString, error in
            if (error == nil) {
                call.resolve([
                    "qrCode": qrCodeString ?? ""
                ])
            } else {
                call.reject(error?.localizedDescription ?? "Error generating QR code")
            }
        }
    }
    
    func colorWithHexString(hexString: String, alpha:CGFloat = 1.0) -> UIColor {
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        let scanner: Scanner = Scanner(string: hexStr)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        hexInt = UInt32(bitPattern: scanner.scanInt32(representation: .hexadecimal) ?? 0)
        return hexInt
    }
}
