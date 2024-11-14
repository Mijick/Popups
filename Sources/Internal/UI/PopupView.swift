//
//  PopupView.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2023 Mijick. All rights reserved.


import SwiftUI

struct PopupView: View {
    #if os(tvOS)
    let rootView: any View
    #endif

    @ObservedObject var stack: PopupStack
    private let topStackViewModel: VM.VerticalStack = .init(TopPopupConfig.self)
    private let centreStackViewModel: VM.CenterStack = .init(CenterPopupConfig.self)
    private let bottomStackViewModel: VM.VerticalStack = .init(BottomPopupConfig.self)


    var body: some View {
        #if os(tvOS)
        AnyView(rootView)
            .disabled(!stack.popups.isEmpty)
            .overlay(createBody())
        #else
        createBody()
        #endif
    }
}
private extension PopupView {
    func createBody() -> some View {
        GeometryReader { reader in
            createPopupStackView()
                .ignoresSafeArea()
                .onAppear { onScreenChange(reader) }
                .onChange(of: reader.size) { _ in onScreenChange(reader) }
        }
        .onAppear(perform: onAppear)
        .onChange(of: stack.popups.map { [$0.height, $0.dragHeight] }, perform: onPopupsHeightChange)
        .onChange(of: stack.popups) { [oldValue = stack.popups] newValue in onStackChange(oldValue, newValue) }
        .onKeyboardStateChange(perform: onKeyboardStateChange)
    }
}
private extension PopupView {
    func createPopupStackView() -> some View {
        ZStack {
            createOverlayView()
            createTopPopupStackView()
            createCentrePopupStackView()
            createBottomPopupStackView()
        }
    }
}
private extension PopupView {
    func createOverlayView() -> some View {
        getOverlayColor()
            .zIndex(stack.priority.overlay)
            .animation(.linear, value: stack.popups)
            .onTapGesture(perform: onTap)
    }
    func createTopPopupStackView() -> some View {
        PopupVerticalStackView(viewModel: topStackViewModel).zIndex(stack.priority.top)
    }
    func createCentrePopupStackView() -> some View {
        PopupCenterStackView(viewModel: centreStackViewModel).zIndex(stack.priority.center)
    }
    func createBottomPopupStackView() -> some View {
        PopupVerticalStackView(viewModel: bottomStackViewModel).zIndex(stack.priority.bottom)
    }
}
private extension PopupView {
    func getOverlayColor() -> Color { switch stack.popups.last?.config.overlayColor {
        case .some(let color) where color == .clear: .black.opacity(0.0000000000001)
        case .some(let color): color
        case nil: .clear
    }}
}

private extension PopupView {
    func onAppear() { Task { @MainActor in
        await updateViewModels { $0.setup(updatePopupAction: updatePopup, closePopupAction: closePopup) }
    }}
    func onScreenChange(_ screenReader: GeometryProxy) { Task { @MainActor in
        await updateViewModels { await $0.updateScreen(screenReader: screenReader) }
    }}
    func onPopupsHeightChange(_ p: Any) { Task { @MainActor in
        await updateViewModels { await $0.updatePopups(stack.popups) }
    }}
    func onStackChange(_ oldStack: [AnyPopup], _ newStack: [AnyPopup]) {
        newStack
            .difference(from: oldStack)
            .forEach { switch $0 {
                case .remove(_, let element, _): element.onDismiss()
                default: return
            }}
        newStack.last?.onFocus()
    }
    func onKeyboardStateChange(_ isKeyboardActive: Bool) { Task { @MainActor in
        await updateViewModels { await $0.updateScreen(isKeyboardActive: isKeyboardActive) }
    }}
    func onTap() { if tapOutsideClosesPopup {
        stack.modify(.removeLastPopup)
    }}
}
private extension PopupView {
    nonisolated func updatePopup(_ popup: AnyPopup) async {
        await stack.update(popup: popup)
    }
    nonisolated func closePopup(_ popup: AnyPopup) async {
        await stack.modify(.removePopup(popup))
    }
    func updateViewModels(_ updateBuilder: @escaping (any ViewModel) async -> ()) async {
        for viewModel in [topStackViewModel, centreStackViewModel, bottomStackViewModel] { Task { @MainActor in await updateBuilder(viewModel as! any ViewModel) }}
    }
}
private extension PopupView {
    var tapOutsideClosesPopup: Bool { stack.popups.last?.config.isTapOutsideToDismissEnabled ?? false }
}
