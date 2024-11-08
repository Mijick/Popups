//
//  PopupVerticalStackView.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

struct PopupVerticalStackView: View {
    @ObservedObject var viewModel: VM.VerticalStack


    var body: some View {
        ZStack(alignment: (!viewModel.alignment).toAlignment(), content: createPopupStack)
            .frame(height: viewModel.screen.height, alignment: viewModel.alignment.toAlignment())
            .onDragGesture(onChanged: viewModel.onPopupDragGestureChanged, onEnded: viewModel.onPopupDragGestureEnded, isEnabled: viewModel.dragGestureEnabled)
    }
}
private extension PopupVerticalStackView {
    func createPopupStack() -> some View {
        ForEach(viewModel.popups, id: \.self, content: createPopup)
    }
}
private extension PopupVerticalStackView {
    func createPopup(_ popup: AnyPopup) -> some View {
        popup.body
            .padding(viewModel.activePopupBodyPadding)
            .fixedSize(horizontal: false, vertical: viewModel.calculateVerticalFixedSize(for: popup))
            .onHeightChange { await viewModel.recalculateAndUpdatePopupHeight($0, popup) }
            .frame(height: viewModel.activePopupHeight, alignment: (!viewModel.alignment).toAlignment())
            .frame(maxWidth: .infinity, maxHeight: viewModel.activePopupHeight, alignment: (!viewModel.alignment).toAlignment())
            .background(backgroundColor: getBackgroundColor(for: popup), overlayColor: getStackOverlayColor(for: popup), corners: viewModel.activePopupCornerRadius)
            .offset(y: viewModel.calculateOffsetY(for: popup))
            .scaleEffect(x: viewModel.calculateScaleX(for: popup))
            .focusSection_tvOS()
            .padding(viewModel.activePopupPadding)
            .transition(transition)
            .zIndex(viewModel.calculateZIndex())
            .compositingGroup()
    }
}

private extension PopupVerticalStackView {
    func getBackgroundColor(for popup: AnyPopup) -> Color { popup.config.backgroundColor }
    func getStackOverlayColor(for popup: AnyPopup) -> Color { stackOverlayColor.opacity(viewModel.calculateStackOverlayOpacity(for: popup)) }
}
private extension PopupVerticalStackView {
    var stackOverlayColor: Color { .black }
    var transition: AnyTransition { .move(edge: viewModel.alignment.toEdge()) }
}
