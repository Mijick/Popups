//
//  PopupCentreStackView.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

struct PopupCentreStackView: View {
    let items: [AnyPopup<CentrePopupConfig>]
    @State private var activeView: AnyView?
    @State private var configTemp: CentrePopupConfig?
    @State private var height: CGFloat?
    @State private var contentIsAnimated: Bool = false


    var body: some View {
        createPopup()
            .frame(width: UIScreen.width, height: UIScreen.height)
            .background(createTapArea())
            .animation(transitionAnimation, value: height)
            .animation(transitionAnimation, value: contentIsAnimated)
            .transition(getTransition())
            .onChange(of: items, perform: onItemsChange)
    }
}

private extension PopupCentreStackView {
    func createPopup() -> some View {
        activeView?
            .readHeight(onChange: saveHeight)
            .frame(width: width, height: height)
            .opacity(contentOpacity)
            .background(backgroundColour)
            .cornerRadius(cornerRadius)
    }
    func createTapArea() -> some View {
        Color.black.opacity(0.00000000001)
            .onTapGesture(perform: items.last?.dismiss ?? {})
            .active(if: config.tapOutsideClosesView)
    }
}

// MARK: -Logic Handlers
private extension PopupCentreStackView {
    func onItemsChange(_ items: [AnyPopup<CentrePopupConfig>]) {
        if let item = items.last {


            DispatchQueue.main.async {
                activeView = AnyView(item.body)
                configTemp = item.configurePopup(popup: .init())
            }







            guard height != nil else {  return }

            contentIsAnimated = true
            DispatchQueue.main.asyncAfter(deadline: .now() + contentOpacityAnimationTime) { contentIsAnimated = false }



        } else {
            //height = nil
            activeView = nil
        }
    }
}

// MARK: -View Handlers
private extension PopupCentreStackView {
    func saveHeight(_ value: CGFloat) { height = items.isEmpty ? nil : value }
    func getTransition() -> AnyTransition {
        .scale(scale: items.isEmpty ? config.exitScale : config.entryScale)
        .combined(with: .opacity)
        .animation(height == nil || items.isEmpty ? transitionAnimation : nil)
    }
}

private extension PopupCentreStackView {
    var width: CGFloat { max(0, UIScreen.width - config.horizontalPadding * 2) }
    var cornerRadius: CGFloat { config.cornerRadius }
    var contentOpacity: CGFloat { contentIsAnimated ? 0 : 1 }
    var contentOpacityAnimationTime: CGFloat { 0.1 }
    var backgroundColour: Color { config.backgroundColour }
    var transitionAnimation: Animation { config.transitionAnimation }
    var config: CentrePopupConfig { items.last?.configurePopup(popup: .init()) ?? configTemp ?? .init() }
}
