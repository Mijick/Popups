//
//  Tests+ViewModel+PopupCentreStack.swift of MijickPopups
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import XCTest
import SwiftUI
import Combine
@testable import MijickPopups

final class PopupCentreStackViewModelTests: XCTestCase {
    @ObservedObject private var viewModel: ViewModel = .init()

    override func setUpWithError() throws {
        viewModel.t_updateScreenValue(screen)
        viewModel.t_setup(updatePopupAction: { [self] in updatePopupAction(viewModel, $0) }, closePopupAction: { [self] in closePopupAction(viewModel, $0) })
    }
}
private extension PopupCentreStackViewModelTests {
    func updatePopupAction(_ viewModel: ViewModel, _ popup: AnyPopup) { if let index = viewModel.popups.firstIndex(of: popup) {
        var popups = viewModel.popups
        popups[index] = popup

        viewModel.t_updatePopupsValue(popups)
        viewModel.t_calculateAndUpdateActivePopupHeight()
    }}
    func closePopupAction(_ viewModel: ViewModel, _ popup: AnyPopup) { if let index = viewModel.popups.firstIndex(of: popup) {
        var popups = viewModel.popups
        popups.remove(at: index)

        viewModel.t_updatePopupsValue(popups)
    }}
}



// MARK: - TEST CASES



// MARK: Popup Padding
extension PopupCentreStackViewModelTests {
    func test_calculatePopupPadding_() {
        
    }
}

// MARK: Corner Radius
extension PopupCentreStackViewModelTests {

}

// MARK: Opacity
extension PopupCentreStackViewModelTests {

}

// MARK: Vertical Fixed Size
extension PopupCentreStackViewModelTests {

}



// MARK: - HELPERS



// MARK: Methods
private extension PopupCentreStackViewModelTests {
    func createPopupInstanceForPopupHeightTests(popupHeight: CGFloat, popupPadding: EdgeInsets = .init(), cornerRadius: CGFloat = 0) -> AnyPopup {
        let config = getConfigForPopupHeightTests(cornerRadius: cornerRadius, popupPadding: popupPadding)

        var popup = AnyPopup(config: config)
        popup.height = popupHeight
        return popup
    }
}
private extension PopupCentreStackViewModelTests {
    func getConfigForPopupHeightTests(cornerRadius: CGFloat, popupPadding: EdgeInsets) -> Config { .init(
        cornerRadius: cornerRadius,
        popupPadding: popupPadding
    )}
}

// MARK: Screen
private extension PopupCentreStackViewModelTests {
    var screen: ScreenProperties { .init(
        height: 800,
        safeArea: .init(top: 100, leading: 20, bottom: 50, trailing: 30)
    )}
}

// MARK: Typealiases
private extension PopupCentreStackViewModelTests {
    typealias Config = LocalConfig.Centre
    typealias ViewModel = PopupCentreStackView.ViewModel
}
