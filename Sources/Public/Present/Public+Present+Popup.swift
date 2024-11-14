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
        - popupStackID: The identifier registered in one of the application windows in which the popup is to be displayed.

     - Important: The **popupStackID** must be registered prior to use. For more information see ``SwiftUICore/View/registerPopups(id:configBuilder:)``.
     - Important: The methods
     ``PopupStack/dismissLastPopup(popupStackID:)``,
     ``PopupStack/dismissPopup(_:popupStackID:)-1atvy``,
     ``PopupStack/dismissPopup(_:popupStackID:)-6l2c2``,
     ``PopupStack/dismissAllPopups(popupStackID:)``,
     ``SwiftUICore/View/dismissLastPopup(popupStackID:)``,
     ``SwiftUICore/View/dismissPopup(_:popupStackID:)-55ubm``,
     ``SwiftUICore/View/dismissPopup(_:popupStackID:)-9mkd5``,
     ``SwiftUICore/View/dismissAllPopups(popupStackID:)``
     should be called with the same **popupStackID** as the one used here.
     
     - Warning: To present multiple popups of the same type, set a unique identifier using the method ``Popup/setCustomID(_:)``.
     */
    @MainActor func present(popupStackID: PopupStackID = .shared) async { await PopupStack.fetch(id: popupStackID)?.modify(.insertPopup(.init(self))) }
}

// MARK: Configure Popup
public extension Popup {
    /**
     Sets the custom ID for the selected popup.

     - important: To dismiss a popup with a custom ID set, use methods ``PopupStack/dismissPopup(_:popupStackID:)-1atvy`` or ``SwiftUICore/View/dismissPopup(_:popupStackID:)-55ubm``
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
