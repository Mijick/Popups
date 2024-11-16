//
//  PopupCenterStackView.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2023 Mijick. All rights reserved.


import SwiftUI

struct PopupCenterStackView: View {
    @ObservedObject var viewModel: VM.CenterStack

    
    var body: some View {
        ZStack(content: createPopupStack)
            .id(viewModel.popups.isEmpty)
            .transition(transition)
            .frame(maxWidth: .infinity, maxHeight: viewModel.screen.height)
    }
}
private extension PopupCenterStackView {
    func createPopupStack() -> some View {
        ForEach(viewModel.popups, id: \.self, content: createPopup)
    }
}
private extension PopupCenterStackView {
    func createPopup(_ popup: AnyPopup) -> some View {
        popup.body
            .compositingGroup()
            .fixedSize(horizontal: false, vertical: viewModel.activePopupProperties.verticalFixedSize)
            .onHeightChange { await viewModel.updatePopupHeight($0, popup) }
            .frame(height: viewModel.activePopupProperties.height)
            .frame(maxWidth: .infinity, maxHeight: viewModel.activePopupProperties.height)
            .background(backgroundColor: getBackgroundColor(for: popup), overlayColor: .clear, corners: viewModel.activePopupProperties.corners)
            .opacity(viewModel.calculateOpacity(for: popup))
            .focusSection_tvOS()
            .padding(viewModel.activePopupProperties.outerPadding)
    }
}

private extension PopupCenterStackView {
    func getBackgroundColor(for popup: AnyPopup) -> Color { popup.config.backgroundColor }
}
private extension PopupCenterStackView {
    var transition: AnyTransition { .scale(scale: 1.1).combined(with: .opacity) }
}
