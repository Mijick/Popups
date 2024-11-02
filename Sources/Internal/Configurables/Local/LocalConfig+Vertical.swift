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

public extension LocalConfig { class Vertical: LocalConfig {
    var ignoredSafeAreaEdges: Edge.Set = []
    var heightMode: HeightMode = .auto
    var dragDetents: [DragDetent] = []
    var isDragGestureEnabled: Bool = GlobalConfigContainer.vertical.isDragGestureEnabled


    required init() { super.init()
        self.popupPadding = GlobalConfigContainer.vertical.popupPadding
        self.cornerRadius = GlobalConfigContainer.vertical.cornerRadius
        self.backgroundColor = GlobalConfigContainer.vertical.backgroundColor
        self.overlayColor = GlobalConfigContainer.vertical.overlayColor
        self.isTapOutsideToDismissEnabled = GlobalConfigContainer.vertical.isTapOutsideToDismissEnabled
    }
}}

// MARK: Subclasses & Typealiases
/**
 Configures the popup.
 See the list of available methods in ``LocalConfig`` and ``LocalConfig/Vertical``.

- important: If a certain method is not called here, the popup inherits the configuration from ``GlobalConfigContainer``.
 */
public typealias TopPopupConfig = LocalConfig.Vertical.Top

/**
 Configures the popup.
 See the list of available methods in ``LocalConfig`` and ``LocalConfig/Vertical``.

- important: If a certain method is not called here, the popup inherits the configuration from ``GlobalConfigContainer``.
 */
public typealias BottomPopupConfig = LocalConfig.Vertical.Bottom
public extension LocalConfig.Vertical {
    class Top: LocalConfig.Vertical {}
    class Bottom: LocalConfig.Vertical {}
}



// MARK: - TESTS
#if DEBUG



extension LocalConfig.Vertical {
    static func t_createNew<C: LocalConfig.Vertical>(popupPadding: EdgeInsets, cornerRadius: CGFloat, ignoredSafeAreaEdges: Edge.Set, heightMode: HeightMode, dragDetents: [DragDetent], isDragGestureEnabled: Bool) -> C {
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
