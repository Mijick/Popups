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
    func calculateActivePopupOuterPadding() async -> EdgeInsets
    func calculateActivePopupInnerPadding() async -> EdgeInsets
    func calculateActivePopupCorners() async -> [PopupAlignment: CGFloat]
    func calculateActivePopupVerticalFixedSize() async -> Bool
    func calculateActivePopupTranslationProgress() async -> CGFloat
    func calculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat
}



// MARK: - INIT & SETUP



// MARK: Initialize
extension ViewModel {
    init<Config: LocalConfig>(_ config: Config.Type) { self.init(); self.alignment = .init(Config.self) }
}

// MARK: Setup
extension ViewModel {
    @MainActor func setup(updatePopupAction: @escaping (AnyPopup) async -> (), closePopupAction: @escaping (AnyPopup) async -> ()) {
        self.updatePopupAction = updatePopupAction
        self.closePopupAction = closePopupAction
    }
}



// MARK: MARK: UPDATE



// MARK: Popups
extension ViewModel {
    @MainActor func updatePopups(_ newPopups: [AnyPopup]) async { Task {
        popups = await filteredPopups(newPopups)
        await updateActivePopupProperties()

        withAnimation(.transition) { objectWillChange.send() }
    }}
}

// MARK: Screen
extension ViewModel {
}

// MARK: Gesture
extension ViewModel {

}

// MARK: Popup Height
extension ViewModel {

}

// MARK: Popup Drag Height
extension ViewModel {

}

// MARK: Helpers
private extension ViewModel {

}



// MARK: Update
extension ViewModel {

    @MainActor func updateScreenValue(screenReader: GeometryProxy? = nil, isKeyboardActive: Bool? = nil) async { Task { @MainActor in
        screen = await updatedScreenProperties(screenReader, isKeyboardActive)
        await updateActivePopupProperties()

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
    @MainActor func updateDragHeight(_ targetDragHeight: CGFloat, _ popup: AnyPopup) async {
        await updatePopupAction(popup.updatedDragHeight(targetDragHeight))
    }
}
private extension ViewModel {
    func filteredPopups(_ popups: [AnyPopup]) async -> [AnyPopup] {
        popups.filter { $0.config.alignment == alignment }
    }
    func updatedScreenProperties(_ screenReader: GeometryProxy?, _ isKeyboardActive: Bool?) async -> Screen {
        let height = if let screenReader { screenReader.size.height + screenReader.safeAreaInsets.top + screenReader.safeAreaInsets.bottom } else { screen.height },
            safeArea = screenReader?.safeAreaInsets ?? screen.safeArea,
            isKeyboardActive = isKeyboardActive ?? screen.isKeyboardActive
        return .init(height: height, safeArea: safeArea, isKeyboardActive: isKeyboardActive)
    }


    


    func updateActivePopupProperties() async {
        activePopup.height = await calculateActivePopupHeight()
        activePopup.outerPadding = await calculateActivePopupOuterPadding()
        activePopup.innerPadding = await calculateActivePopupInnerPadding()
        activePopup.corners = await calculateActivePopupCorners()
        activePopup.verticalFixedSize = await calculateActivePopupVerticalFixedSize()
    }
}








struct ActivePopup: Sendable {
    var height: CGFloat? = nil
    var innerPadding: EdgeInsets = .init()
    var outerPadding: EdgeInsets = .init()
    var corners: [PopupAlignment: CGFloat] = [.top: 0, .bottom: 0]
    var verticalFixedSize: Bool = true
    var gestureTranslation: CGFloat = 0
    var translationProgress: CGFloat = 0
}
