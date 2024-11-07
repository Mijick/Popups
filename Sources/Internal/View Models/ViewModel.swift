//
//  ViewModel.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

enum VM {}
@MainActor class ViewModel: ObservableObject {
    // MARK: Attributes
    private(set) var alignment: PopupAlignment
    private(set) var popups: [AnyPopup] = []
    private(set) var updatePopupAction: ((AnyPopup) -> ())!
    private(set) var closePopupAction: ((AnyPopup) -> ())!

    // MARK: Subclass Attributes
    var activePopupHeight: CGFloat? = nil
    var screen: Screen = .init()
    var isKeyboardActive: Bool = false

    // MARK: Methods to Override
    nonisolated func recalculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat { fatalError() }
    nonisolated func calculateHeightForActivePopup() async -> CGFloat? { fatalError() }

    // MARK: Initializer
    init<Config: LocalConfig>(_ config: Config.Type) { self.alignment = .init(Config.self) }
}

// MARK: Setup
extension ViewModel {
    func setup(updatePopupAction: @escaping (AnyPopup) -> (), closePopupAction: @escaping (AnyPopup) -> ()) {
        self.updatePopupAction = updatePopupAction
        self.closePopupAction = closePopupAction
    }
}

// MARK: Update
extension ViewModel {
    func updatePopupsValue(_ newPopups: [AnyPopup]) { Task {
        popups = newPopups.filter { $0.config.alignment == alignment }
        await activePopupHeight = calculateHeightForActivePopup()

        withAnimation(.transition) { objectWillChange.send() }
    }}
    func updateScreenValue(_ newScreen: Screen) {
        screen = newScreen

        withAnimation(.transition) { objectWillChange.send() }
    }
    func updateKeyboardValue(_ isActive: Bool) {
        isKeyboardActive = isActive

        withAnimation(.transition) { objectWillChange.send() }
    }
    func recalculateAndUpdatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) { Task {
        let recalculatedPopupHeight = await recalculatePopupHeight(heightCandidate, popup)
        if popup.height != recalculatedPopupHeight { updatePopupAction(popup.settingHeight(recalculatedPopupHeight)) }
    }}
}

// MARK: Helpers
extension ViewModel {
    func getActivePopupConfig() -> AnyPopupConfig {
        popups.last?.config ?? .init()
    }
}



// MARK: - TESTS
#if DEBUG



// MARK: Methods
extension ViewModel {
    func t_setup(updatePopupAction: @escaping (AnyPopup) -> (), closePopupAction: @escaping (AnyPopup) -> ()) { setup(updatePopupAction: updatePopupAction, closePopupAction: closePopupAction) }
    func t_updatePopupsValue(_ newPopups: [AnyPopup]) { updatePopupsValue(newPopups) }
    func t_updateScreenValue(_ newScreen: Screen) { updateScreenValue(newScreen) }
    func t_updateKeyboardValue(_ isActive: Bool) { updateKeyboardValue(isActive) }
    func t_updatePopup(_ popup: AnyPopup) { updatePopupAction(popup) }
    func t_calculateAndUpdateActivePopupHeight() { Task { activePopupHeight = await calculateHeightForActivePopup() }}
}

// MARK: Variables
extension ViewModel {
    var t_popups: [AnyPopup] { popups }
    var t_activePopupHeight: CGFloat? { activePopupHeight }
}
#endif
