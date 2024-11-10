//
//  View+Keyboard.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2023 Mijick. All rights reserved.


import SwiftUI
import Combine

// MARK: On Keyboard State Change
extension View {
    func onKeyboardStateChange(perform action: @escaping (Bool) -> ()) -> some View {
        #if os(iOS)
        onReceive(keyboardPublisher, perform: action)
        #else
        self
        #endif
    }
}
fileprivate extension View {
    #if os(iOS)
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }
    #endif
}

// MARK: Hide Keyboard
extension AnyView {
    nonisolated static func hideKeyboard() async {
        #if os(iOS)
        await UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #elseif os(macOS)
        await NSApp.keyWindow?.makeFirstResponder(nil)
        #endif
    }
}
