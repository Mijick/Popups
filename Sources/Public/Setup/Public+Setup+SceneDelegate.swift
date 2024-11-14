//
//  Public+Setup+SceneDelegate.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

#if os(iOS)
/**
 Registers the framework to work in your application. Works on iOS only.

 - tip:  Recommended initialization way when using the framework with standard Apple sheets.

 ## Usage
 ```swift
 @main struct App_Main: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene { WindowGroup(content: ContentView.init) }
 }

 class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = CustomPopupSceneDelegate.self
        return sceneConfig
    }
 }

 class CustomPopupSceneDelegate: PopupSceneDelegate {
    override init() { super.init()
        configBuilder = { $0
            .vertical { $0
                .enableDragGesture(true)
                .tapOutsideToDismissPopup(true)
                .cornerRadius(32)
            }
            .center { $0
                .tapOutsideToDismissPopup(false)
                .backgroundColor(.white)
            }
        }
    }
 }
 ```

 - seealso: It's also possible to register the framework with ``SwiftUICore/View/registerPopups(id:configBuilder:)``.
 */
open class PopupSceneDelegate: NSObject, UIWindowSceneDelegate {
    open var window: UIWindow?
    open var configBuilder: (GlobalConfigContainer) -> (GlobalConfigContainer) = { _ in .init() }
}

// MARK: Create Popup Scene
extension PopupSceneDelegate {
    open func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) { if let windowScene = scene as? UIWindowScene {
        let hostingController = UIHostingController(rootView: Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .registerPopups(configBuilder: configBuilder)
        )
        hostingController.view.backgroundColor = .clear

        window = Window(windowScene: windowScene)
        window?.rootViewController = hostingController
        window?.isHidden = false
    }}
}



// MARK: - WINDOW



// MARK: Implementation
fileprivate class Window: UIWindow {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if #available(iOS 18, *) { point_iOS18(inside: point, with: event) }
        else { point_iOS17(inside: point, with: event) }
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if #available(iOS 18, *) { hitTest_iOS18(point, with: event) }
        else { hitTest_iOS17(point, with: event) }
    }
}

// MARK: Point
private extension Window {
    @available(iOS 18, *)
    func point_iOS18(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let view = rootViewController?.view else { return false }

        let hit = hitTestHelper(point, with: event, view: subviews.count > 1 ? self : view)
        return hit != nil
    }
    func point_iOS17(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event)
    }
}

// MARK: Hit Test
private extension Window {
    @available(iOS 18, *)
    func hitTest_iOS18(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event)
    }
    func hitTest_iOS17(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hit = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == hit ? nil : hit
    }
}


// MARK: Hit Test Helper
// Based on philip_trauner solution: https://forums.developer.apple.com/forums/thread/762292?answerId=803885022#803885022
@available(iOS 18, *)
private extension Window {
    func hitTestHelper(_ point: CGPoint, with event: UIEvent?, view: UIView, depth: Int = 0) -> HitTestResult? {
        view.subviews.reversed().reduce(nil) { deepest, subview in let convertedPoint = view.convert(point, to: subview)
            guard shouldCheckSubview(subview, convertedPoint: convertedPoint, event: event) else { return deepest }

            let result = calculateHitTestSubviewResult(convertedPoint, with: event, subview: subview, depth: depth)
            return getDeepestHitTestResult(candidate: result, current: deepest)
        }
    }
}
@available(iOS 18, *)
private extension Window {
    func shouldCheckSubview(_ subview: UIView, convertedPoint: CGPoint, event: UIEvent?) -> Bool {
        subview.isUserInteractionEnabled &&
        subview.isHidden == false &&
        subview.alpha > 0 &&
        subview.point(inside: convertedPoint, with: event)
    }
    func calculateHitTestSubviewResult(_ point: CGPoint, with event: UIEvent?, subview: UIView, depth: Int) -> HitTestResult {
        switch hitTestHelper(point, with: event, view: subview, depth: depth + 1) {
            case .some(let result): result
            case nil: (subview, depth)
        }
    }
    func getDeepestHitTestResult(candidate: HitTestResult, current: HitTestResult?) -> HitTestResult {
        switch current {
            case .some(let current) where current.depth > candidate.depth: current
            default: candidate
        }
    }
}
@available(iOS 18, *)
private extension Window {
    typealias HitTestResult = (view: UIView, depth: Int)
}
#endif
