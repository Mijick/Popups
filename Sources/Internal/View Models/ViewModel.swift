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
@MainActor protocol ViewModel: ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher { init()
    // MARK: Attributes
    var alignment: PopupAlignment { get set }
    var popups: [AnyPopup] { get set }
    var activePopupProperties: ActivePopupProperties { get set }
    var screen: Screen { get set }

    // MARK: Actions
    var updatePopupAction: ((AnyPopup) async -> ())? { get set }
    var closePopupAction: ((AnyPopup) async -> ())? { get set }

    // MARK: Methods
    func calculateActivePopupHeight() async -> CGFloat?
    func calculateActivePopupOuterPadding() async -> EdgeInsets
    func calculateActivePopupInnerPadding() async -> EdgeInsets
    func calculateActivePopupCorners() async -> [PopupAlignment: CGFloat]
    func calculateActivePopupVerticalFixedSize() async -> Bool
    func calculateActivePopupTranslationProgress() async -> CGFloat
    func calculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat
}


// MARK: - INITIALIZE & SETUP



// MARK: Initialize
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


// MARK: UPDATE



// MARK: Popups
extension ViewModel {
    func updatePopups(_ newPopups: [AnyPopup]) async {
        popups = await filteredPopups(newPopups)
        await updateActivePopupProperties()

        withAnimation(.transition) { objectWillChange.send() }
    }
}

// MARK: Screen
extension ViewModel {
    func updateScreen(screenHeight: CGFloat? = nil, screenSafeArea: EdgeInsets? = nil, isKeyboardActive: Bool? = nil) async {
        screen = await updatedScreenProperties(screenHeight, screenSafeArea, isKeyboardActive)
        await updateActivePopupProperties()

        withAnimation(.transition) { objectWillChange.send() }
    }
}

// MARK: Gesture Translation
extension ViewModel {
    func updateGestureTranslation(_ newGestureTranslation: CGFloat) async {
        await updateActivePopupPropertiesOnGestureTranslationChange(newGestureTranslation)

        withAnimation(activePopupProperties.gestureTranslation == 0 ? .transition : nil) { objectWillChange.send() }
    }
}

// MARK: Popup Height
extension ViewModel {
    func updatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async {
        guard activePopupProperties.gestureTranslation == 0 else { return }

        let newHeight = await calculatePopupHeight(heightCandidate, popup)
        if newHeight != popup.height {
            await updatePopupAction?(popup.updatedHeight(newHeight))
        }
    }
}

// MARK: Popup Drag Height
extension ViewModel {
    func updatePopupDragHeight(_ targetDragHeight: CGFloat, _ popup: AnyPopup) async {
        await updatePopupAction?(popup.updatedDragHeight(targetDragHeight))
    }
}

// MARK: Helpers
private extension ViewModel {
    func filteredPopups(_ popups: [AnyPopup]) async -> [AnyPopup] {
        popups.filter { $0.config.alignment == alignment }
    }
    func updatedScreenProperties(_ screenHeight: CGFloat?, _ screenSafeArea: EdgeInsets?, _ isKeyboardActive: Bool?) async -> Screen { .init(
        height: screenHeight ?? screen.height,
        safeArea: screenSafeArea ?? screen.safeArea,
        isKeyboardActive: isKeyboardActive ?? screen.isKeyboardActive
    )}
}
private extension ViewModel {
    func updateActivePopupProperties() async {
        activePopupProperties.height = await calculateActivePopupHeight()
        activePopupProperties.outerPadding = await calculateActivePopupOuterPadding()
        activePopupProperties.innerPadding = await calculateActivePopupInnerPadding()
        activePopupProperties.corners = await calculateActivePopupCorners()
        activePopupProperties.verticalFixedSize = await calculateActivePopupVerticalFixedSize()
    }
    func updateActivePopupPropertiesOnGestureTranslationChange(_ newGestureTranslation: CGFloat) async {
        activePopupProperties.gestureTranslation = newGestureTranslation
        activePopupProperties.translationProgress = await calculateActivePopupTranslationProgress()
        activePopupProperties.height = await calculateActivePopupHeight()
    }
}
