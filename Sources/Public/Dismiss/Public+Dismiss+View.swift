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
     Dismisses the currently active popup.

     - Parameters:
        - popupStackID: The identifier for which the popup was presented. For more information, see ``Popup/present(popupStackID:)``.

     - Important: Make sure you use the correct **popupStackID** from which you want to remove the popup.
     */
    @MainActor func dismissLastPopup(popupStackID: PopupStackID = .shared) async { await PopupStack.dismissLastPopup(popupStackID: popupStackID) }

    /**
     Dismisses all popups with the specified identifier.

     - Parameters:
        - id: Identifier of the popup located on the stack.
        - popupStackID: The identifier for which the popup was presented. For more information, see ``Popup/present(popupStackID:)``.

     - Important: Make sure you use the correct **popupStackID** from which you want to remove the popup.
     */
    @MainActor func dismissPopup(_ id: String, popupStackID: PopupStackID = .shared) async { await PopupStack.dismissPopup(id, popupStackID: popupStackID) }

    /**
     Dismisses all popups of the provided type.

     - Parameters:
        - type: Type of the popup located on the stack.
        - popupStackID: The identifier for which the popup was presented. For more information, see ``Popup/present(popupStackID:)``.

     - Important: If a custom ID (see ``Popup/setCustomID(_:)`` method for reference) is set for the popup, use the ``SwiftUICore/View/dismissPopup(_:popupStackID:)-55ubm`` method instead.
     - Important: Make sure you use the correct **popupStackID** from which you want to remove the popup.
     */
    @MainActor func dismissPopup<P: Popup>(_ type: P.Type, popupStackID: PopupStackID = .shared) async { await PopupStack.dismissPopup(type, popupStackID: popupStackID) }

    /**
     Dismisses all the popups.

     - Parameters:
        - popupStackID: The identifier for which the popup was presented. For more information, see ``Popup/present(popupStackID:)``.

     - Important: Make sure you use the correct **popupStackID** from which you want to remove the popups.
     */
    @MainActor func dismissAllPopups(popupStackID: PopupStackID = .shared) async { await PopupStack.dismissAllPopups(popupStackID: popupStackID) }
}
