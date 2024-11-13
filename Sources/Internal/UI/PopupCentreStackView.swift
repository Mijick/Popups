//
//  PopupCentreStackView.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2023 Mijick. All rights reserved.


import SwiftUI

struct PopupCentreStackView: View {
    @ObservedObject var viewModel: VM.CentreStack

    
    var body: some View {
        ZStack(content: createPopupStack)
            .id(viewModel.popups.isEmpty)
            .transition(transition)
            .frame(maxWidth: .infinity, maxHeight: viewModel.screen.height)
    }
}
private extension PopupCentreStackView {
    func createPopupStack() -> some View {
        ForEach(viewModel.popups, id: \.self, content: createPopup)
    }
}
private extension PopupCentreStackView {
    func createPopup(_ popup: AnyPopup) -> some View {
        popup.body
            .fixedSize(horizontal: false, vertical: viewModel.activePopup.verticalFixedSize)
            .onHeightChange { await viewModel.updatePopupHeight($0, popup) }
            .frame(height: viewModel.activePopup.height)
            .frame(maxWidth: .infinity, maxHeight: viewModel.activePopup.height)
            .background(backgroundColor: getBackgroundColor(for: popup), overlayColor: .clear, corners: viewModel.activePopup.corners)
            .opacity(viewModel.calculateOpacity(for: popup))
            .focusSection_tvOS()
            .padding(viewModel.activePopup.outerPadding)
            .compositingGroup()
    }
}

private extension PopupCentreStackView {
    func getBackgroundColor(for popup: AnyPopup) -> Color { popup.config.backgroundColor }
}
private extension PopupCentreStackView {
    var transition: AnyTransition { .scale(scale: 1.1).combined(with: .opacity) }
}
