//
//  ViewModel+CentreStack.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

extension VM { class CentreStack: ViewModel { required init() {}
    var alignment: PopupAlignment = .centre
    var popups: [AnyPopup] = []
    var activePopup: ActivePopup = .init()
    var screen: Screen = .init()
    var updatePopupAction: ((AnyPopup) async -> ())!
    var closePopupAction: ((AnyPopup) async -> ())!
}}



// MARK: - VIEW METHODS



// MARK: Popup Height
extension VM.CentreStack {
    func calculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat {
        min(heightCandidate, calculateLargeScreenHeight())
    }
}
private extension VM.CentreStack {
    func calculateLargeScreenHeight() -> CGFloat {
        let fullscreenHeight = screen.height,
            safeAreaHeight = screen.safeArea.top + screen.safeArea.bottom
        return fullscreenHeight - safeAreaHeight
    }
}

// MARK: Outer Padding
extension VM.CentreStack {
    func calculateActivePopupOuterPadding() async -> EdgeInsets { await .init(
        top: calculateVerticalPopupPadding(for: .top),
        leading: calculateLeadingPopupPadding(),
        bottom: calculateVerticalPopupPadding(for: .bottom),
        trailing: calculateTrailingPopupPadding()
    )}
}
private extension VM.CentreStack {
    func calculateVerticalPopupPadding(for edge: PopupAlignment) async -> CGFloat {
        guard let activePopupHeight = await activePopup.height,
              screen.isKeyboardActive && edge == .bottom
        else { return 0 }

        let remainingHeight = screen.height - activePopupHeight
        let paddingCandidate = (remainingHeight / 2 - screen.safeArea.bottom) * 2
        return abs(min(paddingCandidate, 0))
    }
    func calculateLeadingPopupPadding() -> CGFloat {
        popups.last?.config.popupPadding.leading ?? 0
    }
    func calculateTrailingPopupPadding() -> CGFloat {
        popups.last?.config.popupPadding.trailing ?? 0
    }
}

// MARK: Inner Padding
extension VM.CentreStack {
    func calculateActivePopupInnerPadding() async -> EdgeInsets { .init() }
}

// MARK: Corner Radius
extension VM.CentreStack {
    func calculateActivePopupCorners() async -> [PopupAlignment : CGFloat] { [
        .top: popups.last?.config.cornerRadius ?? 0,
        .bottom: popups.last?.config.cornerRadius ?? 0
    ]}
}

// MARK: Opacity
extension VM.CentreStack {
    func calculateOpacity(for popup: AnyPopup) -> CGFloat {
        popups.last == popup ? 1 : 0
    }
}

// MARK: Fixed Size
extension VM.CentreStack {
    func calculateActivePopupVerticalFixedSize() async -> Bool {
        await activePopup.height != calculateLargeScreenHeight()
    }
}

// MARK: Translation Progress
extension VM.CentreStack {
    func calculateActivePopupTranslationProgress() async -> CGFloat { 0 }
}

// MARK: Active Popup Height
extension VM.CentreStack {
    func calculateActivePopupHeight() async -> CGFloat? {
        popups.last?.height
    }
}
