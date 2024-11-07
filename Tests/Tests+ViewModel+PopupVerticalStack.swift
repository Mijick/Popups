//
//  Tests+ViewModel+PopupVerticalStack.swift of MijickPopups
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

@MainActor final class PopupVerticalStackViewModelTests: XCTestCase {
    @ObservedObject private var topViewModel: ViewModel = .init(TopPopupConfig.self)
    @ObservedObject private var bottomViewModel: ViewModel = .init(BottomPopupConfig.self)

    override func setUp() async throws {
        setup(topViewModel)
        setup(bottomViewModel)
    }
}
private extension PopupVerticalStackViewModelTests {
    func setup(_ viewModel: ViewModel) {
        viewModel.t_updateScreenValue(screen)
        viewModel.t_setup(updatePopupAction: { self.updatePopupAction(viewModel, $0) }, closePopupAction: { self.closePopupAction(viewModel, $0) })
    }
}
private extension PopupVerticalStackViewModelTests {
    func updatePopupAction(_ viewModel: ViewModel, _ popup: AnyPopup) { if let index = viewModel.t_popups.firstIndex(of: popup) {
        var popups = viewModel.t_popups
        popups[index] = popup

        viewModel.t_updatePopupsValue(popups)
        viewModel.t_calculateAndUpdateActivePopupHeight()
    }}
    func closePopupAction(_ viewModel: ViewModel, _ popup: AnyPopup) { if let index = viewModel.t_popups.firstIndex(of: popup) {
        var popups = viewModel.t_popups
        popups.remove(at: index)

        viewModel.t_updatePopupsValue(popups)
    }}
}



// MARK: - TEST CASES



// MARK: Inverted Index
extension PopupVerticalStackViewModelTests {
    func test_getInvertedIndex_1() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 150)
        ])

        XCTAssertEqual(
            bottomViewModel.t_getInvertedIndex(of: bottomViewModel.t_popups[0]),
            0
        )
    }
    func test_getInvertedIndex_2() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 150)
        ])

        XCTAssertEqual(
            bottomViewModel.t_getInvertedIndex(of: bottomViewModel.t_popups[3]),
            1
        )
    }
}

// MARK: Update Popup
extension PopupVerticalStackViewModelTests {
    func test_updatePopup_1() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 0)
        ]
        let updatedPopup = popups[0]
            .settingHeight(100)
            .settingDragHeight(100)

        appendPopupsAndCheckPopups(
            viewModel: bottomViewModel,
            popups: popups,
            updatedPopup: updatedPopup,
            expectedValue: (height: 100, dragHeight: 100)
        )
    }
    func test_updatePopup_2() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 50),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 25),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 15),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 2137)
        ]
        let updatedPopup = popups[2].settingHeight(1371)

        appendPopupsAndCheckPopups(
            viewModel: bottomViewModel,
            popups: popups,
            updatedPopup: updatedPopup,
            expectedValue: (height: 1371, dragHeight: nil)
        )
    }
    func test_updatePopup_3() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 50),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 25),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 15),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 2137),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 77)
        ]
        let updatedPopup = popups[4].settingHeight(nil)

        appendPopupsAndCheckPopups(
            viewModel: bottomViewModel,
            popups: popups,
            updatedPopup: updatedPopup,
            expectedValue: (height: nil, dragHeight: nil)
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckPopups(viewModel: ViewModel, popups: [AnyPopup], updatedPopup: AnyPopup, expectedValue: (height: CGFloat?, dragHeight: CGFloat?)) {
        viewModel.t_updatePopupsValue(popups)
        viewModel.t_updatePopup(updatedPopup)

        if let index = viewModel.t_popups.firstIndex(of: updatedPopup) {
            XCTAssertEqual(viewModel.t_popups[index].height, expectedValue.height)
            XCTAssertEqual(viewModel.t_popups[index].dragHeight, expectedValue.dragHeight)
        }
    }
}

