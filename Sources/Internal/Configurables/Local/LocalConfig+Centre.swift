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
    public var popupPadding: EdgeInsets = GlobalConfigContainer.centre.popupPadding
    public var cornerRadius: CGFloat = GlobalConfigContainer.centre.cornerRadius
    public var backgroundColor: Color = GlobalConfigContainer.centre.backgroundColor
    public var overlayColor: Color = GlobalConfigContainer.centre.overlayColor
    public var isTapOutsideToDismissEnabled: Bool = GlobalConfigContainer.centre.isTapOutsideToDismissEnabled

    // MARK: Inactive Variables
    public var ignoredSafeAreaEdges: Edge.Set = []
    public var heightMode: HeightMode = .auto
    public var dragDetents: [DragDetent] = []
    public var isDragGestureEnabled: Bool = false
}

// MARK: Typealias
/**
 Configures the popup.
 See the list of available methods in ``LocalConfig``.

- important: If a certain method is not called here, the popup inherits the configuration from ``GlobalConfigContainer``.
 */
public typealias CentrePopupConfig = LocalConfigCentre



// MARK: - TESTS
#if DEBUG



extension LocalConfigCentre {
    static func t_createNew(popupPadding: EdgeInsets, cornerRadius: CGFloat) -> LocalConfigCentre {
        let config = LocalConfigCentre()
        config.popupPadding = popupPadding
        config.cornerRadius = cornerRadius
        return config
    }
}
#endif
