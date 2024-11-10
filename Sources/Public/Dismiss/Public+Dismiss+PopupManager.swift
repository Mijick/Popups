//
//  Public+Dismiss+PopupManager.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import Foundation

public extension PopupManager {
    /**
     Removes the currently active popup from the stack.
     Makes the next popup in the stack the new active popup.

     - Parameters:
        - popupManagerID: The identifier for which the popup was presented. For more information, see ``Popup/present(popupManagerID:)``.

     - Important: Make sure you use the correct **popupManagerID** from which you want to remove the popup.
     */
    static func dismissLastPopup(popupManagerID: PopupManagerID = .shared) { Task { await fetchInstance(id: popupManagerID)?.stack(.removeLastPopup) }}

    /**
     Removes all popups with the specified identifier from the stack.

     - Parameters:
        - id: Identifier of the popup located on the stack.
        - popupManagerID: The identifier for which the popup was presented. For more information, see ``Popup/present(popupManagerID:)``.

     - Important: Make sure you use the correct **popupManagerID** from which you want to remove the popup.
     */
    static func dismissPopup(_ id: String, popupManagerID: PopupManagerID = .shared) { Task { await fetchInstance(id: popupManagerID)?.stack(.removeAllPopupsWithID(id)) }}

    /**
     Removes all popups of the provided type from the stack.

     - Parameters:
        - type: Type of the popup located on the stack.
        - popupManagerID: The identifier for which the popup was presented. For more information, see ``Popup/present(popupManagerID:)``.

     - Important: If a custom ID (``Popup/setCustomID(_:)``) is set for the popup, use the ``dismissPopup(_:popupManagerID:)-1atvy`` method instead.
     - Important: Make sure you use the correct **popupManagerID** from which you want to remove the popup.
     */
    static func dismissPopup<P: Popup>(_ type: P.Type, popupManagerID: PopupManagerID = .shared) { Task { await fetchInstance(id: popupManagerID)?.stack(.removeAllPopupsOfType(type)) }}

    /**
     Removes all popups from the stack.

     - Parameters:
        - popupManagerID: The identifier for which the popup was presented. For more information, see ``Popup/present(popupManagerID:)``.

     - Important: Make sure you use the correct **popupManagerID** from which you want to remove the popups.
     */
    static func dismissAllPopups(popupManagerID: PopupManagerID = .shared) { Task { await fetchInstance(id: popupManagerID)?.stack(.removeAllPopups) }}
}
