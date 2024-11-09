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
protocol ViewModel: ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    // MARK: Attributes
    var alignment: PopupAlignment { get set }
    var popups: [AnyPopup] { get set }
    var gestureTranslation: CGFloat { get set }
    var translationProgress: CGFloat { get set }
    var activePopup: ActivePopup { get set }
    var screen: Screen { get set }

    // MARK: Actions
    var updatePopupAction: ((AnyPopup) async -> ())! { get set }
    var closePopupAction: ((AnyPopup) async -> ())! { get set }

    // MARK: Initializers
    init()
    init<Config: LocalConfig>(_ config: Config.Type)

    // MARK: Methods
    func calculateActivePopupHeight() async -> CGFloat?
    func calculateActivePopupInnerPadding() async -> EdgeInsets
    func calculateActivePopupOuterPadding() async -> EdgeInsets
    func calculateActivePopupCorners() async -> [PopupAlignment: CGFloat]
    func calculateActivePopupVerticalFixedSize() async -> Bool

    func calculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat
    func calculateTranslationProgress() async -> CGFloat
}

// MARK: Setup
extension VV {
    func setup(updatePopupAction: @escaping (AnyPopup) async -> (), closePopupAction: @escaping (AnyPopup) async -> ()) {
        self.updatePopupAction = updatePopupAction
        self.closePopupAction = closePopupAction
    }
}

// MARK: Update
extension VV {
    @MainActor func updatePopupsValue(_ newPopups: [AnyPopup]) async { Task { @MainActor in
        popups = await filterPopups(newPopups)

        activePopup.outerPadding = await calculateActivePopupOuterPadding()
        activePopup.height = await calculateActivePopupHeight()
        activePopup.innerPadding = await calculateActivePopupInnerPadding()
        activePopup.corners = await calculateActivePopupCorners()
        activePopup.verticalFixedSize = await calculateActivePopupVerticalFixedSize()

        withAnimation(.transition) { objectWillChange.send() }
    }}
    @MainActor func updateScreenValue(_ screenReader: GeometryProxy) async { Task { @MainActor in
        screen.update(screenReader)
        activePopup.outerPadding = await calculateActivePopupOuterPadding()
        activePopup.innerPadding = await calculateActivePopupInnerPadding()

        withAnimation(.transition) { objectWillChange.send() }
    }}
    @MainActor func updateKeyboardValue(_ isActive: Bool) async { Task { @MainActor in
        screen.isKeyboardActive = isActive
        activePopup.outerPadding = await calculateActivePopupOuterPadding()
        activePopup.innerPadding = await calculateActivePopupInnerPadding()

        withAnimation(.transition) { objectWillChange.send() }
    }}
    @MainActor func recalculateAndUpdatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async { Task { @MainActor in
        guard gestureTranslation == 0 else { return }


        var newPopup = popup
        newPopup.height = await calculatePopupHeight(heightCandidate, newPopup)

        guard newPopup.height != popup.height else { return }
        await updatePopupAction(newPopup)
    }}
    @MainActor func updateGestureTranslation(_ newGestureTranslation: CGFloat) async { Task { @MainActor in
        gestureTranslation = newGestureTranslation
        translationProgress = await calculateTranslationProgress()
        activePopup.height = await calculateActivePopupHeight()

        withAnimation(gestureTranslation == 0 ? .transition : nil) { objectWillChange.send() }
    }}
}
private extension VV {
    func filterPopups(_ popups: [AnyPopup]) async -> [AnyPopup] {
        popups.filter { $0.config.alignment == alignment }
    }
}




extension VV {
    init<Config: LocalConfig>(_ config: Config.Type) { self.init(); self.alignment = .init(Config.self) }
}





@MainActor class ActivePopup {
    var height: CGFloat? = nil
    var innerPadding: EdgeInsets = .init()
    var outerPadding: EdgeInsets = .init()
    var corners: [PopupAlignment: CGFloat] = [.top: 0, .bottom: 0]
    var verticalFixedSize: Bool = true
}