// MARK: Popup Height
extension PopupVerticalStackViewModelTests {
    func test_calculatePopupHeight_withAutoHeightMode_whenLessThanScreen_onePopupStacked() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 150)
        ])

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            150.0
        )
    }
    func test_calculatePopupHeight_withAutoHeightMode_whenLessThanScreen_fourPopupsStacked() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 200),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 100)
        ])

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            100.0
        )
    }
    func test_calculatePopupHeight_withAutoHeightMode_whenBiggerThanScreen_onePopupStacked() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 2000)
        ])

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            screen.height - screen.safeArea.top
        )
    }
    func test_calculatePopupHeight_withAutoHeightMode_whenBiggerThanScreen_fivePopupStacked() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 200),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 2000)
        ])

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            screen.height - screen.safeArea.top - bottomViewModel.t_stackOffset * 4
        )
    }
    func test_calculatePopupHeight_withLargeHeightMode_whenOnePopupStacked() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .large, popupHeight: 100)
        ])

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            screen.height - screen.safeArea.top
        )
    }
    func test_calculatePopupHeight_withLargeHeightMode_whenThreePopupStacked() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .large, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .large, popupHeight: 700),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .large, popupHeight: 1000)
        ])

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            screen.height - screen.safeArea.top - bottomViewModel.t_stackOffset * 2
        )
    }
    func test_calculatePopupHeight_withFullscreenHeightMode_whenOnePopupStacked() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 100)
        ])

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            screen.height
        )
    }
    func test_calculatePopupHeight_withFullscreenHeightMode_whenThreePopupsStacked() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 2000),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 3000)
        ])

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            screen.height
        )
    }
    func test_calculatePopupHeight_withLargeHeightMode_whenThreePopupsStacked_popupPadding() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 2000),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .large, popupHeight: 3000, popupPadding: .init(top: 33, leading: 15, bottom: 21, trailing: 15))
        ])

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            screen.height - screen.safeArea.top - 2 * bottomViewModel.t_stackOffset
        )
    }
    func test_calculatePopupHeight_withFullscreenHeightMode_whenThreePopupsStacked_popupPadding() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 2000),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 3000, popupPadding: .init(top: 33, leading: 15, bottom: 21, trailing: 15))
        ])

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            screen.height
        )
    }
    func test_calculatePopupHeight_withLargeHeightMode_whenPopupsHaveTopAlignment() {
        topViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .large, popupHeight: 100)
        ])

        XCTAssertEqual(
            calculateLastPopupHeight(topViewModel),
            screen.height - screen.safeArea.bottom
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func calculateLastPopupHeight(_ viewModel: ViewModel) -> CGFloat {
        viewModel.t_calculateHeight(heightCandidate: viewModel.t_popups.last!.height!, popup: viewModel.t_popups.last!)
    }
}

