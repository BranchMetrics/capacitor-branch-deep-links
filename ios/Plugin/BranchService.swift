import Foundation
import BranchSDK

class BranchService {
    func generateShortUrl(params: [AnyHashable : Any], linkProperties: BranchLinkProperties, completion: @escaping (String?, Error?)->(Void)) -> Void {
        Branch.getInstance().getShortUrl(withParams: params, andTags: linkProperties.tags, andAlias: linkProperties.alias, andMatchDuration: linkProperties.matchDuration, andChannel: linkProperties.channel, andFeature: linkProperties.feature, andStage: linkProperties.stage, andCampaign: linkProperties.campaign) { (url, error) in
            if (error == nil) {
                completion(url, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func disableTracking(isEnabled: Bool, completion: @escaping (Bool)->(Void)) -> Void {
        Branch.setTrackingDisabled(isEnabled)
        completion(isEnabled)
    }
    
    func setIdentity(newIdentity: String, completion: @escaping ([AnyHashable : Any]?, Error?)->(Void)) -> Void {
        Branch.getInstance().setIdentity(newIdentity) { (referringParams, error) in
            if (error == nil) {
                completion(referringParams, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func logout(completion: @escaping (Bool?, Error?)->(Void)) -> Void {
        Branch.getInstance().logout { (loggedOut, error) in
            if (error == nil) {
                completion(loggedOut, nil)
            } else {
                completion(nil, error)
            }
        }
    }

    func getBranchQRCode(branchQRCode: BranchQRCode, buo: BranchUniversalObject, linkProperties: BranchLinkProperties, completion: @escaping (String?, Error?)->(Void)) -> Void {
        branchQRCode.getAsData(buo, linkProperties: linkProperties) { qrCodeData, error in
            if let error = error {
                completion(nil, error)
            } else if let qrCodeData = qrCodeData {
                let qrCodeString = qrCodeData.base64EncodedString()
                completion(qrCodeString, nil)
            }
        }
    }

   func getLatestReferringParams(completion: @escaping ([AnyHashable: Any])->(Void)) -> Void {
        let params = Branch.getInstance().getLatestReferringParams() ?? [:]
        completion(params)
    }

    func getFirstReferringParams(completion: @escaping ([AnyHashable : Any])->(Void)) -> Void {
        let params = Branch.getInstance().getFirstReferringParams() ?? [:]
        completion(params)
    }

    func setDMAParamsForEEA(eeaRegion: Bool, adPersonalizationConsent: Bool, adUserDataUsageConsent: Bool) -> Void {
        Branch.setDMAParamsForEEA(eeaRegion, adPersonalizationConsent: adPersonalizationConsent, adUserDataUsageConsent: adUserDataUsageConsent)
    }
    
    func handleUrl(url: String, completion: @escaping (Error?) -> Void) {
        if let deepLinkUrl = URL(string: url) {
            Branch.getInstance().handleDeepLink(deepLinkUrl)
            completion(nil)
        } else {
            completion(NSError(domain: "Invalid URL", code: 400, userInfo: nil))
        }
    }
}
