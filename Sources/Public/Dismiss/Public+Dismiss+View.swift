//
//  Public+Dismiss+View.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

public extension View {
    /**
     Removes the currently active popup from the stack.
     Makes the next popup in the stack the new active popup.

     - Parameters:
        - popupManagerID: The identifier for which the popup was presented. For more information, see ``Popup/present(popupManagerID:)``.

     - Important: Make sure you use the correct **popupManagerID** from which you want to remove the popup.
     */
    @MainActor func dismissLastPopup(popupManagerID: PopupManagerID = .shared) async { await PopupManager.dismissLastPopup(popupManagerID: popupManagerID) }

    /**
     Removes all popups with the specified identifier from the stack.

     - Parameters:
        - id: Identifier of the popup located on the stack.
        - popupManagerID: The identifier for which the popup was presented. For more information, see ``Popup/present(popupManagerID:)``.

     - Important: Make sure you use the correct **popupManagerID** from which you want to remove the popup.
     */
    @MainActor func dismissPopup(_ id: String, popupManagerID: PopupManagerID = .shared) async { await PopupManager.dismissPopup(id, popupManagerID: popupManagerID) }

    /**
     Removes all popups of the provided type from the stack.

     - Parameters:
        - type: Type of the popup located on the stack.
        - popupManagerID: The identifier for which the popup was presented. For more information, see ``Popup/present(popupManagerID:)``.

     - Important: If a custom ID (see ``Popup/setCustomID(_:)`` method for reference) is set for the popup, use the ``SwiftUICore/View/dismissPopup(_:popupManagerID:)-55ubm`` method instead.
     - Important: Make sure you use the correct **popupManagerID** from which you want to remove the popup.
     */
    @MainActor func dismissPopup<P: Popup>(_ type: P.Type, popupManagerID: PopupManagerID = .shared) async { await PopupManager.dismissPopup(type, popupManagerID: popupManagerID) }

    /**
     Removes all popups from the stack.

     - Parameters:
        - popupManagerID: The identifier for which the popup was presented. For more information, see ``Popup/present(popupManagerID:)``.

     - Important: Make sure you use the correct **popupManagerID** from which you want to remove the popups.
     */
    @MainActor func dismissAllPopups(popupManagerID: PopupManagerID = .shared) async { await PopupManager.dismissAllPopups(popupManagerID: popupManagerID) }
}
