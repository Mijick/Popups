//
//  LocalConfig+Centre.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

public class LocalConfigCentre: LocalConfig { required public init() {}
    // MARK: Active Variables
    public var popupPadding: EdgeInsets = GlobalConfigContainer.center.popupPadding
    public var cornerRadius: CGFloat = GlobalConfigContainer.center.cornerRadius
    public var backgroundColor: Color = GlobalConfigContainer.center.backgroundColor
    public var overlayColor: Color = GlobalConfigContainer.center.overlayColor
    public var isTapOutsideToDismissEnabled: Bool = GlobalConfigContainer.center.isTapOutsideToDismissEnabled

    // MARK: Inactive Variables
    public var ignoredSafeAreaEdges: Edge.Set = GlobalConfigContainer.center.ignoredSafeAreaEdges
    public var heightMode: HeightMode = GlobalConfigContainer.center.heightMode
    public var dragDetents: [DragDetent] = GlobalConfigContainer.center.dragDetents
    public var isDragGestureEnabled: Bool = GlobalConfigContainer.center.isDragGestureEnabled
}

// MARK: Typealias
/**
 Configures the popup.
 See the list of available methods in ``LocalConfig``.

- important: If a certain method is not called here, the popup inherits the configuration from ``GlobalConfigContainer``.
 */
public typealias CentrePopupConfig = LocalConfigCentre
