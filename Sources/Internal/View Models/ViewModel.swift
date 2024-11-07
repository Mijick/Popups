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
    nonisolated let alignment: PopupAlignment
    private(set) var popups: [AnyPopup] = []
    private(set) var updatePopupAction: ((AnyPopup) async -> ())!
    private(set) var closePopupAction: ((AnyPopup) async -> ())!

    // MARK: Subclass Attributes
    var activePopupHeight: CGFloat? = nil
    var screen: Screen = .init()
    var isKeyboardActive: Bool = false

    // MARK: Methods to Override
    nonisolated func calculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat { fatalError() }
    nonisolated func calculatePopupPadding() async -> EdgeInsets { fatalError() }
    nonisolated func calculateHeightForActivePopup() async -> CGFloat? { fatalError() }
    nonisolated func recalculatePopupPadding() async -> EdgeInsets { fatalError() }

    // MARK: Initializer
    init<Config: LocalConfig>(_ config: Config.Type) { self.alignment = .init(Config.self) }
}

// MARK: Setup
extension ViewModel {
    func setup(updatePopupAction: @escaping (AnyPopup) async -> (), closePopupAction: @escaping (AnyPopup) async -> ()) {
        self.updatePopupAction = updatePopupAction
        self.closePopupAction = closePopupAction
    }
}

// MARK: Update
extension ViewModel {
    func updatePopupsValue(_ newPopups: [AnyPopup]) async {
        popups = await filterPopups(newPopups)
        activePopupHeight = await calculateHeightForActivePopup()

        withAnimation(.transition) { objectWillChange.send() }
    }
    func updateScreenValue(_ newScreen: Screen) {
        screen = newScreen

        withAnimation(.transition) { objectWillChange.send() }
    }
    func updateKeyboardValue(_ isActive: Bool) {
        isKeyboardActive = isActive

        withAnimation(.transition) { objectWillChange.send() }
    }
    func recalculateAndUpdatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async {
        var newPopup = popup
        newPopup.popupPadding = await calculatePopupPadding()
        newPopup.height = await calculatePopupHeight(heightCandidate, newPopup)

        await updatePopupAction(newPopup)
    }
}
private extension ViewModel {
    nonisolated func filterPopups(_ popups: [AnyPopup]) async -> [AnyPopup] {
        popups.filter { $0.config.alignment == alignment }
    }
}

// MARK: Helpers
extension ViewModel {
    func getActivePopupConfig() -> AnyPopupConfig {
        popups.last?.config ?? .init()
    }
}
