//
//  LocalConfig+Vertical.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

public class LocalConfigVertical: LocalConfig { required public init() {}
    // MARK: Content
    public var popupPadding: EdgeInsets = GlobalConfigContainer.vertical.popupPadding
    public var cornerRadius: CGFloat = GlobalConfigContainer.vertical.cornerRadius
    public var ignoredSafeAreaEdges: Edge.Set = GlobalConfigContainer.vertical.ignoredSafeAreaEdges
    public var backgroundColor: Color = GlobalConfigContainer.vertical.backgroundColor
    public var overlayColor: Color = GlobalConfigContainer.vertical.overlayColor
    public var heightMode: HeightMode = GlobalConfigContainer.vertical.heightMode
    public var dragDetents: [DragDetent] = GlobalConfigContainer.vertical.dragDetents

    // MARK: Gestures
    public var isTapOutsideToDismissEnabled: Bool = GlobalConfigContainer.vertical.isTapOutsideToDismissEnabled
    public var isDragGestureEnabled: Bool = GlobalConfigContainer.vertical.isDragGestureEnabled
}

// MARK: Subclasses & Typealiases
public extension LocalConfigVertical {
    class Top: LocalConfigVertical {}
    class Bottom: LocalConfigVertical {}
}

/**
 Configures the popup.
 See the list of available methods in ``LocalConfig`` and ``LocalConfig/Vertical``.

- important: If a certain method is not called here, the popup inherits the configuration from ``GlobalConfigContainer``.
 */
public typealias TopPopupConfig = LocalConfigVertical.Top

/**
 Configures the popup.
 See the list of available methods in ``LocalConfig`` and ``LocalConfig/Vertical``.

- important: If a certain method is not called here, the popup inherits the configuration from ``GlobalConfigContainer``.
 */
public typealias BottomPopupConfig = LocalConfigVertical.Bottom



// MARK: - TESTS
#if DEBUG



extension LocalConfigVertical {
    static func t_createNew<C: LocalConfigVertical>(popupPadding: EdgeInsets, cornerRadius: CGFloat, ignoredSafeAreaEdges: Edge.Set, heightMode: HeightMode, dragDetents: [DragDetent], isDragGestureEnabled: Bool) -> C {
        let config = C()
        config.popupPadding = popupPadding
        config.cornerRadius = cornerRadius
        config.ignoredSafeAreaEdges = ignoredSafeAreaEdges
        config.heightMode = heightMode
        config.dragDetents = dragDetents
        config.isDragGestureEnabled = isDragGestureEnabled
        return config
    }
}
#endif