// MARK: Active Popup Height
extension PopupVerticalStackViewModelTests {
    func test_calculateActivePopupHeight_withAutoHeightMode_whenLessThanScreen_onePopupStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 100)
        ]

        appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: 100
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenBiggerThanScreen_threePopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 3000),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1000),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 2000)
        ]

        appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: screen.height - screen.safeArea.top - 2 * bottomViewModel.t_stackOffset
        )
    }
    func test_calculateActivePopupHeight_withLargeHeightMode_whenThreePopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 1000),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .large, popupHeight: 2000)
        ]

        appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: screen.height - screen.safeArea.top - 2 * bottomViewModel.t_stackOffset
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenGestureIsNegative_twoPopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 2000)
        ]

        appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -51,
            expectedValue: screen.height - screen.safeArea.top - bottomViewModel.t_stackOffset * 1 + 51
        )
    }
    func test_calculateActivePopupHeight_withLargeHeightMode_whenGestureIsNegative_onePopupStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .large, popupHeight: 350)
        ]

        appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -99,
            expectedValue: screen.height - screen.safeArea.top + 99
        )
    }
    func test_calculateActivePopupHeight_withFullscreenHeightMode_whenGestureIsNegative_twoPopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 250)
        ]

        appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -21,
            expectedValue: screen.height
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenGestureIsPositive_threePopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .large, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 1000),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 850)
        ]

        appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 100,
            expectedValue: 850
        )
    }
    func test_calculateActivePopupHeight_withFullscreenHeightMode_whenGestureIsPositive_onePopupStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 350)
        ]

        appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 31,
            expectedValue: screen.height
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenGestureIsNegative_hasDragHeightStored_twoPopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 500, popupDragHeight: 100)
        ]

        appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -93,
            expectedValue: 500 + 100 + 93
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenGestureIsPositive_hasDragHeightStored_onePopupStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1300, popupDragHeight: 100)
        ]

        appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 350,
            expectedValue: screen.height - screen.safeArea.top
        )
    }
    func test_calculateActivePopupHeight_withPopupsHaveTopAlignment() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .large, popupHeight: 1300)
        ]

        appendPopupsAndCheckActivePopupHeight(
            viewModel: topViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: screen.height - screen.safeArea.bottom
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckActivePopupHeight(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: CGFloat) {
        appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { $0.t_activePopupHeight },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Offset
extension PopupVerticalStackViewModelTests {
    func test_calculateOffsetY_withZeroGestureTranslation_fivePopupsStacked_thirdElement() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 240),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 670),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 310)
        ])

        XCTAssertEqual(
            bottomViewModel.t_calculateOffsetY(for: bottomViewModel.t_popups[2]),
            -bottomViewModel.t_stackOffset * 2
        )
    }
    func test_calculateOffsetY_withZeroGestureTranslation_fivePopupsStacked_lastElement() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 240),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 670),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 310)
        ])

        XCTAssertEqual(
            bottomViewModel.t_calculateOffsetY(for: bottomViewModel.t_popups[4]),
            0
        )
    }
    func test_calculateOffsetY_withNegativeGestureTranslation_dragHeight_onePopupStacked() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 350, popupDragHeight: 100)
        ])
        bottomViewModel.t_updateGestureTranslation(-100)

        XCTAssertEqual(
            bottomViewModel.t_calculateOffsetY(for: bottomViewModel.t_popups[0]),
            0
        )
    }
    func test_calculateOffsetY_withPositiveGestureTranslation_dragHeight_twoPopupsStacked_firstElement() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 350, popupDragHeight: 249),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 133, popupDragHeight: 21)
        ])
        bottomViewModel.t_updateGestureTranslation(100)

        XCTAssertEqual(
            bottomViewModel.t_calculateOffsetY(for: bottomViewModel.t_popups[0]),
            -bottomViewModel.t_stackOffset
        )
    }
    func test_calculateOffsetY_withPositiveGestureTranslation_dragHeight_twoPopupsStacked_lastElement() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 350, popupDragHeight: 249),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 133, popupDragHeight: 21)
        ])
        bottomViewModel.t_updateGestureTranslation(100)

        XCTAssertEqual(
            bottomViewModel.t_calculateOffsetY(for: bottomViewModel.t_popups[1]),
            100 - 21
        )
    }
    func test_calculateOffsetY_withStackingDisabled() {
        bottomViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 350, popupDragHeight: 249),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 133, popupDragHeight: 21)
        ])
        GlobalConfigContainer.vertical.isStackingEnabled = false

        XCTAssertEqual(
            bottomViewModel.t_calculateOffsetY(for: bottomViewModel.t_popups[0]),
            0
        )
    }
    func test_calculateOffsetY_withPopupsHaveTopAlignment_1() {
        topViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 350, popupDragHeight: 249),
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 133, popupDragHeight: 21)
        ])

        XCTAssertEqual(
            topViewModel.t_calculateOffsetY(for: topViewModel.t_popups[0]),
            topViewModel.t_stackOffset
        )
    }
    func test_calculateOffsetY_withPopupsHaveTopAlignment_2() {
        topViewModel.t_updatePopupsValue([
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 350, popupDragHeight: 249),
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 133, popupDragHeight: 21)
        ])
        topViewModel.t_updateGestureTranslation(-100)

        XCTAssertEqual(
            topViewModel.t_calculateOffsetY(for: topViewModel.t_popups[1]),
            21 - 100
        )
    }
}

