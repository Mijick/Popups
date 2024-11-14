//
//  Public+Popup+Main.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

/**
 The view to be displayed as a popup. It may appear in one of three positions (see **Usage Examples** section).
 # Optional Methods
 - ``configurePopup(config:)-3ze4``
 - ``onFocus()-6krqs``
 - ``onDismiss()-254h8``
 */
public protocol Popup: View {
    associatedtype Config: LocalConfig

    /**
     Configures the popup.
     See the list of available methods in ``LocalConfig`` and ``LocalConfig/Vertical``.

    - important: If a certain method is not called here, the popup inherits the configuration from ``GlobalConfigContainer``.
     */
    func configurePopup(config: Config) -> Config

    /**
     Method triggered **every time** a popup is at the top of the stack.
     */
    func onFocus()

    /**
     Method triggered when a popup is dismissed.
     */
    func onDismiss()
}

// MARK: Default Methods Implementation
public extension Popup {
    func configurePopup(config: Config) -> Config { config }
    func onFocus() {}
    func onDismiss() {}
}

// MARK: Available Types
/**
 The view to be displayed as a Top popup.
 
 # Optional Methods
 - ``Popup/configurePopup(config:)-98ha0``
 - ``Popup/onFocus()-6krqs``
 - ``Popup/onDismiss()-3bufs``
 
 # Usage Example
 ```swift
 struct TopPopupExample: TopPopup {
    func onFocus() { print("Popup is now active") }
    func onDismiss() { print("Popup was dismissed") }
    func configurePopup(config: TopPopupConfig) -> TopPopupConfig { config
        .heightMode(.auto)
        .cornerRadius(44)
        .dragDetents([.fraction(1.2), .fraction(1.4), .large])
    }
    var body: some View {
        Text("Hello Kitty")
    }
 }
 ```
 ![TopPopup](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/top-popup.png?raw=true)
*/
public protocol TopPopup: Popup { associatedtype Config = TopPopupConfig }

/**
 The view to be displayed as a Centre popup.
 
 # Optional Methods
 - ``Popup/configurePopup(config:)-3ze4``
 - ``Popup/onFocus()-loq5``
 - ``Popup/onDismiss()-3bufs``
 
 # Usage Example
 ```swift
 struct CenterPopupExample: CenterPopup {
    func onFocus() { print("Popup is now active") }
    func onDismiss() { print("Popup was dismissed") }
    func configurePopup(config: CenterPopupConfig) -> CenterPopupConfig { config
        .cornerRadius(44)
        .tapOutsideToDismissPopup(true)
    }
    var body: some View {
        Text("Hello Kitty")
    }
 }
 ```
 ![CenterPopup](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/centre-popup.png?raw=true)
 */
public protocol CenterPopup: Popup { associatedtype Config = CenterPopupConfig }

/**
 The view to be displayed as a Bottom popup.
 
 # Optional Methods
 - ``Popup/configurePopup(config:)-98ha0``
 - ``Popup/onFocus()-loq5``
 - ``Popup/onDismiss()-254h8``
 
 # Usage Example
 ```swift
 struct BottomPopupExample: BottomPopup {
    func onFocus() { print("Popup is now active") }
    func onDismiss() { print("Popup was dismissed") }
    func configurePopup(config: BottomPopupConfig) -> BottomPopupConfig { config
        .heightMode(.auto)
        .cornerRadius(44)
        .dragDetents([.fraction(1.2), .fraction(1.4), .large])
    }
    var body: some View {
        Text("Hello Kitty")
    }
 }
 ```
 ![BottomPopup](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/bottom-popup.png?raw=true)
 */
public protocol BottomPopup: Popup { associatedtype Config = BottomPopupConfig }
