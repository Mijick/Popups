//
//  Popup+Setup+PopupStackID.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


/**
 A set of identifiers to be registered.

 # Usage Example
 ```swift
 @main struct App_Main: App {
    var body: some Scene {
        Window("Window1", id: "Window1") {
            ContentView().registerPopups(id: .custom1)
        }
        Window("Window2", id: "Window2") {
            ContentView().registerPopups(id: .custom2)
        }
    }
 }

 extension PopupStackID {
    static let custom1: Self = .init(rawValue: "custom1")
    static let custom2: Self = .init(rawValue: "custom2")
 }
 ```

 - important: Use methods like ``SwiftUICore/View/dismissLastPopup(popupManagerID:)`` or ``Popup/present(popupManagerID:)`` only with a registered PopupStackID.
 - tip: The main use case where you might need to register a different PopupStackID is when your application has multiple windows - for example, on macOS, iPad or visionOS.
 */
public struct PopupStackID: Equatable, Sendable {
    let rawValue: String

    public init(rawValue: String) { self.rawValue = rawValue }
}

// MARK: Default Instance
public extension PopupStackID {
    static let shared: Self = .init(rawValue: "shared")
}