// MARK: Popup Padding
extension PopupVerticalStackViewModelTests {
    func test_calculatePopupPadding_withAutoHeightMode_whenLessThanScreen() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 344, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        appendPopupsAndCheckPopupPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 12, leading: 17, bottom: 33, trailing: 17)
        )
    }
    func test_calculatePopupPadding_withAutoHeightMode_almostLikeScreen_onlyOnePaddingShouldBeNonZero() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 877, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        appendPopupsAndCheckPopupPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 17, bottom: 23, trailing: 17)
        )
    }
    func test_calculatePopupPadding_withAutoHeightMode_almostLikeScreen_bothPaddingsShouldBeNonZero() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 861, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        appendPopupsAndCheckPopupPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 6, leading: 17, bottom: 33, trailing: 17)
        )
    }
    func test_calculatePopupPadding_withAutoHeightMode_almostLikeScreen_topPopupsAlignment() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 911, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        appendPopupsAndCheckPopupPadding(
            viewModel: topViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 12, leading: 17, bottom: 27, trailing: 17)
        )
    }
    func test_calculatePopupPadding_withAutoHeightMode_whenBiggerThanScreen() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1100, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        appendPopupsAndCheckPopupPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 17, bottom: 0, trailing: 17)
        )
    }
    func test_calculatePopupPadding_withLargeHeightMode() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .large, popupHeight: 344, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        appendPopupsAndCheckPopupPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 17, bottom: 0, trailing: 17)
        )
    }
    func test_calculatePopupPadding_withFullscreenHeightMode() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 344, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        appendPopupsAndCheckPopupPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 17, bottom: 0, trailing: 17)
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckPopupPadding(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: EdgeInsets) {
        appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { $0.t_calculatePopupPadding() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Body Padding
extension PopupVerticalStackViewModelTests {
    func test_calculateBodyPadding_withDefaultSettings() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 350)
        ]

        appendPopupsAndCheckBodyPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: screen.safeArea.top, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateBodyPadding_withIgnoringSafeArea_bottom() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 200, ignoredSafeAreaEdges: .bottom)
        ]

        appendPopupsAndCheckBodyPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: screen.safeArea.leading, bottom: 0, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateBodyPadding_withIgnoringSafeArea_all() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1200, ignoredSafeAreaEdges: .all)
        ]

        appendPopupsAndCheckBodyPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        )
    }
    func test_calculateBodyPadding_withPopupPadding() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1200, popupPadding: .init(top: 21, leading: 12, bottom: 37, trailing: 12))
        ]

        appendPopupsAndCheckBodyPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateBodyPadding_withFullscreenHeightMode_ignoringSafeArea_top() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 100, ignoredSafeAreaEdges: .top)
        ]

        appendPopupsAndCheckBodyPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateBodyPadding_withGestureTranslation() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 800)
        ]

        appendPopupsAndCheckBodyPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -300,
            expectedValue: .init(top: screen.safeArea.top, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateBodyPadding_withGestureTranslation_dragHeight() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300, popupDragHeight: 700)
        ]

        appendPopupsAndCheckBodyPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 21,
            expectedValue: .init(top: screen.safeArea.top - 21, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateBodyPadding_withGestureTranslation_dragHeight_topPopupsAlignment() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 300, popupDragHeight: 700)
        ]

        appendPopupsAndCheckBodyPadding(
            viewModel: topViewModel,
            popups: popups,
            gestureTranslation: -21,
            expectedValue: .init(top: screen.safeArea.top, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom - 21, trailing: screen.safeArea.trailing)
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckBodyPadding(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: EdgeInsets) {
        appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { $0.t_calculateBodyPadding(for: popups.last!) },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Translation Progress
extension PopupVerticalStackViewModelTests {
    func test_calculateTranslationProgress_withNoGestureTranslation() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300)
        ]

        appendPopupsAndCheckTranslationProgress(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: 0
        )
    }
    func test_calculateTranslationProgress_withPositiveGestureTranslation() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300)
        ]

        appendPopupsAndCheckTranslationProgress(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 250,
            expectedValue: 250 / 300
        )
    }
    func test_calculateTranslationProgress_withPositiveGestureTranslation_dragHeight() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300, popupDragHeight: 120)
        ]

        appendPopupsAndCheckTranslationProgress(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 250,
            expectedValue: (250 - 120) / 300
        )
    }
    func test_calculateTranslationProgress_withNegativeGestureTranslation() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300)
        ]

        appendPopupsAndCheckTranslationProgress(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -175,
            expectedValue: 0
        )
    }
    func test_calculateTranslationProgress_withNegativeGestureTranslation_whenTopPopupsAlignment() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 300)
        ]

        appendPopupsAndCheckTranslationProgress(
            viewModel: topViewModel,
            popups: popups,
            gestureTranslation: -175,
            expectedValue: 175 / 300
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckTranslationProgress(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: CGFloat) {
        appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { $0.t_calculateTranslationProgress() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Corner Radius
extension PopupVerticalStackViewModelTests {
    func test_calculateCornerRadius_withTwoPopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300, cornerRadius: 1),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300, cornerRadius: 12)
        ]

        appendPopupsAndCheckCornerRadius(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 12, .bottom: 0]
        )
    }
    func test_calculateCornerRadius_withPopupPadding_bottom_first() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300, popupPadding: .init(top: 0, leading: 0, bottom: 12, trailing: 0), cornerRadius: 1),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300, cornerRadius: 12)
        ]

        appendPopupsAndCheckCornerRadius(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 12, .bottom: 0]
        )
    }
    func test_calculateCornerRadius_withPopupPadding_bottom_last() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300, cornerRadius: 1),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300, popupPadding: .init(top: 0, leading: 0, bottom: 12, trailing: 0), cornerRadius: 12)
        ]

        appendPopupsAndCheckCornerRadius(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 12, .bottom: 12]
        )
    }
    func test_calculateCornerRadius_withPopupPadding_all() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300, cornerRadius: 1),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300, popupPadding: .init(top: 12, leading: 24, bottom: 12, trailing: 24), cornerRadius: 12)
        ]

        appendPopupsAndCheckCornerRadius(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 12, .bottom: 12]
        )
    }
    func test_calculateCornerRadius_fullscreen() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 300, cornerRadius: 13)
        ]

        appendPopupsAndCheckCornerRadius(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 0, .bottom: 0]
        )
    }
    func test_calculateCornerRadius_whenPopupsHaveTopAlignment() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 300, cornerRadius: 12)
        ]

        appendPopupsAndCheckCornerRadius(
            viewModel: topViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 0, .bottom: 12]
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckCornerRadius(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: [MijickPopups.PopupAlignment: CGFloat]) {
        appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { $0.t_calculateCornerRadius() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Scale X
extension PopupVerticalStackViewModelTests {
    func test_calculateScaleX_withNoGestureTranslation_threePopupsStacked_last() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 360)
        ]

        appendPopupsAndCheckScaleX(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 2,
            expectedValueBuilder: {_ in 1 }
        )
    }
    func test_calculateScaleX_withNoGestureTranslation_fourPopupsStacked_second() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 360),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1360)
        ]

        appendPopupsAndCheckScaleX(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 1,
            expectedValueBuilder: { 1 - $0.t_stackScaleFactor * 2 }
        )
    }
    func test_calculateScaleX_withNegativeGestureTranslation_fourPopupsStacked_third() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 360),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1360)
        ]

        appendPopupsAndCheckScaleX(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -100,
            calculateForIndex: 2,
            expectedValueBuilder: { 1 - $0.t_stackScaleFactor * 1 }
        )
    }
    func test_calculateScaleX_withPositiveGestureTranslation_fivePopupsStacked_second() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 360),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 123)
        ]

        appendPopupsAndCheckScaleX(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 100,
            calculateForIndex: 1,
            expectedValueBuilder: { 1 - $0.t_stackScaleFactor * 3 * max(1 - $0.t_calculateTranslationProgress(), $0.t_minScaleProgressMultiplier) }
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckScaleX(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, calculateForIndex index: Int, expectedValueBuilder: @escaping (ViewModel) -> CGFloat) {
        appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { $0.t_calculateScaleX(for: $0.t_popups[index]) },
            expectedValueBuilder: expectedValueBuilder
        )
    }
}

