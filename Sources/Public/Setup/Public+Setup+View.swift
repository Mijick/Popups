//
//  Public+Setup+View.swift of MijickPopups
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
     Registers the framework to work in your application.

     - Parameters:
        - id: It is possible to register multiple stacks (for different windows); especially useful in a macOS or iPad implementation. Read more in ``PopupStackID``.
        - configBuilder: Default configuration for all popups. Use the ``Popup/configurePopup(config:)-98ha0`` method to change the configuration for a specific popup. See the list of available methods in ``GlobalConfig``.


     ## Usage
     ```swift
     @main struct App_Main: App {
        var body: some Scene { WindowGroup {
            ContentView()
                .registerPopups { config in config
                    .vertical { $0
                        .enableDragGesture(true)
                        .tapOutsideToDismissPopup(true)
                        .cornerRadius(32)
                    }
                    .center { $0
                        .tapOutsideToDismissPopup(false)
                        .backgroundColor(.white)
                    }
                }
        }}
     }
     ```

    - seealso: It's also possible to register the framework with ``PopupSceneDelegate``; useful if you want to use the library with Apple's default sheets.
     */
    func registerPopups(id: PopupStackID = .shared, configBuilder: @escaping (GlobalConfigContainer) -> GlobalConfigContainer = { $0 }) -> some View {
        #if os(tvOS)
        PopupView(rootView: self, stack: .registerStack(id: id)).onAppear { _ = configBuilder(.init()) }
        #else
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(PopupView(stack: .registerStack(id: id)), alignment: .top)
            .onAppear { _ = configBuilder(.init()) }
        #endif
    }
}
