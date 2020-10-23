import Foundation
import Branch
@testable import Plugin

class BranchServiceMock: BranchService {
    override func generateShortUrl(params: [AnyHashable : Any], linkProperties: BranchLinkProperties, completion: @escaping (String?, Error?)->(Void)) -> Void {
        completion("https://example.app.link/qeFky9V118", nil)
    }
    
    override func disableTracking(isEnabled: Bool, completion: @escaping (Bool)->(Void)) -> Void {
        completion(isEnabled)
    }
    
    override func setIdentity(newIdentity: String, completion: @escaping ([AnyHashable : Any]?, Error?)->(Void)) -> Void {
        completion(["+is_first_session": false], nil)
    }
    
    override func logout(completion: @escaping (Bool?, Error?)->(Void)) -> Void {
        completion(true, nil)
    }
}