// MARK: Fixed Size
extension PopupVerticalStackViewModelTests {
    func test_calculateFixedSize_withAutoHeightMode_whenLessThanScreen_twoPopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 123)
        ]

        appendPopupsAndCheckVerticalFixedSize(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 1,
            expectedValue: true
        )
    }
    func test_calculateFixedSize_withAutoHeightMode_whenBiggerThanScreen_twoPopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1223)
        ]

        appendPopupsAndCheckVerticalFixedSize(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 1,
            expectedValue: false
        )
    }
    func test_calculateFixedSize_withLargeHeightMode_threePopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1223),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .large, popupHeight: 1223)
        ]

        appendPopupsAndCheckVerticalFixedSize(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 2,
            expectedValue: false
        )
    }
    func test_calculateFixedSize_withFullscreenHeightMode_fivePopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1223),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .large, popupHeight: 1223),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1223),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 1223)
        ]

        appendPopupsAndCheckVerticalFixedSize(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 4,
            expectedValue: false
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckVerticalFixedSize(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, calculateForIndex index: Int, expectedValue: Bool) {
        appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { $0.t_calculateVerticalFixedSize(for: $0.t_popups[index]) },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Stack Overlay Opacity
extension PopupVerticalStackViewModelTests {
    func test_calculateStackOverlayOpacity_withThreePopupsStacked_whenNoGestureTranslation_last() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 512)
        ]

        appendPopupsAndCheckStackOverlayOpacity(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 2,
            expectedValueBuilder: { _ in 0 }
        )
    }
    func test_calculateStackOverlayOpacity_withFourPopupsStacked_whenNoGestureTranslation_second() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 512),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 812)
        ]

        appendPopupsAndCheckStackOverlayOpacity(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 1,
            expectedValueBuilder: { $0.t_stackOverlayFactor * 2 }
        )
    }
    func test_calculateStackOverlayOpacity_withFourPopupsStacked_whenGestureTranslationIsNegative_last() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 512),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 812)
        ]

        appendPopupsAndCheckStackOverlayOpacity(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -123,
            calculateForIndex: 3,
            expectedValueBuilder: { _ in 0 }
        )
    }
    func test_calculateStackOverlayOpacity_withTenPopupsStacked_whenGestureTranslationIsNegative_first() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 55),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 512),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 812),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 34),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 664),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 754),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 357),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 1234),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 356)
        ]

        appendPopupsAndCheckStackOverlayOpacity(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -123,
            calculateForIndex: 0,
            expectedValueBuilder: { min($0.t_stackOverlayFactor * 9, $0.t_maxStackOverlayFactor) }
        )
    }
    func test_calculateStackOverlayOpacity_withThreePopupsStacked_whenGestureTranslationIsPositive_last() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 512)
        ]

        appendPopupsAndCheckStackOverlayOpacity(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 494,
            calculateForIndex: 2,
            expectedValueBuilder: { _ in 0 }
        )
    }
    func test_calculateStackOverlayOpacity_withFourPopupsStacked_whenGestureTranslationIsPositive_nextToLast() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 512),
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 343)
        ]

        appendPopupsAndCheckStackOverlayOpacity(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 241,
            calculateForIndex: 2,
            expectedValueBuilder: { (1 - $0.t_calculateTranslationProgress()) * $0.t_stackOverlayFactor }
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckStackOverlayOpacity(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, calculateForIndex index: Int, expectedValueBuilder: @escaping (ViewModel) -> CGFloat) {
        appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { $0.t_calculateStackOverlayOpacity(for: $0.t_popups[index]) },
            expectedValueBuilder: expectedValueBuilder
        )
    }
}

