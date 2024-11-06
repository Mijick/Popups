//
//  Public+Popup+Utilities.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import Foundation

// MARK: Height Mode
public enum HeightMode: Sendable {
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
public enum DragDetent: Sendable {
    /**
     A detent with the specified height.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/drag-detent-height.png?raw=true)
     */
    case height(CGFloat)

    /**
     A detent with the specified fractional height.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/drag-detent-fraction.png?raw=true)
     */
    case fraction(CGFloat)

    /**
     A detent for a popup at large height.
     See ``HeightMode/large`` for more details.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/drag-detent-large.png?raw=true)
     */
    case large

    /**
     A detent for a popup at fullscreen height.
     See ``HeightMode/fullscreen`` for more details.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/drag-detent-fullscreen.png?raw=true)
     */
    case fullscreen
}
