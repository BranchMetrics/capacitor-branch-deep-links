import XCTest
import Capacitor
import Branch
@testable import Plugin

class PluginTests: XCTestCase {
    var plugin = BranchDeepLinks()
    var branchServiceMock = BranchServiceMock()

    override func setUp() {
        super.setUp()
        plugin = BranchDeepLinks()
        branchServiceMock = BranchServiceMock()
        plugin.setBranchService(branchService: branchServiceMock)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetStandardEvents() {
        let call = CAPPluginCall(callbackId: "getStandardEvents", success: { (result, _) in
            let resultValue = result!.data["branch_standard_events"] as? [Any]
            let containsEvents = resultValue!.contains { element in
                if (element as? BranchStandardEvent) != nil {
                    return true
                } else {
                    return false
                }
            }
            XCTAssertTrue(containsEvents)
        }, error: { (_) in
            XCTFail("Error shouldn't have been called")
        })

        plugin.getStandardEvents(call!)
    }

    func testGenerateShortUrl() {
        let analytics = NSDictionary()
        let properties = NSDictionary()

        let call = CAPPluginCall(callbackId: "generateShortUrl", options: [
            "analytics": analytics,
            "properties": properties
        ], success: { (result, _) in
            let resultValue = result!.data["url"] as? String
            XCTAssertEqual(resultValue, "https://example.app.link/qeFky9V118")
        }, error: { (_) in
            XCTFail("Error shouldn't have been called")
        })

        plugin.generateShortUrl(call!)
    }

    func testDisableTracking() {
        let isEnabled = true

        let call = CAPPluginCall(callbackId: "disableTracking", options: [
            "isEnabled": isEnabled
        ], success: { (result, _) in
            let resultValue = result!.data["is_enabled"] as? Bool
            XCTAssertEqual(resultValue, true)
        }, error: { (_) in
            XCTFail("Error shouldn't have been called")
        })

        plugin.disableTracking(call!)
    }

    func testSetIdentity() {
        let newIdentity = "123abc"

        let call = CAPPluginCall(callbackId: "setIdentity", options: [
            "newIdentity": newIdentity
        ], success: { (result, _) in
            let resultValue = result!.data["referringParams"] as? [AnyHashable : Any]
            XCTAssertEqual(resultValue!["+is_first_session"] as? Bool, false)
        }, error: { (_) in
            XCTFail("Error shouldn't have been called")
        })

        plugin.setIdentity(call!)
    }

    func testLogout() {
        let call = CAPPluginCall(callbackId: "logout", success: { (result, _) in
            let resultValue = result!.data["logged_out"] as? Bool
            XCTAssertEqual(resultValue, true)
        }, error: { (_) in
            XCTFail("Error shouldn't have been called")
        })

        plugin.logout(call!)
    }

    func testHandleSceneOpenURL() {
        let url = URL(string: "myapp://open?link_click_id=123")!
        let notification = Notification(name: .branchCapacitorSceneOpenURL, object: nil, userInfo: [
            "url": url,
            "options": [:]
        ])

        plugin.handleSceneOpenURL(notification: notification)

        XCTAssertEqual(branchServiceMock.openedURLs, [url])
        XCTAssertTrue(branchServiceMock.universalLinks.isEmpty)
    }

    func testHandleSceneOpenUniversalLink() {
        let url = URL(string: "https://example.app.link/qeFky9V118")!
        let notification = Notification(name: .branchCapacitorSceneOpenUniversalLink, object: nil, userInfo: [
            "url": url
        ])

        plugin.handleSceneOpenUniversalLink(notification: notification)

        XCTAssertEqual(branchServiceMock.universalLinks, [url])
        XCTAssertTrue(branchServiceMock.openedURLs.isEmpty)
    }

    func testHandleSceneNotificationsWithoutURL() {
        plugin.handleSceneOpenURL(notification: Notification(name: .branchCapacitorSceneOpenURL, object: nil, userInfo: nil))
        plugin.handleSceneOpenUniversalLink(notification: Notification(name: .branchCapacitorSceneOpenUniversalLink, object: nil, userInfo: ["url": "not a URL"]))

        XCTAssertTrue(branchServiceMock.openedURLs.isEmpty)
        XCTAssertTrue(branchServiceMock.universalLinks.isEmpty)
    }
}
