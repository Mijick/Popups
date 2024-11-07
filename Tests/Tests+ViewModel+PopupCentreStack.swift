//
//  Tests+ViewModel+PopupCentreStack.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import XCTest
import SwiftUI
@testable import MijickPopups

@MainActor final class PopupCentreStackViewModelTests: XCTestCase {
    @ObservedObject private var viewModel: ViewModel = .init(CentrePopupConfig.self)

    override func setUp() async throws {
        viewModel.updateScreenValue(screen)
        viewModel.setup(updatePopupAction: { [self] in await updatePopupAction(viewModel, $0) }, closePopupAction: { [self] in await closePopupAction(viewModel, $0) })
    }
}
private extension PopupCentreStackViewModelTests {
    func updatePopupAction(_ viewModel: ViewModel, _ popup: AnyPopup) async { if let index = viewModel.popups.firstIndex(of: popup) {
        var popups = viewModel.popups
        popups[index] = popup

        await viewModel.updatePopupsValue(popups)
        await viewModel.t_calculateAndUpdateActivePopupHeight()
    }}
    func closePopupAction(_ viewModel: ViewModel, _ popup: AnyPopup) async { if let index = viewModel.popups.firstIndex(of: popup) {
        var popups = viewModel.popups
        popups.remove(at: index)

        await viewModel.updatePopupsValue(popups)
    }}
}



// MARK: - TEST CASES



