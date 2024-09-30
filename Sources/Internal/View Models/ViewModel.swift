//
//  ViewModel.swift of MijickPopups
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import SwiftUI

class ViewModel<Config: LocalConfig>: ObservableObject {
    private(set) var allPopups: [AnyPopup] = []
    private(set) var popups: [AnyPopup] = []

    private(set) var activePopupHeight: CGFloat? = nil
    private(set) var screen: ScreenProperties = .init()
    private(set) var isKeyboardActive: Bool = false

    private var updatePopupAction: ((AnyPopup) -> ())!
    private var closePopupAction: ((AnyPopup) -> ())!


    // MARK: Methods to Override
    func recalculateAndSave(height: CGFloat, for popup: AnyPopup) { fatalError() }
    func calculateHeightForActivePopup() -> CGFloat? { fatalError() }
    func calculatePopupPadding() -> EdgeInsets { fatalError() }
    func calculateCornerRadius() -> [VerticalEdge: CGFloat] { fatalError() }
    func calculateVerticalFixedSize(for popup: AnyPopup) -> Bool { fatalError() }
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
    func updatePopupsValue(_ newPopups: [AnyPopup]) {
        allPopups = newPopups
        popups = newPopups.filter { $0.config is Config }
        activePopupHeight = calculateHeightForActivePopup()

        Task { @MainActor in withAnimation(.transition) { objectWillChange.send() }}
    }
    func updateScreenValue(_ newScreen: ScreenProperties) {
        screen = newScreen

        Task { @MainActor in withAnimation(.transition) { objectWillChange.send() }}
    }
    func updateKeyboardValue(_ isActive: Bool) {
        isKeyboardActive = isActive

        Task { @MainActor in withAnimation(.transition) { objectWillChange.send() }}
    }
    func updatePopup(_ popup: AnyPopup, by popupUpdateBuilder: @escaping (inout AnyPopup) -> ()) {
        var popup = popup
        popupUpdateBuilder(&popup)

        Task { @MainActor in updatePopupAction(popup) }
    }
}

// MARK: View Methods
extension ViewModel {
    func calculateZIndex(for popup: AnyPopup?) -> CGFloat {
        guard let popup,
              let index = allPopups.firstIndex(of: popup)
        else { return 2137 }

        return .init(index + 2)
    }
}

// MARK: Helpers
extension ViewModel {
    func updateHeight(_ newHeight: CGFloat, _ popup: AnyPopup) { if popup.height != newHeight {
        updatePopup(popup) { $0.height = newHeight }
    }}
}
extension ViewModel {
    func getConfig(_ item: AnyPopup?) -> Config {
        let config = item?.config as? Config
        return config ?? .init()
    }
    func getActivePopupConfig() -> Config {
        getConfig(popups.last)
    }
}

// MARK: Tests
#if DEBUG
extension ViewModel { struct TestHook {
    let target: ViewModel
}}
extension ViewModel {
    var testHook: TestHook { .init(target: self) }
}
#endif
