//
//  View++.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: fulcrumone@icloud.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

public extension View {
    func openFromBottom(configBuilder: (inout PopupBottomStackView.Config) -> ()) {
        let popUp = AnyPopup(id: String(describing: self)) { self }
        PopupManager.shared.openFromBottom(view: popUp, configBuilder: configBuilder)
    }
   func setupPopUpPresenting() -> some View {
        return ZStack {
            self
            if let item = PopupManager.shared.popUpStack?.content() { item }
        }
    }
}

// MARK: -Alignments
extension View {
    func alignToBottom(_ value: CGFloat = 0) -> some View {
        VStack(spacing: 0) {
            Spacer()
            self
            Spacer.height(value)
        }
    }
    func alignToTop(_ value: CGFloat = 0) -> some View {
        VStack(spacing: 0) {
            Spacer.height(value)
            self
            Spacer()
        }
    }
}

// MARK: -Content Height Reader
extension View {
    func readHeight(onChange action: @escaping (CGFloat) -> ()) -> some View {
        background(heightReader).onPreferenceChange(HeightPreferenceKey.self, perform: action)
    }
}
private extension View {
    var heightReader: some View { GeometryReader {
        Color.clear.preference(key: HeightPreferenceKey.self, value: $0.size.height)
    }}
}
fileprivate struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

// MARK: -Others
extension View {
    @ViewBuilder func active(if condition: Bool) -> some View {
        if condition { self }
    }
}
