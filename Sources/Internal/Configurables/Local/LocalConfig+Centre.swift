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

public extension LocalConfig { class Centre: LocalConfig {
    required init() { super.init()
        self.popupPadding = GlobalConfigContainer.centre.popupPadding
        self.cornerRadius = GlobalConfigContainer.centre.cornerRadius
        self.backgroundColor = GlobalConfigContainer.centre.backgroundColor
        self.overlayColor = GlobalConfigContainer.centre.overlayColor
        self.isTapOutsideToDismissEnabled = GlobalConfigContainer.centre.isTapOutsideToDismissEnabled
    }
}}

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
