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

extension VM { class CentreStack: ViewModel {
    // MARK: Overridden Methods
    override func calculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat { await _calculatePopupHeight(heightCandidate) }
    override func calculatePopupPadding() async -> EdgeInsets { await _calculatePopupPadding() }
    override func calculateHeightForActivePopup() async -> CGFloat? { await _calculateHeightForActivePopup() }
    override func calculateCornerRadius() async -> [PopupAlignment: CGFloat] { await _calculateCornerRadius() }
}}



// MARK: - VIEW METHODS



// MARK: Popup Height
private extension VM.CentreStack {
    nonisolated func _calculatePopupHeight(_ heightCandidate: CGFloat) async -> CGFloat {
        await min(heightCandidate, calculateLargeScreenHeight())
    }
}
private extension VM.CentreStack {
    func calculateLargeScreenHeight() -> CGFloat {
        let fullscreenHeight = screen.height,
            safeAreaHeight = screen.safeArea.top + screen.safeArea.bottom
        return fullscreenHeight - safeAreaHeight
    }
}

// MARK: Popup Padding
private extension VM.CentreStack {
    nonisolated func _calculatePopupPadding() async -> EdgeInsets { await .init(
        top: calculateVerticalPopupPadding(for: .top),
        leading: calculateLeadingPopupPadding(),
        bottom: calculateVerticalPopupPadding(for: .bottom),
        trailing: calculateTrailingPopupPadding()
    )}
}
private extension VM.CentreStack {
    func calculateVerticalPopupPadding(for edge: PopupAlignment) -> CGFloat {
        guard let activePopupHeight,
              isKeyboardActive && edge == .bottom
        else { return 0 }

        let remainingHeight = screen.height - activePopupHeight
        let paddingCandidate = (remainingHeight / 2 - screen.safeArea.bottom) * 2
        return abs(min(paddingCandidate, 0))
    }
    func calculateLeadingPopupPadding() -> CGFloat {
        getActivePopupConfig().popupPadding.leading
    }
    func calculateTrailingPopupPadding() -> CGFloat {
        getActivePopupConfig().popupPadding.trailing
    }
}

// MARK: Corner Radius
private extension VM.CentreStack {
    nonisolated func _calculateCornerRadius() async -> [PopupAlignment : CGFloat] { await [
        .top: getActivePopupConfig().cornerRadius,
        .bottom: getActivePopupConfig().cornerRadius
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
    func calculateVerticalFixedSize(for popup: AnyPopup) -> Bool {
        activePopupHeight != calculateLargeScreenHeight()
    }
}



// MARK: - HELPERS



// MARK: Active Popup Height
private extension VM.CentreStack {
    nonisolated func _calculateHeightForActivePopup() async -> CGFloat? {
        await popups.last?.height
    }
}
