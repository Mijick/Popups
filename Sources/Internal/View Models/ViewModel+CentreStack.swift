//
//  ViewModel+CenterStack.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

extension VM { class CenterStack: ViewModel { required init() {}
    var alignment: PopupAlignment = .center
    var popups: [AnyPopup] = []
    var activePopupProperties: ActivePopupProperties = .init()
    var screen: Screen = .init()
    var updatePopupAction: ((AnyPopup) async -> ())?
    var closePopupAction: ((AnyPopup) async -> ())?
}}


// MARK: - METHODS / VIEW MODEL / ACTIVE POPUP



// MARK: Height
extension VM.CenterStack {
    func calculateActivePopupHeight() async -> CGFloat? {
        popups.last?.height
    }
}

// MARK: Outer Padding
extension VM.CenterStack {
    func calculateActivePopupOuterPadding() async -> EdgeInsets { .init(
        top: calculateVerticalPopupPadding(for: .top),
        leading: calculateLeadingPopupPadding(),
        bottom: calculateVerticalPopupPadding(for: .bottom),
        trailing: calculateTrailingPopupPadding()
    )}
}
private extension VM.CenterStack {
    func calculateVerticalPopupPadding(for edge: PopupAlignment) -> CGFloat {
        guard let activePopupHeight = activePopupProperties.height, screen.isKeyboardActive && edge == .bottom else { return 0 }

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
extension VM.CenterStack {
    func calculateActivePopupInnerPadding() async -> EdgeInsets { .init() }
}

// MARK: Corners
extension VM.CenterStack {
    func calculateActivePopupCorners() async -> [PopupAlignment : CGFloat] { [
        .top: popups.last?.config.cornerRadius ?? 0,
        .bottom: popups.last?.config.cornerRadius ?? 0
    ]}
}

// MARK: Vertical Fixed Size
extension VM.CenterStack {
    func calculateActivePopupVerticalFixedSize() async -> Bool {
        activePopupProperties.height != calculateLargeScreenHeight()
    }
}

// MARK: Translation Progress
extension VM.CenterStack {
    func calculateActivePopupTranslationProgress() async -> CGFloat { 0 }
}


// MARK: - METHODS / VIEW MODEL / SELECTED POPUP



// MARK: Height
extension VM.CenterStack {
    func calculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat {
        min(heightCandidate, calculateLargeScreenHeight())
    }
}
private extension VM.CenterStack {
    func calculateLargeScreenHeight() -> CGFloat {
        let fullscreenHeight = screen.height,
            safeAreaHeight = screen.safeArea.top + screen.safeArea.bottom
        return fullscreenHeight - safeAreaHeight
    }
}


// MARK: - METHODS / VIEW



// MARK: Opacity
extension VM.CenterStack {
    func calculateOpacity(for popup: AnyPopup) -> CGFloat {
        popups.last == popup ? 1 : 0
    }
}
