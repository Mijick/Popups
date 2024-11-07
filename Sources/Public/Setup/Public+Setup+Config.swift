//
//  Public+Setup+Config.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

// MARK: Centre
public extension GlobalConfigCentre {
    /**
     Distance of the entire popup (including its background) from the horizontal edges of the screen.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/horizontal-padding.png?raw=true)
     */
    func popupHorizontalPadding(_ value: CGFloat) -> Self { self.popupPadding = .init(top: popupPadding.top, leading: value, bottom: popupPadding.bottom, trailing: value); return self }

    /**
     Corner radius of the background of the active popup.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/corner-radius.png?raw=true)
     */
    func cornerRadius(_ value: CGFloat) -> Self { self.cornerRadius = value; return self }

    /**
     Background color of the popup.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/background-color.png?raw=true)
     */
    func backgroundColor(_ color: Color) -> Self { self.backgroundColor = color; return self }

    /**
     The color of the overlay covering the view behind the popup.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/overlay-color.png?raw=true)

     - tip: Use .clear to hide the overlay.
     */
    func overlayColor(_ color: Color) -> Self { self.overlayColor = color; return self }

    /**
     If enabled, dismisses the active popup when touched outside its area.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/tap-to-close.png?raw=true)
     */
    func tapOutsideToDismissPopup(_ value: Bool) -> Self { self.isTapOutsideToDismissEnabled = value; return self }
}

// MARK: Vertical
public extension GlobalConfigVertical {
    /**
     Distance of the entire popup (including its background) from the top edge of the screen.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/top-padding.png?raw=true)
     */
    func popupTopPadding(_ value: CGFloat) -> Self { self.popupPadding = .init(top: value, leading: popupPadding.leading, bottom: popupPadding.bottom, trailing: popupPadding.trailing); return self }

    /**
     Distance of the entire popup (including its background) from the bottom edge of the screen.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/bottom-padding.png?raw=true)
     */
    func popupBottomPadding(_ value: CGFloat) -> Self { self.popupPadding = .init(top: popupPadding.top, leading: popupPadding.leading, bottom: value, trailing: popupPadding.trailing); return self }
    
    /**
     Distance of the entire popup (including its background) from the horizontal edges of the screen.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/horizontal-padding.png?raw=true)
     */
    func popupHorizontalPadding(_ value: CGFloat) -> Self { self.popupPadding = .init(top: popupPadding.top, leading: value, bottom: popupPadding.bottom, trailing: value); return self }

    /**
     Corner radius of the background of the active popup.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/corner-radius.png?raw=true)
     */
    func cornerRadius(_ value: CGFloat) -> Self { self.cornerRadius = value; return self }

    /**
     Background color of the popup.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/background-color.png?raw=true)
     */
    func backgroundColor(_ color: Color) -> Self { self.backgroundColor = color; return self }

    /**
     The color of the overlay covering the view behind the popup.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/overlay-color.png?raw=true)

     - tip: Use .clear to hide the overlay.
     */
    func overlayColor(_ color: Color) -> Self { self.overlayColor = color; return self }

    /**
     Indicates whether stacked popups should be visible in the view.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/enable-stacking.png?raw=true)
     */
    func enableStacking(_ value: Bool) -> Self { self.isStackingEnabled = value; return self }

    /**
     If enabled, dismisses the active popup when touched outside its area.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/tap-to-close.png?raw=true)
     */
    func tapOutsideToDismissPopup(_ value: Bool) -> Self { self.isTapOutsideToDismissEnabled = value; return self }

    /**
     Determines whether it's possible to interact with popups using a drag gesture.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/enable-drag-gesture.png?raw=true)
     */
    func enableDragGesture(_ value: Bool) -> Self { self.isDragGestureEnabled = value; return self }
    
    /**
     The drag progress value above which the popup will either be dismissed or move to the next drag detent value.

     ## Visualisation
     ![image](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/drag-threshold.png?raw=true)

     - important: Drag progress is calculated as **dragTranslation** / **popupHeight**, therefore drag threshold value is expected to be between 0 and 1.
     */
    func dragThreshold(_ value: CGFloat) -> Self { self.dragThreshold = value; return self }
}
