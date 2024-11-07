//
//  View+Gestures.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2023 Mijick. All rights reserved.


import SwiftUI

// MARK: On Tap Gesture
extension View {
    func onTapGesture(perform action: @escaping () -> ()) -> some View {
        #if os(tvOS)
        self
        #else
        onTapGesture(count: 1, perform: action)
        #endif
    }
}

// MARK: On Drag Gesture
extension View {
    func onDragGesture(onChanged actionOnChanged: @escaping (CGFloat) async -> (), onEnded actionOnEnded: @escaping (CGFloat) async -> (), isEnabled: Bool) -> some View {
        #if os(tvOS)
        self
        #else
        highPriorityGesture(
            DragGesture()
                .onChanged { newValue in Task { @MainActor in await actionOnChanged(newValue.translation.height) }}
                .onEnded { newValue in Task { @MainActor in await actionOnEnded(newValue.translation.height) }},
            isEnabled: isEnabled
        )
        #endif
    }
}
