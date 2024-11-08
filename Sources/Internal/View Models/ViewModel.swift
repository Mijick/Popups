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
    var gestureTranslation: CGFloat = 0
    var translationProgress: CGFloat = 0
    var activePopup: ActivePopup = .init()
    var screen: Screen = .init()
    var isKeyboardActive: Bool = false

    // MARK: Methods to Override
    nonisolated func calculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat { fatalError() }
    nonisolated func calculatePopupPadding() async -> EdgeInsets { fatalError() }
    nonisolated func calculateCornerRadius() async -> [PopupAlignment: CGFloat] { fatalError() }
    nonisolated func calculateHeightForActivePopup() async -> CGFloat? { fatalError() }
    nonisolated func calculateBodyPadding() async -> EdgeInsets { fatalError() }
    nonisolated func calculateTranslationProgress() async -> CGFloat { fatalError() }
    nonisolated func calculateVerticalFixedSize() async -> Bool { fatalError() }

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

        activePopup.outerPadding = await calculatePopupPadding()
        activePopup.height = await calculateHeightForActivePopup()
        activePopup.innerPadding = await calculateBodyPadding()
        activePopup.corners = await calculateCornerRadius()
        activePopup.verticalFixedSize = await calculateVerticalFixedSize()

        withAnimation(.transition) { objectWillChange.send() }
    }
    func updateScreenValue(_ newScreen: Screen) async {
        screen = newScreen
        activePopup.outerPadding = await calculatePopupPadding()
        activePopup.innerPadding = await calculateBodyPadding()

        withAnimation(.transition) { objectWillChange.send() }
    }
    func updateKeyboardValue(_ isActive: Bool) async {
        isKeyboardActive = isActive
        activePopup.outerPadding = await calculatePopupPadding()
        activePopup.innerPadding = await calculateBodyPadding()

        withAnimation(.transition) { objectWillChange.send() }
    }
    func recalculateAndUpdatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async {
        guard gestureTranslation == 0 else { return }


        var newPopup = popup
        newPopup.height = await calculatePopupHeight(heightCandidate, newPopup)

        guard newPopup.height != popup.height else { return }
        await updatePopupAction(newPopup)
    }
    func updateGestureTranslation(_ newGestureTranslation: CGFloat) async {
        gestureTranslation = newGestureTranslation
        translationProgress = await calculateTranslationProgress()
        activePopup.height = await calculateHeightForActivePopup()

        withAnimation(gestureTranslation == 0 ? .transition : nil) { objectWillChange.send() }
    }
}
private extension ViewModel {
    nonisolated func filterPopups(_ popups: [AnyPopup]) async -> [AnyPopup] {
        popups.filter { $0.config.alignment == alignment }
    }
}



protocol VV: ObservableObject {
    var alignment: PopupAlignment { get }
    var popups: [AnyPopup] { get }
    var updatePopupAction: ((AnyPopup) async -> ())! { get set }
    var closePopupAction: ((AnyPopup) async -> ())! { get set }
}





@MainActor class ActivePopup {
    var height: CGFloat? = nil
    var innerPadding: EdgeInsets = .init()
    var outerPadding: EdgeInsets = .init()
    var corners: [PopupAlignment: CGFloat] = [.top: 0, .bottom: 0]
    var verticalFixedSize: Bool = true
}
