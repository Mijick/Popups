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
    func onDragGesture(onChanged actionOnChanged: @escaping (DragGestureState) async -> (), onEnded actionOnEnded: @escaping (DragGestureState) async -> (), isEnabled: Bool) -> some View {
        #if os(tvOS)
        self
        #else
        simultaneousGesture(
            DragGesture()
                .onChanged { newValue in Task { @MainActor in await actionOnChanged(DragGestureState(newValue)) }}
                .onEnded { newValue in Task { @MainActor in await actionOnEnded(DragGestureState(newValue)) }},
            isEnabled: isEnabled
        )
        #endif
    }
}
