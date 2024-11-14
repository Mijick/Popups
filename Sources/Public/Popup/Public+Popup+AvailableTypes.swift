//
//  Public+Popup+AvailableTypes.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


// MARK: Top
/**
 Configures the popup.
 See the list of available methods in ``LocalConfig`` and ``LocalConfig/Vertical``.

 - important: If a certain method is not called here, the popup inherits the configuration from ``GlobalConfigContainer``.
 */
public typealias TopPopupConfig = LocalConfigVertical.Top



// MARK: Center
/**
 Configures the popup.
 See the list of available methods in ``LocalConfig``.

 - important: If a certain method is not called here, the popup inherits the configuration from ``GlobalConfigContainer``.
 */
public typealias CenterPopupConfig = LocalConfigCenter



// MARK: Bottom
/**
 Configures the popup.
 See the list of available methods in ``LocalConfig`` and ``LocalConfig/Vertical``.

 - important: If a certain method is not called here, the popup inherits the configuration from ``GlobalConfigContainer``.
 */
public typealias BottomPopupConfig = LocalConfigVertical.Bottom
