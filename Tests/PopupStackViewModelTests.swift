//
//  PopupStackViewModelTests.swift of MijickPopups
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import XCTest
import SwiftUI
@testable import MijickPopups

final class PopupStackViewModelTests: XCTestCase {
    @ObservedObject private var viewModel: PopupStackView.ViewModel = .init(alignment: .bottom)


    override func setUpWithError() throws {
        viewModel.screen = screen
    }
}

// MARK: Calculating Popup Height
extension PopupStackViewModelTests {
    func test_calculatePopupHeight_withAutoHeightMode_whenLessThanScreen_onePopupStacked() {
        viewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 150)
        ]

        let calculatedPopupHeight = testHook.calculatePopupHeight(height: 150, popupConfig: viewModel.popups.last!.config as! Config)
        let expectedPopupHeight = 150.0
        XCTAssertEqual(calculatedPopupHeight, expectedPopupHeight)
    }
    func test_calculatePopupHeight_withAutoHeightMode_whenLessThanScreen_fourPopupsStacked() {
        let popup1 = createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 150)
        viewModel.popups = [popup1]




        let config = getConfigForPopupHeightTests(heightMode: .auto)

        testHook.calculatePopupHeight(height: 150, popupConfig: config)

        var popup = AnyPopup(config: config)
    }
    func test_calculatePopupHeight_withAutoHeightMode_whenBiggerThanScreen_onePopupStacked() {

    }
    func test_calculatePopupHeight_withAutoHeightMode_whenBiggerThanScreen_fivePopupStacked() {

    }
    func test_calculatePopupHeight_withLargeHeightMode_whenOnePopupStacked() {

    }
    func test_calculatePopupHeight_withLargeHeightMode_whenThreePopupStacked() {

    }
    func test_calculatePopupHeight_withFullscreenHeightMode_whenOnePopupStacked() {

    }
    func test_calculatePopupHeight_withFullscreenHeightMode_whenThreePopupsStacked() {

    }
}
private extension PopupStackViewModelTests {
    func createPopupInstanceForPopupHeightTests(heightMode: HeightMode, popupHeight: CGFloat) -> AnyPopup {
        let config = getConfigForPopupHeightTests(heightMode: heightMode)

        var popup = AnyPopup(config: config)
        popup.height = popupHeight
        return popup
    }
}
private extension PopupStackViewModelTests {
    func getConfigForPopupHeightTests(heightMode: HeightMode) -> Config { .init(
        ignoredSafeAreaEdges: [],
        heightMode: heightMode,
        popupPadding: (0, 0, 0),
        dragGestureEnabled: true,
        dragDetents: []
    )}
}



fileprivate typealias Config = LocalConfig.Vertical






private extension PopupStackViewModelTests {
    var testHook: PopupStackView<Config>.ViewModel.TestHook { viewModel.testHook }
}




// MARK: Helpers
private extension PopupStackViewModelTests {
    var screen: ScreenProperties { .init(
        height: 1000,
        safeArea: .init(top: 100, leading: 0, bottom: 50, trailing: 0)
    )}
}
