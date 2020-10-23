import Foundation
import Branch

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
}
