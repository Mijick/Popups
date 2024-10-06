//
//  Public+View.swift of
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

// MARK: - Initialising
public extension View {
    /// Initialises the library. Use directly with the view in your @main structure
    func implementPopupView(id: PopupManagerID = .shared, config: @escaping (ConfigContainer) -> ConfigContainer = { $0 }) -> some View {
        let popupManager = PopupManager.registerInstance(for: id)

    #if os(iOS) || os(macOS) || os(visionOS) || os(watchOS)
        return self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(PopupView(popupManager: popupManager), alignment: .top)
            .onAppear { _ = config(.init()) }
    #elseif os(tvOS)
        return PopupView(rootView: updateScreenSize()).onAppear { _ = config(.init()) }
    #endif
    }
}

// MARK: - Dismissing Popups
public extension View {
    /// Dismisses the last popup on the stack
    func dismiss(id: PopupManagerID = .shared) { PopupManager.dismiss(manID: id) }

    /// Dismisses all the popups of provided type on the stack
    func dismissPopup<P: Popup>(_ popup: P.Type, id: PopupManagerID = .shared) { PopupManager.dismissPopup(popup, manID: id) }

    /// Dismisses all the popups on the stack
    func dismissAll(id: PopupManagerID = .shared) { PopupManager.dismissAll(manID: id) }
}
