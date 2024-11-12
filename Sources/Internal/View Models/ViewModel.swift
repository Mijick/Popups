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
import Combine

enum VM {}
protocol ViewModel: ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher { init()
    // MARK: Attributes
    var alignment: PopupAlignment { get set }
    var popups: [AnyPopup] { get set }
    var activePopup: ActivePopup { get set }
    var screen: Screen { get set }

    // MARK: Actions
    var updatePopupAction: ((AnyPopup) async -> ())! { get set }
    var closePopupAction: ((AnyPopup) async -> ())! { get set }

    // MARK: Methods
    func calculateActivePopupHeight() async -> CGFloat?
    func calculateActivePopupInnerPadding() async -> EdgeInsets
    func calculateActivePopupOuterPadding() async -> EdgeInsets
    func calculateActivePopupCorners() async -> [PopupAlignment: CGFloat]
    func calculateActivePopupVerticalFixedSize() async -> Bool
    func calculateActivePopupTranslationProgress() async -> CGFloat
    func calculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat
}

// MARK: Initializer
extension ViewModel {
    init<Config: LocalConfig>(_ config: Config.Type) { self.init(); self.alignment = .init(Config.self) }
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
    @MainActor func updatePopupsValue(_ newPopups: [AnyPopup]) async { Task { @MainActor in
        popups = await filterPopups(newPopups)

        activePopup.outerPadding = await calculateActivePopupOuterPadding()
        activePopup.height = await calculateActivePopupHeight()
        activePopup.innerPadding = await calculateActivePopupInnerPadding()
        activePopup.corners = await calculateActivePopupCorners()
        activePopup.verticalFixedSize = await calculateActivePopupVerticalFixedSize()

        withAnimation(.transition) { objectWillChange.send() }
    }}
    @MainActor func updateScreenValue(screenReader: GeometryProxy? = nil, isKeyboardActive: Bool? = nil) async { Task { @MainActor in
        screen.update(screenReader: screenReader, isKeyboardActive: isKeyboardActive)
        activePopup.outerPadding = await calculateActivePopupOuterPadding()
        activePopup.innerPadding = await calculateActivePopupInnerPadding()

        withAnimation(.transition) { objectWillChange.send() }
    }}
    @MainActor func recalculateAndUpdatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async { Task { @MainActor in
        guard activePopup.gestureTranslation == 0 else { return }

        let newHeight = await calculatePopupHeight(heightCandidate, popup)
        guard newHeight != popup.height else { return }

        await updatePopupAction(popup.updatedHeight(newHeight))
    }}
    @MainActor func updateGestureTranslation(_ newGestureTranslation: CGFloat) async { Task { @MainActor in
        activePopup.gestureTranslation = newGestureTranslation
        activePopup.translationProgress = await calculateActivePopupTranslationProgress()
        activePopup.height = await calculateActivePopupHeight()

        withAnimation(activePopup.gestureTranslation == 0 ? .transition : nil) { objectWillChange.send() }
    }}
}
private extension ViewModel {
    func filterPopups(_ popups: [AnyPopup]) async -> [AnyPopup] {
        popups.filter { $0.config.alignment == alignment }
    }
}










@MainActor class ActivePopup {
    var height: CGFloat? = nil
    var innerPadding: EdgeInsets = .init()
    var outerPadding: EdgeInsets = .init()
    var corners: [PopupAlignment: CGFloat] = [.top: 0, .bottom: 0]
    var verticalFixedSize: Bool = true
    var gestureTranslation: CGFloat = 0
    var translationProgress: CGFloat = 0
}
