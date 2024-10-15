//
//  Public+Utilities+Popup.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import Foundation

// MARK: Height Mode
public enum HeightMode {
    /**
     Popup height is calculated based on its content.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/height-mode-auto.png?raw=true)

     - note: If the calculated height is greater than the screen height, the height mode will automatically be switched to ``large``.
     */
    case auto

    /**
     The popup has a fixed height, which is equal to the height of the screen minus the safe area and the height of the popups stack (if ``GlobalConfig/Vertical/enableStacking(_:)`` is enabled).

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/height-mode-large.png?raw=true)
     */
    case large

    /**
     Fills the entire height of the screen, regardless of the height of the popup content.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/height-mode-fullscreen.png?raw=true)
     */
    case fullscreen
}

// MARK: Drag Detent
public enum DragDetent {
    case fixed(CGFloat)
    case fraction(CGFloat)
    case large
    case fullscreen
}
