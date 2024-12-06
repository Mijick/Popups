//
//  PopupCentreStackView.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

struct PopupCentreStackView: PopupStack {
    let items: [AnyPopup<CentrePopupConfig>]
    let globalConfig: GlobalConfig
    @ObservedObject private var screen: ScreenManager = .shared
    @ObservedObject private var keyboardManager: KeyboardManager = .shared
    @State private var activeView: AnyView?
    @State private var configTemp: CentrePopupConfig?
    @State private var height: CGFloat?
    @State private var contentIsAnimated: Bool = false

    
    var body: some View {
        createPopup()
            .align(to: .bottom, keyboardManager.height == 0 ? nil : keyboardManager.height)
            .frame(height: screen.size.height)
            .background(createTapArea())
            .animation(transitionEntryAnimation, value: lastPopupConfig.horizontalPadding)
            .animation(height == nil ? transitionRemovalAnimation : transitionEntryAnimation, value: height)
            .animation(transitionEntryAnimation, value: contentIsAnimated)
            .animation(.keyboard, value: keyboardManager.height)
            .transition(getTransition())
            .onChange(of: items, perform: onItemsChange)
    }
}

private extension PopupCentreStackView {
    @ViewBuilder func createPopup() -> some View {
        if #available(iOS 15, *) { createPopupForNewPlatforms() }
        else { createPopupForOlderPlatforms() }
    }
}

private extension PopupCentreStackView {
    func createPopupForNewPlatforms() -> some View {
        HStack(spacing: 0) {
            Spacer().frame(width: lastPopupConfig.horizontalPadding)
            activeView?
                .readHeight(onChange: saveHeight)
                .frame(height: height).frame(maxWidth: .infinity)
                .opacity(contentOpacity)
                .background(backgroundColour, overlayColour: .clear, radius: cornerRadius, corners: .allCorners, shadow: popupShadow)
                .compositingGroup()
                .focusSectionIfAvailable()
            Spacer().frame(width: lastPopupConfig.horizontalPadding)
        }
    }
    func createPopupForOlderPlatforms() -> some View {
        HStack(spacing: 0) {
            Spacer().frame(width: lastPopupConfig.horizontalPadding)
            items.last?.body
                .readHeight(onChange: saveHeight)
                .frame(height: height).frame(maxWidth: .infinity)
                .background(backgroundColour, overlayColour: .clear, radius: cornerRadius, corners: .allCorners, shadow: popupShadow)
                .compositingGroup()
                .focusSectionIfAvailable()
            Spacer().frame(width: lastPopupConfig.horizontalPadding)
        }
    }
}

// MARK: - Logic Modifiers
private extension PopupCentreStackView {
    func onItemsChange(_ items: [AnyPopup<CentrePopupConfig>]) {
        guard let popup = items.last else { return handleClosingPopup() }

        showNewPopup(popup)
        animateContentIfNeeded()
    }
}
private extension PopupCentreStackView {
    func showNewPopup(_ popup: AnyPopup<CentrePopupConfig>) { DispatchQueue.main.async {
        activeView = AnyView(popup.body)
        configTemp = popup.configurePopup(popup: .init())
    }}
    func animateContentIfNeeded() { if height != nil {
        contentIsAnimated = true
        DispatchQueue.main.asyncAfter(deadline: .now() + contentOpacityAnimationTime) { contentIsAnimated = false }
    }}
    func handleClosingPopup() { DispatchQueue.main.async {
        height = nil
        activeView = nil
    }}
}

// MARK: - View Modifiers
private extension PopupCentreStackView {
    func saveHeight(_ value: CGFloat) { height = items.isEmpty ? nil : value }
    func getTransition() -> AnyTransition {
        .scale(scale: items.isEmpty ? globalConfig.centre.transitionExitScale : globalConfig.centre.transitionEntryScale)
        .combined(with: .opacity)
        .animation(height == nil || items.isEmpty ? transitionRemovalAnimation : nil)
    }
}

// MARK: - Flags & Values
extension PopupCentreStackView {
    var cornerRadius: CGFloat { lastPopupConfig.cornerRadius ?? globalConfig.centre.cornerRadius }
    var contentOpacity: CGFloat { contentIsAnimated ? 0 : 1 }
    var popupShadow: Shadow { globalConfig.centre.shadow }
    var contentOpacityAnimationTime: CGFloat { globalConfig.centre.contentAnimationTime }
    var backgroundColour: Color { lastPopupConfig.backgroundColour ?? globalConfig.centre.backgroundColour }

    var tapOutsideClosesPopup: Bool { lastPopupConfig.tapOutsideClosesView ?? globalConfig.bottom.tapOutsideClosesView }
}
