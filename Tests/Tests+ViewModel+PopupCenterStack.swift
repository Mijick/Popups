//
//  Tests+ViewModel+PopupCenterStack.swift of MijickPopups
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

@MainActor final class PopupCenterStackViewModelTests: XCTestCase {
    @ObservedObject private var viewModel: ViewModel = .init(CenterPopupConfig.self)

    override func setUp() async throws {
        viewModel.updateScreenValue(screen)
        viewModel.setup(updatePopupAction: { [self] in await updatePopupAction(viewModel, $0) }, closePopupAction: { [self] in await closePopupAction(viewModel, $0) })
    }
}
private extension PopupCenterStackViewModelTests {
    func updatePopupAction(_ viewModel: ViewModel, _ popup: AnyPopup) async { if let index = viewModel.popups.firstIndex(of: popup) {
        var popups = viewModel.popups
        popups[index] = popup

        await viewModel.updatePopups(popups)
    }}
    func closePopupAction(_ viewModel: ViewModel, _ popup: AnyPopup) async { if let index = viewModel.popups.firstIndex(of: popup) {
        var popups = viewModel.popups
        popups.remove(at: index)

        await viewModel.updatePopups(popups)
    }}
}



// MARK: - TEST CASES



// MARK: Outer Padding
extension PopupCenterStackViewModelTests {
    func test_calculateOuterPadding_withKeyboardHidden_whenCustomPaddingNotSet() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 350),
            createPopupInstanceForPopupHeightTests(popupHeight: 72),
            createPopupInstanceForPopupHeightTests(popupHeight: 400)
        ]

        await appendPopupsAndCheckOuterPadding(
            popups: popups,
            isKeyboardActive: false,
            expectedValue: .init()
        )
    }
    func test_calculateOuterPadding_withKeyboardHidden_whenCustomPaddingSet() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 350),
            createPopupInstanceForPopupHeightTests(popupHeight: 72, popupPadding: .init(top: 0, leading: 11, bottom: 0, trailing: 11)),
            createPopupInstanceForPopupHeightTests(popupHeight: 400, popupPadding: .init(top: 0, leading: 16, bottom: 0, trailing: 16))
        ]

        await appendPopupsAndCheckOuterPadding(
            popups: popups,
            isKeyboardActive: false,
            expectedValue: .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        )
    }
    func test_calculateOuterPadding_withKeyboardShown_whenKeyboardNotOverlapingPopup() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 350),
            createPopupInstanceForPopupHeightTests(popupHeight: 72, popupPadding: .init(top: 0, leading: 11, bottom: 0, trailing: 11)),
            createPopupInstanceForPopupHeightTests(popupHeight: 400, popupPadding: .init(top: 0, leading: 16, bottom: 0, trailing: 16))
        ]

        await appendPopupsAndCheckOuterPadding(
            popups: popups,
            isKeyboardActive: true,
            expectedValue: .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        )
    }
    func test_calculateOuterPadding_withKeyboardShown_whenKeyboardOverlapingPopup() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 350),
            createPopupInstanceForPopupHeightTests(popupHeight: 72, popupPadding: .init(top: 0, leading: 11, bottom: 0, trailing: 11)),
            createPopupInstanceForPopupHeightTests(popupHeight: 1000, popupPadding: .init(top: 0, leading: 16, bottom: 0, trailing: 16))
        ]

        await appendPopupsAndCheckOuterPadding(
            popups: popups,
            isKeyboardActive: true,
            expectedValue: .init(top: 0, leading: 16, bottom: 250, trailing: 16)
        )
    }
}
private extension PopupCenterStackViewModelTests {
    func appendPopupsAndCheckOuterPadding(popups: [AnyPopup], isKeyboardActive: Bool, expectedValue: EdgeInsets) async {
        await appendPopupsAndPerformChecks(
            popups: popups,
            isKeyboardActive: isKeyboardActive,
            calculatedValue: { await $0.calculateActivePopupOuterPadding() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Corner Radius
extension PopupCenterStackViewModelTests {
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
private extension PopupCenterStackViewModelTests {
    func appendPopupsAndCheckCornerRadius(popups: [AnyPopup], expectedValue: [MijickPopups.PopupAlignment: CGFloat]) async {
        await appendPopupsAndPerformChecks(
            popups: popups,
            isKeyboardActive: false,
            calculatedValue: { await $0.calculateActivePopupCorners() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Opacity
extension PopupCenterStackViewModelTests {
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
private extension PopupCenterStackViewModelTests {
    func appendPopupsAndCheckOpacity(popups: [AnyPopup], calculateForIndex index: Int, expectedValue: CGFloat) async {
        await appendPopupsAndPerformChecks(
            popups: popups,
            isKeyboardActive: false,
            calculatedValue: { [self] in $0.calculateOpacity(for: viewModel.popups[index]) },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Vertical Fixed Size
extension PopupCenterStackViewModelTests {
    func test_calculateVerticalFixedSize_withHeightSmallerThanScreen() async {
        let popups = [
            createPopupInstanceForPopupHeightTests(popupHeight: 350),
            createPopupInstanceForPopupHeightTests(popupHeight: 913),
            createPopupInstanceForPopupHeightTests(popupHeight: 400)
        ]

        await appendPopupsAndCheckVerticalFixedSize(
            popups: popups,
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
            expectedValue: false
        )
    }
}
private extension PopupCenterStackViewModelTests {
    func appendPopupsAndCheckVerticalFixedSize(popups: [AnyPopup], expectedValue: Bool) async {
        await appendPopupsAndPerformChecks(
            popups: popups,
            isKeyboardActive: false,
            calculatedValue: { await $0.calculateActivePopupVerticalFixedSize() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}



// MARK: - HELPERS



// MARK: Methods
private extension PopupCenterStackViewModelTests {
    func createPopupInstanceForPopupHeightTests(popupHeight: CGFloat, popupPadding: EdgeInsets = .init(), cornerRadius: CGFloat = 0) -> AnyPopup {
        let config = getConfigForPopupHeightTests(cornerRadius: cornerRadius, popupPadding: popupPadding)
        return AnyPopup.t_createNew(config: config).settingHeight(popupHeight)
    }
    func appendPopupsAndPerformChecks<Value: Equatable & Sendable>(popups: [AnyPopup], isKeyboardActive: Bool, calculatedValue: @escaping (ViewModel) async -> (Value), expectedValueBuilder: @escaping (ViewModel) async -> Value) async {
        await viewModel.updatePopups(popups)
        await updatePopups(viewModel)
        viewModel.updateKeyboardValue(isKeyboardActive)
        viewModel.updateScreenValue(isKeyboardActive ? screenWithKeyboard : screen)

        let calculatedValue = await calculatedValue(viewModel)
        let expectedValue = await expectedValueBuilder(viewModel)
        XCTAssertEqual(calculatedValue, expectedValue)
    }
}
private extension PopupCenterStackViewModelTests {
    func getConfigForPopupHeightTests(cornerRadius: CGFloat, popupPadding: EdgeInsets) -> CenterPopupConfig {
        var config = CenterPopupConfig()
        config.cornerRadius = cornerRadius
        config.popupPadding = popupPadding
        return config
    }
    func updatePopups(_ viewModel: ViewModel) async {
        for popup in viewModel.popups { await viewModel.updatePopupHeight(popup.height!, popup) }
    }
}

// MARK: Screen
private extension PopupCenterStackViewModelTests {
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
private extension PopupCenterStackViewModelTests {
    typealias ViewModel = VM.CenterStack
}