// MARK: On Drag Gesture Changed
extension PopupVerticalStackViewModelTests {
    func test_calculateValuesOnDragGestureChanged_withPositiveDragValue_whenDragGestureDisabled() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 344, dragGestureEnabled: false)
        ]

        appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: 11,
            expectedValues: (popupHeight: 344, gestureTranslation: 0)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withPositiveDragValue_whenDragGestureEnabled_bottomPopupsAlignment() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 344)
        ]

        appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: 11,
            expectedValues: (popupHeight: 344, gestureTranslation: 11)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withPositiveDragValue_whenDragGestureEnabled_topPopupsAlignment() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 344)
        ]

        appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: 11,
            expectedValues: (popupHeight: 344, gestureTranslation: 0)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withNegativeDragValue_whenNoDragDetents() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 344, dragDetents: [])
        ]

        appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -133,
            expectedValues: (popupHeight: 344, gestureTranslation: 0)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withNegativeDragValue_whenDragDetents() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 344, dragDetents: [.height(450)])
        ]

        appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -40,
            expectedValues: (popupHeight: 384, gestureTranslation: -40)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withNegativeDragValue_whenDragDetentsLessThanDragValue_bottomPopupsAlignment() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 344, dragDetents: [.height(370)])
        ]

        appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -133,
            expectedValues: (popupHeight: 370 + bottomViewModel.t_dragTranslationThreshold, gestureTranslation: 344 - 370 - bottomViewModel.t_dragTranslationThreshold)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withNegativeDragValue_whenDragDetentsLessThanDragValue_topPopupsAlignment() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 344, dragDetents: [.height(370)])
        ]

        appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: -133,
            expectedValues: (popupHeight: 344, gestureTranslation: -133)
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckGestureTranslationOnChange(viewModel: ViewModel, popups: [AnyPopup], gestureValue: CGFloat, expectedValues: (popupHeight: CGFloat, gestureTranslation: CGFloat)) {
        viewModel.t_updatePopupsValue(popups)
        viewModel.t_updatePopupsValue(recalculatePopupHeights(viewModel))
        viewModel.t_onPopupDragGestureChanged(gestureValue)

        XCTAssertEqual(viewModel.t_activePopupHeight, expectedValues.popupHeight)
        XCTAssertEqual(viewModel.t_gestureTranslation, expectedValues.gestureTranslation)
    }
}