// MARK: Popup Padding
extension PopupCentreStackViewModelTests {
    func test_calculatePopupPadding_withKeyboardHidden_whenCustomPaddingNotSet() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 350),
            createPopupInstanceForPopupHeightTests(popupHeight: 72),
            createPopupInstanceForPopupHeightTests(popupHeight: 400)
        ]

        await appendPopupsAndCheckPopupPadding(
            popups: popups,
            isKeyboardActive: false,
            expectedValue: .init()
        )
    }
    func test_calculatePopupPadding_withKeyboardHidden_whenCustomPaddingSet() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 350),
            createPopupInstanceForPopupHeightTests(popupHeight: 72, popupPadding: .init(top: 0, leading: 11, bottom: 0, trailing: 11)),
            createPopupInstanceForPopupHeightTests(popupHeight: 400, popupPadding: .init(top: 0, leading: 16, bottom: 0, trailing: 16))
        ]

        await appendPopupsAndCheckPopupPadding(
            popups: popups,
            isKeyboardActive: false,
            expectedValue: .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        )
    }
    func test_calculatePopupPadding_withKeyboardShown_whenKeyboardNotOverlapingPopup() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 350),
            createPopupInstanceForPopupHeightTests(popupHeight: 72, popupPadding: .init(top: 0, leading: 11, bottom: 0, trailing: 11)),
            createPopupInstanceForPopupHeightTests(popupHeight: 400, popupPadding: .init(top: 0, leading: 16, bottom: 0, trailing: 16))
        ]

        await appendPopupsAndCheckPopupPadding(
            popups: popups,
            isKeyboardActive: true,
            expectedValue: .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        )
    }
    func test_calculatePopupPadding_withKeyboardShown_whenKeyboardOverlapingPopup() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 350),
            createPopupInstanceForPopupHeightTests(popupHeight: 72, popupPadding: .init(top: 0, leading: 11, bottom: 0, trailing: 11)),
            createPopupInstanceForPopupHeightTests(popupHeight: 1000, popupPadding: .init(top: 0, leading: 16, bottom: 0, trailing: 16))
        ]

        await appendPopupsAndCheckPopupPadding(
            popups: popups,
            isKeyboardActive: true,
            expectedValue: .init(top: 0, leading: 16, bottom: 250, trailing: 16)
        )
    }
}
private extension PopupCentreStackViewModelTests {
    func appendPopupsAndCheckPopupPadding(popups: [AnyPopup], isKeyboardActive: Bool, expectedValue: EdgeInsets) async {
        await appendPopupsAndPerformChecks(
            popups: popups,
            isKeyboardActive: isKeyboardActive,
            calculatedValue: { $0.t_calculatePopupPadding() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Corner Radius
extension PopupCentreStackViewModelTests {
    func test_calculateCornerRadius_withCornerRadiusZero() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 234, cornerRadius: 20),
            createPopupInstanceForPopupHeightTests(popupHeight: 234, cornerRadius: 0),
        ]

        await appendPopupsAndCheckCornerRadius(
            popups: popups,
            expectedValue: [.top: 0, .bottom: 0]
        )
    }
    func test_calculateCornerRadius_withCornerRadiusNonZero() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 234, cornerRadius: 20),
            createPopupInstanceForPopupHeightTests(popupHeight: 234, cornerRadius: 24),
        ]

        await appendPopupsAndCheckCornerRadius(
            popups: popups,
            expectedValue: [.top: 24, .bottom: 24]
        )
    }
}
private extension PopupCentreStackViewModelTests {
    func appendPopupsAndCheckCornerRadius(popups: [AnyPopup], expectedValue: [MijickPopups.PopupAlignment: CGFloat]) async {
        await appendPopupsAndPerformChecks(
            popups: popups,
            isKeyboardActive: false,
            calculatedValue: { $0.t_calculateCornerRadius() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Opacity
extension PopupCentreStackViewModelTests {
    func test_calculatePopupOpacity_1() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 350),
            createPopupInstanceForPopupHeightTests(popupHeight: 72),
            createPopupInstanceForPopupHeightTests(popupHeight: 400)
        ]

        await appendPopupsAndCheckOpacity(
            popups: popups,
            calculateForIndex: 1,
            expectedValue: 0
        )
    }
    func test_calculatePopupOpacity_2() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 350),
            createPopupInstanceForPopupHeightTests(popupHeight: 72),
            createPopupInstanceForPopupHeightTests(popupHeight: 400)
        ]

        await appendPopupsAndCheckOpacity(
            popups: popups,
            calculateForIndex: 2,
            expectedValue: 1
        )
    }
}
private extension PopupCentreStackViewModelTests {
    func appendPopupsAndCheckOpacity(popups: [AnyPopup], calculateForIndex index: Int, expectedValue: CGFloat) async {
        await appendPopupsAndPerformChecks(
            popups: popups,
            isKeyboardActive: false,
            calculatedValue: { [self] in $0.t_calculateOpacity(for: viewModel.popups[index]) },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Vertical Fixed Size
extension PopupCentreStackViewModelTests {
    func test_calculateVerticalFixedSize_withHeightSmallerThanScreen() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 350),
            createPopupInstanceForPopupHeightTests(popupHeight: 913),
            createPopupInstanceForPopupHeightTests(popupHeight: 400)
        ]

        await appendPopupsAndCheckVerticalFixedSize(
            popups: popups,
            calculateForIndex: 2,
            expectedValue: true
        )
    }
    func test_calculateVerticalFixedSize_withHeightLargerThanScreen() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 350),
            createPopupInstanceForPopupHeightTests(popupHeight: 72),
            createPopupInstanceForPopupHeightTests(popupHeight: 913)
        ]

        await appendPopupsAndCheckVerticalFixedSize(
            popups: popups,
            calculateForIndex: 2,
            expectedValue: false
        )
    }
}
private extension PopupCentreStackViewModelTests {
    func appendPopupsAndCheckVerticalFixedSize(popups: [AnyPopup], calculateForIndex index: Int, expectedValue: Bool) async {
        await appendPopupsAndPerformChecks(
            popups: popups,
            isKeyboardActive: false,
            calculatedValue: { $0.t_calculateVerticalFixedSize(for: $0.popups[index]) },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}



// MARK: - HELPERS



// MARK: Methods
private extension PopupCentreStackViewModelTests {
    func createPopupInstanceForPopupHeightTests(popupHeight: CGFloat, popupPadding: EdgeInsets = .init(), cornerRadius: CGFloat = 0) -> AnyPopup {
        let config = getConfigForPopupHeightTests(cornerRadius: cornerRadius, popupPadding: popupPadding)
        return AnyPopup.t_createNew(config: config).settingHeight(popupHeight)
    }
    func appendPopupsAndPerformChecks<Value: Equatable>(popups: [AnyPopup], isKeyboardActive: Bool, calculatedValue: @escaping (ViewModel) -> (Value), expectedValueBuilder: @escaping (ViewModel) -> Value) async {
        await viewModel.updatePopupsValue(popups)
        await viewModel.updatePopupsValue(recalculatePopupHeights(viewModel))
        viewModel.updateKeyboardValue(isKeyboardActive)
        viewModel.updateScreenValue(isKeyboardActive ? screenWithKeyboard : screen)

        XCTAssertEqual(calculatedValue(viewModel), expectedValueBuilder(viewModel))
    }
}
private extension PopupCentreStackViewModelTests {
    func getConfigForPopupHeightTests(cornerRadius: CGFloat, popupPadding: EdgeInsets) -> CentrePopupConfig { .t_createNew(
        popupPadding: popupPadding,
        cornerRadius: cornerRadius
    )}
    func recalculatePopupHeights(_ viewModel: ViewModel) -> [AnyPopup] { viewModel.popups.map {
        $0.settingHeight(viewModel.t_calculateHeight(heightCandidate: $0.height!))
    }}
}

// MARK: Screen
private extension PopupCentreStackViewModelTests {
    var screen: Screen { .init(
        height: 1000,
        safeArea: .init(top: 100, leading: 20, bottom: 50, trailing: 30)
    )}
    var screenWithKeyboard: Screen { .init(
        height: 1000,
        safeArea: .init(top: 100, leading: 20, bottom: 200, trailing: 30)
    )}
}

// MARK: Typealiases
private extension PopupCentreStackViewModelTests {
    typealias ViewModel = VM.CentreStack
}
