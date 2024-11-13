//
//  Public+Present+Popup.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2023 Mijick. All rights reserved.


import SwiftUI

public extension Popup {
    /**
     Presents the popup.

     - Parameters:
        - popupManagerID: The identifier registered in one of the application windows in which the popup is to be displayed.

     - Important: The **popupManagerID** must be registered prior to use. For more information see ``SwiftUICore/View/registerPopups(id:configBuilder:)``.
     - Important: The methods
     ``PopupManager/dismissLastPopup(popupManagerID:)``,
     ``PopupManager/dismissPopup(_:popupManagerID:)-1atvy``,
     ``PopupManager/dismissPopup(_:popupManagerID:)-6l2c2``,
     ``PopupManager/dismissAllPopups(popupManagerID:)``,
     ``SwiftUICore/View/dismissLastPopup(popupManagerID:)``,
     ``SwiftUICore/View/dismissPopup(_:popupManagerID:)-55ubm``,
     ``SwiftUICore/View/dismissPopup(_:popupManagerID:)-9mkd5``,
     ``SwiftUICore/View/dismissAllPopups(popupManagerID:)``
     should be called with the same **popupManagerID** as the one used here.
     
     - Warning: To present multiple popups of the same type, set a unique identifier using the method ``Popup/setCustomID(_:)``.
     */
    @MainActor func present(popupManagerID: PopupManagerID = .shared) async { await PopupManager.fetchInstance(id: popupManagerID)?.stack(.insertPopup(.init(self))) }
}

// MARK: Configure Popup
public extension Popup {
    /**
     Sets the custom ID for the selected popup.

     - important: To dismiss a popup with a custom ID set, use methods ``PopupManager/dismissPopup(_:popupManagerID:)-1atvy`` or ``SwiftUICore/View/dismissPopup(_:popupManagerID:)-55ubm``
     - tip: Useful if you want to display several different popups of the same type.
     */
    @MainActor func setCustomID(_ id: String) async -> some Popup { await AnyPopup(self).updatedID(id) }

    /**
     Supplies an observable object to a popup's hierarchy.
     */
    @MainActor func setEnvironmentObject<T: ObservableObject>(_ object: T) async -> some Popup { await AnyPopup(self).updatedEnvironmentObject(object) }

    /**
     Dismisses the popup after a specified period of time.

     - Parameters:
        - seconds: Time in seconds after which the popup will be closed.
     */
    @MainActor func dismissAfter(_ seconds: Double) async -> some Popup { await AnyPopup(self).updatedDismissTimer(seconds) }
}
