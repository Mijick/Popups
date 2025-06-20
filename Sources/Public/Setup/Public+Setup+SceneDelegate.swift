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

fileprivate class Window: UIWindow {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if #available(iOS 26, *) {
            return super.point(inside: point, with: event)
        }
        
        if #available(iOS 18, *) {
            return point_iOS18(inside: point, with: event)
        }
        
        return super.point(inside: point, with: event)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if #available(iOS 26, *) {
            return hitTest_iOS19(point, with: event)
        }
        
        if #available(iOS 18, *) {
            return hitTest_iOS18(point, with: event)
        }
        
        return hitTest_iOS17(point, with: event)
    }
}


// MARK: - VERSION-SPECIFIC HELPERS

private extension Window {
    func hitTest_iOS17(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hit = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == hit ? nil : hit
    }
    
    @available(iOS 18, *)
    func point_iOS18(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let view = rootViewController?.view else { return false }
        let hit = hitTestHelper(point, with: event, view: subviews.count > 1 ? self : view)
        return hit != nil
    }

    @available(iOS 18, *)
    func hitTest_iOS18(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event)
    }

    @available(iOS 26, *)
    func hitTest_iOS19(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let rootView = self.rootViewController?.view else { return nil }

        // Instead of using the fragile helper, we will ask the system's reliable
        // hit-test method to find the correct view, but we'll start it from the
        // rootView, not the window. First, we must convert the point to the
        // rootView's coordinate system.
        let pointInRootView = self.convert(point, to: rootView)
        
        // Now, ask the rootView to find the deepest subview at that point.
        // This is much more robust than our manual hitTestHelper.
        let hitView = rootView.hitTest(pointInRootView, with: event)

        let isTapOutsideToDismissEnabled = PopupStackContainer.stacks.first?.popups.last?.config.isTapOutsideToDismissEnabled ?? false

        // If the hit view is the rootView itself, it means the background was tapped.
        if hitView == rootView || hitView == nil {
             // If tap-to-dismiss is on, we must handle the touch on the background.
             // If off, we return nil to pass the touch through to the app below.
            return isTapOutsideToDismissEnabled ? rootView : nil
        }
        
        // A specific interactive subview (Button, TextField, etc.) was hit.
        // Return it so it can process the touch.
        return hitView
    }
}


@available(iOS 18, *)
private extension Window {
    func hitTestHelper(_ point: CGPoint, with event: UIEvent?, view: UIView, depth: Int = 0) -> HitTestResult? {
        view.subviews.reversed().reduce(nil) { deepest, subview in let convertedPoint = view.convert(point, to: subview)
            guard shouldCheckSubview(subview, convertedPoint: convertedPoint, event: event) else { return deepest }

            let result = calculateHitTestSubviewResult(convertedPoint, with: event, subview: subview, depth: depth)
            return getDeepestHitTestResult(candidate: result, current: deepest)
        }
    }
    
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
    
    typealias HitTestResult = (view: UIView, depth: Int)
}
#endif