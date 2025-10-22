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
    open func sceneStoppedBeingFirstResponder() { }
    open func makeSceneKey() { window?.makeKey() }
}

// MARK: Create Popup Scene
extension PopupSceneDelegate {
    open func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) { if let windowScene = scene as? UIWindowScene {
        let hostingController = UIHostingController(rootView: Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .registerPopups(configBuilder: configBuilder)
        )
        hostingController.view.backgroundColor = .clear
        window = Window(scene: self, windowScene: windowScene)
        window?.rootViewController = hostingController
        window?.isHidden = false
        window?.makeKey()
    }}
}


// MARK: - WINDOW




fileprivate class Window: UIWindow {
    weak var scene: PopupSceneDelegate?
    
    init(scene: PopupSceneDelegate, windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        self.scene = scene
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Implementation
extension Window {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if #available(iOS 26, *) { point_iOS26(inside: point, with: event) }
        else if #available(iOS 18, *) { point_iOS18(inside: point, with: event) }
        else { point_iOS17(inside: point, with: event) }
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if #available(iOS 26, *) { hitTest_iOS26(point, with: event) }
        else if #available(iOS 18, *) { hitTest_iOS18(point, with: event) }
        else { hitTest_iOS17(point, with: event) }
    }
    override func resignKey() {
        super.resignKey()
        
        scene?.sceneStoppedBeingFirstResponder()
    }
}

// MARK: Point
private extension Window {
    @available(iOS 26, *)
    func point_iOS26(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event)
    }
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
    @available(iOS 26, *)
    func hitTest_iOS26(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let rootView = self.rootViewController?.view else { return nil }
        guard let isDismissParameterEmpty = PopupStackContainer.stacks.first?.popups.last?.config.isTapOutsideToDismissEnabled else { return nil }
        
        let pointInRootView = self.convert(point, to: rootView)
        let hitView = rootView.hitTest(pointInRootView, with: event)
        let isTapOutsideToDismissEnabled = PopupStackContainer.stacks.first?.popups.last?.config.isTapOutsideToDismissEnabled ?? false
        
        if hitView == rootView || hitView == nil { return isTapOutsideToDismissEnabled ? rootView : hitView }
        return hitView
    }
  
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
