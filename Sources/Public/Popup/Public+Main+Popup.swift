//
//  Public+Main+Popup.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

/**
Blablabla




 # Usage Examples

 ## TopPopup
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

 ## CentrePopup
 ```swift
 struct CentrePopupExample: CentrePopup {
    func onFocus() { print("Popup is now active") }
    func onDismiss() { print("Popup was dismissed") }
    func configurePopup(config: CentrePopupConfig) -> CentrePopupConfig { config
        .cornerRadius(44)
        .tapOutsideToDismissPopup(true)
    }
    var body: some View {
        Text("Hello Kitty")
    }
 }
 ```
 ![CentrePopup](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/centre-popup.png?raw=true)

 ## BottomPopup
 ![BottomPopup](https://github.com/Mijick/Assets/blob/main/Framework%20Docs/Popups/bottom-popup.png?raw=true)
 */
public protocol Popup: View {
    associatedtype Config: LocalConfig

    func configurePopup(config: Config) -> Config
    func onFocus()
    func onDismiss()
}

// MARK: Default Methods Implementation
public extension Popup {
    func configurePopup(config: Config) -> Config { config }
    func onFocus() {}
    func onDismiss() {}
}

// MARK: Available Types
public protocol TopPopup: Popup { associatedtype Config = TopPopupConfig }
public protocol CentrePopup: Popup { associatedtype Config = CentrePopupConfig }
public protocol BottomPopup: Popup { associatedtype Config = BottomPopupConfig }
