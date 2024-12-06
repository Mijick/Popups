//
//  PopupView.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

// MARK: - iOS / macOS Implementation
#if os(iOS) || os(macOS) || os(visionOS) || os(watchOS)
struct PopupView: View {
    let globalConfig: GlobalConfig
    @State private var zIndex: ZIndex = .init()
    @ObservedObject private var popupManager: PopupManager = .shared


    var body: some View { createBody() }
}

// MARK: - tvOS Implementation
#elseif os(tvOS)
struct PopupView: View {
    let rootView: any View
    let globalConfig: GlobalConfig
    @State private var zIndex: ZIndex = .init()
    @ObservedObject private var popupManager: PopupManager = .shared


    var body: some View {
        AnyView(rootView)
            .disabled(!popupManager.views.isEmpty)
            .overlay(createBody())
    }
}
#endif


// MARK: - Common Part
private extension PopupView {
    func createBody() -> some View {
        createPopupStackView()
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .animation(stackAnimation, value: popupManager.views.map(\.id))
            .onChange(popupManager.views.count, completion: onViewsCountChange)
    }
}

private extension PopupView {
    func createPopupStackView() -> some View {
        ZStack {
            createTopPopupStackView()
            createCentrePopupStackView()
            createBottomPopupStackView()
        }
    }
}

private extension PopupView {
    func createTopPopupStackView() -> some View {
        PopupTopStackView(
            items: getViews(AnyPopup<TopPopupConfig>.self),
            globalConfig: globalConfig,
            enable: $popupManager.enable
        )
            .addOverlay(overlayColour, isOverlayActive(AnyPopup<TopPopupConfig>.self))
            .zIndex(zIndex.top)
    }
    func createCentrePopupStackView() -> some View {
        PopupCentreStackView(items: getViews(AnyPopup<CentrePopupConfig>.self), globalConfig: globalConfig)
            .addOverlay(overlayColour, isOverlayActive(AnyPopup<CentrePopupConfig>.self))
            .zIndex(zIndex.centre)
    }
    func createBottomPopupStackView() -> some View {
        PopupBottomStackView(
            items: getViews(AnyPopup<BottomPopupConfig>.self),
            globalConfig: globalConfig,
            enable: $popupManager.enable
        )
            .addOverlay(overlayColour, isOverlayActive(AnyPopup<BottomPopupConfig>.self))
            .zIndex(zIndex.bottom)
    }
}
private extension PopupView {
    func getViews<T: Popup>(_ type: T.Type) -> [T] { popupManager.views.compactMap { $0 as? T } }
}

private extension PopupView {
    func onViewsCountChange(_ count: Int) { DispatchQueue.main.asyncAfter(deadline: .now() + (!popupManager.presenting && zIndex.centre == 3 ? 0.4 : 0)) {
        zIndex.reshuffle(popupManager.views.last)
    }}
}

private extension PopupView {
    func isOverlayActive<P: Popup>(_ type: P.Type) -> Bool { popupManager.views.last is P && !shouldOverlayBeHiddenForCurrentPopup }
}
private extension PopupView {
    var shouldOverlayBeHiddenForCurrentPopup: Bool { popupManager.popupsWithoutOverlay.contains(popupManager.views.last?.id ?? .init()) }
}

private extension PopupView {
    var stackAnimation: Animation { popupManager.presenting ? globalConfig.common.animation.entry : globalConfig.common.animation.removal }
    var overlayColour: Color { globalConfig.common.overlayColour }
}


// MARK: - Counting zIndexes
// Purpose: To ensure that the stacks are displayed in the correct order
// Example: There are three bottom popups on the screen, and the user wants to display the centre one - to make sure they are displayed in the right order, we need to count the indexes; otherwise centre popup would be hidden by the bottom three.
extension PopupView { struct ZIndex {
    private var values: [Double] = [1, 1, 1]
}}
extension PopupView.ZIndex {
    mutating func reshuffle(_ lastPopup: (any Popup)?) { if let lastPopup {
        if lastPopup is AnyPopup<TopPopupConfig> { reshuffle(0) }
        else if lastPopup is AnyPopup<CentrePopupConfig> { reshuffle(1) }
        else if lastPopup is AnyPopup<BottomPopupConfig> { reshuffle(2) }
    }}
}
private extension PopupView.ZIndex {
    mutating func reshuffle(_ index: Int) { if values[index] != 3 {
        values.enumerated().forEach {
            values[$0.offset] = $0.offset == index ? 3 : max(1, $0.element - 1)
        }
    }}
}
private extension PopupView.ZIndex {
    var top: Double { values[0] }
    var centre: Double { values[1] }
    var bottom: Double { values[2] }
}


// MARK: - Helpers
fileprivate extension View {
    func addOverlay(_ colour: Color, _ active: Bool) -> some View { ZStack {
        colour.active(if: active)
        self
    }}
}
