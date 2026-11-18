import XCTest
import Capacitor
import BranchSDK
@testable import BranchDeepLinksPlugin

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
        let call = CAPPluginCall(callbackId: "getStandardEvents", methodName: "getStandardEvents", options: [:], success: { (result, _) in
            let resultValue = result!.data?["branch_standard_events"] as? [Any]
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

        let call = CAPPluginCall(callbackId: "generateShortUrl", methodName: "generateShortUrl", options: [
            "analytics": analytics,
            "properties": properties
        ], success: { (result, _) in
            let resultValue = result!.data?["url"] as? String
            XCTAssertEqual(resultValue, "https://example.app.link/qeFky9V118")
        }, error: { (_) in
            XCTFail("Error shouldn't have been called")
        })

        plugin.generateShortUrl(call!)
    }

    func testDisableTracking() {
        let isEnabled = true

        let call = CAPPluginCall(callbackId: "disableTracking", methodName: "disableTracking", options: [
            "isEnabled": isEnabled
        ], success: { (result, _) in
            let resultValue = result!.data?["is_enabled"] as? Bool
            XCTAssertEqual(resultValue, true)
        }, error: { (_) in
            XCTFail("Error shouldn't have been called")
        })

        plugin.disableTracking(call!)
    }

    func testSetIdentity() {
        let newIdentity = "123abc"

        let call = CAPPluginCall(callbackId: "setIdentity", methodName: "setIdentity", options: [
            "newIdentity": newIdentity
        ], success: { (result, _) in
            let resultValue = result!.data?["referringParams"] as? [AnyHashable : Any]
            XCTAssertEqual(resultValue!["+is_first_session"] as? Bool, false)
        }, error: { (_) in
            XCTFail("Error shouldn't have been called")
        })

        plugin.setIdentity(call!)
    }

    func testLogout() {
        let call = CAPPluginCall(callbackId: "logout", methodName: "logout", options: [:], success: { (result, _) in
            let resultValue = result!.data?["logged_out"] as? Bool
            XCTAssertEqual(resultValue, true)
        }, error: { (_) in
            XCTFail("Error shouldn't have been called")
        })

        plugin.logout(call!)
    }

    // MARK: - Scene links

    private let sceneOpenURL = URL(string: "myapp://open?link_click_id=123")!
    private let universalLink = URL(string: "https://example.app.link/qeFky9V118")!

    /// A forwarder on a private notification center, so tests don't touch the process-wide one.
    /// Notification objects that are strings stand in for scenes and become the scene identifier.
    private func makeForwarder(notificationCenter: NotificationCenter = NotificationCenter()) -> SceneLinkForwarder {
        return SceneLinkForwarder(branchService: branchServiceMock,
                                  notificationCenter: notificationCenter,
                                  sceneIdentifier: { $0 as? String })
    }

    func testForwardsSceneOpenURLWithSceneIdentifier() {
        let center = NotificationCenter()
        let forwarder = makeForwarder(notificationCenter: center)
        forwarder.start()

        center.post(name: .branchCapacitorSceneOpenURL, object: "scene-1", userInfo: ["url": sceneOpenURL, "options": [:]])

        XCTAssertEqual(branchServiceMock.sceneLinks, [.init(url: sceneOpenURL, sceneIdentifier: "scene-1")])
    }

    func testForwardsUniversalLinkWithSceneIdentifier() {
        let center = NotificationCenter()
        let forwarder = makeForwarder(notificationCenter: center)
        forwarder.start()

        center.post(name: .branchCapacitorSceneOpenUniversalLink, object: "scene-2", userInfo: ["url": universalLink])

        XCTAssertEqual(branchServiceMock.sceneLinks, [.init(url: universalLink, sceneIdentifier: "scene-2")])
    }

    func testForwardsNilSceneIdentifierWhenObjectIsNotAScene() {
        let forwarder = SceneLinkForwarder(branchService: branchServiceMock, notificationCenter: NotificationCenter())

        forwarder.handle(Notification(name: .branchCapacitorSceneOpenURL, object: nil, userInfo: ["url": sceneOpenURL]))

        XCTAssertEqual(branchServiceMock.sceneLinks, [.init(url: sceneOpenURL, sceneIdentifier: nil)])
    }

    func testIgnoresSceneNotificationsWithoutURL() {
        let forwarder = makeForwarder()

        forwarder.handle(Notification(name: .branchCapacitorSceneOpenURL, object: "scene-1", userInfo: nil))
        forwarder.handle(Notification(name: .branchCapacitorSceneOpenUniversalLink, object: "scene-1", userInfo: ["url": "not a URL"]))

        XCTAssertTrue(branchServiceMock.sceneLinks.isEmpty)
    }

    func testDoesNotRegisterObserversWhenHandleSceneLinksIsFalse() {
        let center = NotificationCenter()
        let forwarder = makeForwarder(notificationCenter: center)
        plugin.sceneLinkForwarder = forwarder

        plugin.configureSceneLinks(handleSceneLinks: false, hasSceneManifest: true, hasSceneDelegateProxy: true)
        center.post(name: .branchCapacitorSceneOpenURL, object: "scene-1", userInfo: ["url": sceneOpenURL])
        center.post(name: .branchCapacitorSceneOpenUniversalLink, object: "scene-1", userInfo: ["url": universalLink])

        XCTAssertFalse(forwarder.isStarted)
        XCTAssertTrue(branchServiceMock.sceneLinks.isEmpty)
    }

    func testSendsEachLinkToBranchOnceWithSeveralPluginInstances() {
        let center = NotificationCenter()
        let forwarder = makeForwarder(notificationCenter: center)
        let plugins = [BranchDeepLinks(), BranchDeepLinks(), BranchDeepLinks()]

        for plugin in plugins {
            plugin.sceneLinkForwarder = forwarder
            plugin.configureSceneLinks(handleSceneLinks: true, hasSceneManifest: true, hasSceneDelegateProxy: true)
        }
        center.post(name: .branchCapacitorSceneOpenURL, object: "scene-1", userInfo: ["url": sceneOpenURL])
        center.post(name: .branchCapacitorSceneOpenUniversalLink, object: "scene-1", userInfo: ["url": universalLink])

        XCTAssertEqual(branchServiceMock.sceneLinks, [
            .init(url: sceneOpenURL, sceneIdentifier: "scene-1"),
            .init(url: universalLink, sceneIdentifier: "scene-1")
        ])
    }

    func testPluginsShareTheProcessWideForwarderByDefault() {
        XCTAssertTrue(BranchDeepLinks().sceneLinkForwarder === BranchDeepLinks().sceneLinkForwarder)
        XCTAssertTrue(BranchDeepLinks().sceneLinkForwarder === SceneLinkForwarder.shared)
    }

    func testSceneLinksWarnings() {
        XCTAssertNotNil(BranchDeepLinks.sceneLinksWarning(handleSceneLinks: false, hasSceneManifest: true, hasSceneDelegateProxy: true))
        XCTAssertNotNil(BranchDeepLinks.sceneLinksWarning(handleSceneLinks: true, hasSceneManifest: true, hasSceneDelegateProxy: false))
        XCTAssertNil(BranchDeepLinks.sceneLinksWarning(handleSceneLinks: true, hasSceneManifest: true, hasSceneDelegateProxy: true))
        XCTAssertNil(BranchDeepLinks.sceneLinksWarning(handleSceneLinks: false, hasSceneManifest: false, hasSceneDelegateProxy: false))
    }
}
