import UIKit
import Capacitor
import BranchSDK
import BranchDeepLinksPlugin
import Firebase
import GoogleAdsOnDeviceConversion


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // TEST-ONLY (do not commit): send stdout/stderr to Documents/testbed.log so device runs, including
    // cold starts from a tapped link, can be pulled with `xcrun devicectl device copy from`.
    private func startTestLog() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let path = docs.appendingPathComponent("testbed.log").path
        freopen(path, "a", stdout)
        freopen(path, "a", stderr)
        setvbuf(stdout, nil, _IOLBF, 0)
        setvbuf(stderr, nil, _IONBF, 0)
        print("\n===== [TEST] LAUNCH \(Date()) pid=\(getpid()) =====")

        let center = NotificationCenter.default
        for name in ["CapacitorSceneOpenURLNotification", "CapacitorSceneOpenUniversalLinkNotification"] {
            center.addObserver(forName: Notification.Name(name), object: nil, queue: nil) { note in
                let scene = (note.object as? UIScene)?.session.persistentIdentifier ?? "nil"
                print("[TEST] \(name) url=\(note.userInfo?["url"] ?? "nil") scene=\(scene)")
            }
        }
        center.addObserver(forName: .BranchDidStartSession, object: nil, queue: nil) { note in
            let error = note.userInfo?[BranchErrorKey] as? Error
            let params = Branch.getInstance().getLatestReferringParams() ?? [:]
            print("[TEST] BranchDidStartSession error=\(error.map { "\($0)" } ?? "nil") clicked=\(params["+clicked_branch_link"] ?? "nil") params=\(params)")
        }
        center.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in
            print("[TEST] didBecomeActive")
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        startTestLog() // TEST-ONLY

        FirebaseApp.configure()
    
        // Branch.getInstance().setConsumerProtectionAttributionLevel(.reduced)
        // Branch.setSDKWaitTimeForThirdPartyAPIs(3)
        // Branch.setODMInfo("testODMInfo", andFirstOpenTimestamp: Date())
        // Branch.setAnonID("AnonIDTest")
        // Branch.getInstance().setRequestMetadataKey("insert_user_id", value: "value") // If you need to append partner metadata before initializing Branch

        // Branch.setUseTestBranchKey(true) // If you are using the TEST key
        
        // TEST-ONLY: route Branch logs through print so they land in testbed.log unredacted.
        Branch.enableLogging(at: BranchLogLevel.verbose) { message, level, error in
            print("[Branch][\(level.rawValue)] \(message)\(error.map { " error=\($0)" } ?? "")")
        }

        Branch.getInstance().initSession(launchOptions: launchOptions)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Called when the app was launched with a url. Feel free to add additional processing here,
        // but if you want the App API to support tracking app url opens, make sure to keep this call.
        // Branch links are forwarded by the BranchDeepLinks plugin (UIScene path), not here.
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Called when the app was launched with an activity, including Universal Links.
        // Feel free to add additional processing here, but if you want the App API to support
        // tracking app url opens, make sure to keep this call.
        // Branch links are forwarded by the BranchDeepLinks plugin (UIScene path), not here.
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Branch.getInstance().handlePushNotification(userInfo)
    }


    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration",
                                          sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}
