//
//  Public+Popup.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

public protocol Popup: View {
    associatedtype Config: LocalConfig

    func configurePopup(popup: Config) -> Config
    func onFocus()
    func onDismiss()
}

// MARK: Default Methods Implementation
public extension Popup {
    func configurePopup(popup: Config) -> Config { popup }
    func onFocus() {}
    func onDismiss() {}
}


// MARK: - Presenting
public extension Popup {
    /// Displays the popup. Stacks previous one
    func present(id: PopupManagerID = .shared) { PopupManager.fetchInstance(id: id)?.stack(.insertPopup(self)) }
}

// MARK: - Modifiers
public extension Popup {
    /// Closes popup after n seconds
    func dismissAfter(_ seconds: Double) -> some Popup { AnyPopup(self).settingDismissTimer(seconds) }

    func setCustomID(_ id: String) -> some Popup { AnyPopup(self).settingCustomID(id) }

    /// Supplies an observable object to a view’s hierarchy
    func setEnvironmentObject<T: ObservableObject>(_ object: T) -> some Popup { AnyPopup(self).settingEnvironmentObject(object) }
}

// MARK: - Available Popups
public protocol TopPopup: Popup { associatedtype Config = TopPopupConfig }
public protocol CentrePopup: Popup { associatedtype Config = CentrePopupConfig }
public protocol BottomPopup: Popup { associatedtype Config = BottomPopupConfig }
