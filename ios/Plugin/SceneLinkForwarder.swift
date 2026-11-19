import Foundation
import UIKit

extension Notification.Name {
    // Posted by Capacitor's SceneDelegateProxy (Capacitor 8.5+) only. Unlike .capacitorOpenURL and
    // .capacitorOpenUniversalLink, these are never posted on the AppDelegate path, so apps that still
    // call Branch from their AppDelegate don't get each link handled twice. Raw names keep the plugin
    // building against Capacitor 8.0–8.4, which never post them.
    static let branchCapacitorSceneOpenURL = Notification.Name("CapacitorSceneOpenURLNotification")
    static let branchCapacitorSceneOpenUniversalLink = Notification.Name("CapacitorSceneOpenUniversalLinkNotification")
}

/// Forwards links from Capacitor's scene notifications to Branch.
///
/// Every Capacitor bridge loads its own plugin instance, but `Branch` is a process-wide singleton, so the
/// observers are registered once per process: each link reaches Branch exactly once, however many
/// bridges (or windows) the app has.
final class SceneLinkForwarder {
    static let shared = SceneLinkForwarder()

    private let branchService: BranchService
    private let notificationCenter: NotificationCenter
    /// Maps a notification's `object` to the scene identifier passed to Branch. A seam so tests don't
    /// need a real `UIScene`.
    private let sceneIdentifier: (Any?) -> String?
    private let lock = NSLock()
    private var observers: [NSObjectProtocol] = []

    init(branchService: BranchService = BranchService(),
         notificationCenter: NotificationCenter = .default,
         sceneIdentifier: @escaping (Any?) -> String? = SceneLinkForwarder.persistentIdentifier(of:)) {
        self.branchService = branchService
        self.notificationCenter = notificationCenter
        self.sceneIdentifier = sceneIdentifier
    }

    deinit {
        observers.forEach(notificationCenter.removeObserver)
    }

    var isStarted: Bool {
        lock.lock()
        defer { lock.unlock() }
        return !observers.isEmpty
    }

    /// Registers the scene observers. Safe to call from every plugin instance: only the first call has an effect.
    func start() {
        lock.lock()
        defer { lock.unlock() }
        guard observers.isEmpty else { return }

        // Cold-start links are held by Capacitor until the first view appears, after plugins have loaded,
        // then posted through these same notifications.
        observers = [.branchCapacitorSceneOpenURL, .branchCapacitorSceneOpenUniversalLink].map { name in
            notificationCenter.addObserver(forName: name, object: nil, queue: nil) { [weak self] notification in
                self?.handle(notification)
            }
        }
    }

    func handle(_ notification: Notification) {
        guard let url = notification.userInfo?["url"] as? URL else { return }
        branchService.handleSceneLink(url: url, sceneIdentifier: sceneIdentifier(notification.object))
    }

    static func persistentIdentifier(of object: Any?) -> String? {
        return (object as? UIScene)?.session.persistentIdentifier
    }
}
