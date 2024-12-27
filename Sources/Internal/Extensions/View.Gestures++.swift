//
//  View.Gestures++.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

// MARK: - iOS + macOS Implementation
#if os(iOS) || os(macOS) || os(visionOS) || os(watchOS)
extension View {
    func onTapGesture(perform action: @escaping () -> ()) -> some View { onTapGesture(count: 1, perform: action) }
    func onDragGesture(_ state: GestureState<Bool>,enable: Binding<Bool>, onChanged actionOnChanged: @escaping (CGFloat) -> (), onEnded actionOnEnded: @escaping (CGFloat) -> ()) -> some View {
//        simultaneousGesture(
//            enable.wrappedValue ? createDragGesture(
//                state,
//                actionOnChanged,
//                actionOnEnded
//            ) : nil
//        )
        simultaneousGesture(
            createDragGesture(
                state,
                actionOnChanged,
                actionOnEnded
            )
        )
        .onStateChange(state, actionOnEnded)
    }
}
private extension View {
    func createDragGesture(_ state: GestureState<Bool>, _ actionOnChanged: @escaping (CGFloat) -> (), _ actionOnEnded: @escaping (CGFloat) -> ()) -> some Gesture {
        DragGesture()
            .updating(state) { _, state, _ in state = true }
            .onChanged { actionOnChanged($0.translation.height) }
            .onEnded { actionOnEnded($0.translation.height) }
    }
    func onStateChange(_ state: GestureState<Bool>, _ actionOnEnded: @escaping (CGFloat) -> ()) -> some View {
    #if os(visionOS)
        onChange(of: state.wrappedValue) { state.wrappedValue ? () : actionOnEnded(.zero) }
    #else
        onChange(of: state.wrappedValue) { $0 ? () : actionOnEnded(.zero) }
    #endif
    }
}


// MARK: - tvOS Implementation
#elseif os(tvOS)
extension View {
    func onTapGesture(perform action: () -> ()) -> some View { self }
    func onDragGesture(onChanged actionOnChanged: (CGFloat) -> (), onEnded actionOnEnded: (CGFloat) -> ()) -> some View { self }
}
#endif
