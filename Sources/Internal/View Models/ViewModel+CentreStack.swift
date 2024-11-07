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
    override func recalculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat { await recalculatePopupHeight(heightCandidate) }
    override func calculateHeightForActivePopup() -> CGFloat? { _calculateHeightForActivePopup() }
    override func calculatePopupPadding() -> EdgeInsets { _calculatePopupPadding() }
    override func calculateCornerRadius() -> [PopupAlignment : CGFloat] { _calculateCornerRadius() }
    override func calculateVerticalFixedSize(for popup: AnyPopup) -> Bool { _calculateVerticalFixedSize(for: popup) }
}}



// MARK: - VIEW METHODS



// MARK: Recalculate Popup Height
private extension VM.CentreStack {
    nonisolated func recalculatePopupHeight(_ heightCandidate: CGFloat) async -> CGFloat {
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
    func _calculatePopupPadding() -> EdgeInsets { .init(
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
    func _calculateCornerRadius() -> [PopupAlignment : CGFloat] {[
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
private extension VM.CentreStack {
    func _calculateVerticalFixedSize(for popup: AnyPopup) -> Bool {
        activePopupHeight != calculateLargeScreenHeight()
    }
}



// MARK: - HELPERS



// MARK: Active Popup Height
private extension VM.CentreStack {
    func _calculateHeightForActivePopup() -> CGFloat? {
        popups.last?.height
    }
}



// MARK: - TESTS
#if DEBUG



// MARK: Methods
extension VM.CentreStack {
    func t_calculateHeight(heightCandidate: CGFloat) -> CGFloat { recalculatePopupHeight(heightCandidate) }
    func t_calculatePopupPadding() -> EdgeInsets { calculatePopupPadding() }
    func t_calculateCornerRadius() -> [PopupAlignment: CGFloat] { calculateCornerRadius() }
    func t_calculateOpacity(for popup: AnyPopup) -> CGFloat { calculateOpacity(for: popup) }
    func t_calculateVerticalFixedSize(for popup: AnyPopup) -> Bool { calculateVerticalFixedSize(for: popup) }
}
#endif