// MARK: On Drag Gesture Ended
extension PopupVerticalStackViewModelTests {
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenNoDragDetents() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 344)
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -200,
            expectedValues: (popupHeight: 344, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_bottomPopupsAlignment_1() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440)])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -200,
            expectedValues: (popupHeight: 440, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_bottomPopupsAlignment_2() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440), .height(520)])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -120,
            expectedValues: (popupHeight: 520, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_bottomPopupsAlignment_3() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440), .height(520)])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -42,
            expectedValues: (popupHeight: 440, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_bottomPopupsAlignment_4() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440), .height(520), .large, .fullscreen])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -300,
            expectedValues: (popupHeight: screen.height - screen.safeArea.top, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_bottomPopupsAlignment_5() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440), .height(520), .large, .fullscreen])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -600,
            expectedValues: (popupHeight: screen.height, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_topPopupsAlignment_1() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440), .height(520), .large, .fullscreen])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: -300,
            expectedValues: (popupHeight: nil, shouldPopupBeDismissed: true)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_topPopupsAlignment_2() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440), .height(520), .large, .fullscreen])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: -15,
            expectedValues: (popupHeight: 344, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withPositiveDragValue_bottomPopupsAlignment_1() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 400)
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: 50,
            expectedValues: (popupHeight: 400, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withPositiveDragValue_bottomPopupsAlignment_2() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: BottomPopupConfig.self, heightMode: .auto, popupHeight: 400)
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: 300,
            expectedValues: (popupHeight: nil, shouldPopupBeDismissed: true)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withPositiveDragValue_topPopupsAlignment_1() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 400)
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: 400,
            expectedValues: (popupHeight: 400, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withPositiveDragValue_topPopupsAlignment_2() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 400, dragDetents: [.large])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: 100,
            expectedValues: (popupHeight: 400, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withPositiveDragValue_topPopupsAlignment_3() {
        let popups = [
            createPopupInstanceForPopupHeightTests(type: TopPopupConfig.self, heightMode: .auto, popupHeight: 400, dragDetents: [.large])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: 400,
            expectedValues: (popupHeight: screen.height - screen.safeArea.bottom, shouldPopupBeDismissed: false)
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckGestureTranslationOnEnd(viewModel: ViewModel, popups: [AnyPopup], gestureValue: CGFloat, expectedValues: (popupHeight: CGFloat?, shouldPopupBeDismissed: Bool)) {
        viewModel.t_updatePopupsValue(popups)
        viewModel.t_updatePopupsValue(recalculatePopupHeights(viewModel))
        viewModel.t_updateGestureTranslation(gestureValue)
        viewModel.t_calculateAndUpdateTranslationProgress()
        viewModel.t_onPopupDragGestureEnded(gestureValue)

        XCTAssertEqual(viewModel.t_popups.count, expectedValues.shouldPopupBeDismissed ? 0 : 1)
        XCTAssertEqual(viewModel.t_activePopupHeight, expectedValues.popupHeight)
    }
}



// MARK: - HELPERS



// MARK: Methods
private extension PopupVerticalStackViewModelTests {
    func createPopupInstanceForPopupHeightTests<C: LocalConfigVertical>(type: C.Type, heightMode: HeightMode, popupHeight: CGFloat, popupDragHeight: CGFloat? = nil, ignoredSafeAreaEdges: Edge.Set = [], popupPadding: EdgeInsets = .init(), cornerRadius: CGFloat = 0, dragGestureEnabled: Bool = true, dragDetents: [DragDetent] = []) -> AnyPopup {
        let config = getConfigForPopupHeightTests(type: type, heightMode: heightMode, ignoredSafeAreaEdges: ignoredSafeAreaEdges, popupPadding: popupPadding, cornerRadius: cornerRadius, dragGestureEnabled: dragGestureEnabled, dragDetents: dragDetents)

        return AnyPopup.t_createNew(config: config)
            .settingHeight(popupHeight)
            .settingDragHeight(popupDragHeight)
    }
    func appendPopupsAndPerformChecks<Value: Equatable>(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, calculatedValue: @escaping (ViewModel) -> (Value), expectedValueBuilder: @escaping (ViewModel) -> Value) {
        viewModel.t_updatePopupsValue(popups)
        viewModel.t_updatePopupsValue(recalculatePopupHeights(viewModel))
        viewModel.t_updateGestureTranslation(gestureTranslation)

        XCTAssertEqual(calculatedValue(viewModel), expectedValueBuilder(viewModel))
    }
}
private extension PopupVerticalStackViewModelTests {
    func getConfigForPopupHeightTests<C: LocalConfigVertical>(type: C.Type, heightMode: HeightMode, ignoredSafeAreaEdges: Edge.Set, popupPadding: EdgeInsets, cornerRadius: CGFloat, dragGestureEnabled: Bool, dragDetents: [DragDetent]) -> C { .t_createNew(
        popupPadding: popupPadding,
        cornerRadius: cornerRadius,
        ignoredSafeAreaEdges: ignoredSafeAreaEdges,
        heightMode: heightMode,
        dragDetents: dragDetents,
        isDragGestureEnabled: dragGestureEnabled
    )}
    func recalculatePopupHeights(_ viewModel: ViewModel) -> [AnyPopup] { viewModel.t_popups.map {
        $0.settingHeight(viewModel.t_calculateHeight(heightCandidate: $0.height!, popup: $0))
    }}
}

// MARK: Screen
private extension PopupVerticalStackViewModelTests {
    var screen: Screen { .init(
        height: 1000,
        safeArea: .init(top: 100, leading: 20, bottom: 50, trailing: 30)
    )}
}

// MARK: Typealiases
private extension PopupVerticalStackViewModelTests {
    typealias ViewModel = VM.VerticalStack
}
