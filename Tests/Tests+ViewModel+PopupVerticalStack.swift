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
        await setup(topViewModel)
        await setup(bottomViewModel)
    }
}
private extension PopupVerticalStackViewModelTests {
    func setup(_ viewModel: ViewModel) async {
        await viewModel.updateScreen(screenHeight: screen.height, screenSafeArea: screen.safeArea)
        viewModel.setup(updatePopupAction: { await self.updatePopupAction(viewModel, $0) }, closePopupAction: { await self.closePopupAction(viewModel, $0) })
    }
}
private extension PopupVerticalStackViewModelTests {
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



// MARK: Inverted Index
extension PopupVerticalStackViewModelTests {
    func test_getInvertedIndex_1() async {
        await bottomViewModel.updatePopups([
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 150)
        ])

        XCTAssertEqual(
            bottomViewModel.popups.getInvertedIndex(of: bottomViewModel.popups[0]),
            0
        )
    }
    func test_getInvertedIndex_2() async {
        await bottomViewModel.updatePopups([
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 150)
        ])

        XCTAssertEqual(
            bottomViewModel.popups.getInvertedIndex(of: bottomViewModel.popups[3]),
            1
        )
    }
}

// MARK: Update Popup
extension PopupVerticalStackViewModelTests {
    func test_updatePopup_1() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 0)
        ]
        let updatedPopup = await popups[0]
            .updatedHeight(100)
            .updatedDragHeight(100)

        await appendPopupsAndCheckPopups(
            viewModel: bottomViewModel,
            popups: popups,
            updatedPopup: updatedPopup,
            expectedValue: (height: 100, dragHeight: 100)
        )
    }
    func test_updatePopup_2() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 50),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 25),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 15),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 2137)
        ]
        let updatedPopup = await popups[2].updatedHeight(1371)

        await appendPopupsAndCheckPopups(
            viewModel: bottomViewModel,
            popups: popups,
            updatedPopup: updatedPopup,
            expectedValue: (height: 1371, dragHeight: nil)
        )
    }
    func test_updatePopup_3() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 50),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 25),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 15),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 2137),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 77)
        ]
        let updatedPopup = await popups[4].updatedHeight(nil)

        await appendPopupsAndCheckPopups(
            viewModel: bottomViewModel,
            popups: popups,
            updatedPopup: updatedPopup,
            expectedValue: (height: nil, dragHeight: nil)
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckPopups(viewModel: ViewModel, popups: [AnyPopup], updatedPopup: AnyPopup, expectedValue: (height: CGFloat?, dragHeight: CGFloat?)) async {
        await viewModel.updatePopups(popups)
        await viewModel.updatePopupAction(updatedPopup)

        if let index = viewModel.popups.firstIndex(of: updatedPopup) {
            XCTAssertEqual(viewModel.popups[index].height, expectedValue.height)
            XCTAssertEqual(viewModel.popups[index].dragHeight, expectedValue.dragHeight)
        }
    }
}

// MARK: Popup Height
extension PopupVerticalStackViewModelTests {
    func test_calculatePopupHeight_withAutoHeightMode_whenLessThanScreen_onePopupStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 150)
        ]

        await appendPopupsAndCheckPopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            calculateForIndex: 0,
            expectedValue: 150
        )
    }
    func test_calculatePopupHeight_withAutoHeightMode_whenLessThanScreen_fourPopupsStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 200),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 100)
        ]

        await appendPopupsAndCheckPopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            calculateForIndex: 3,
            expectedValue: 100
        )
    }
    func test_calculatePopupHeight_withAutoHeightMode_whenBiggerThanScreen_onePopupStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 2000)
        ]

        await appendPopupsAndCheckPopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            calculateForIndex: 0,
            expectedValue: screen.height - screen.safeArea.top
        )
    }
    func test_calculatePopupHeight_withAutoHeightMode_whenBiggerThanScreen_fivePopupStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 200),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 2000)
        ]

        await appendPopupsAndCheckPopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            calculateForIndex: 4,
            expectedValue: screen.height - screen.safeArea.top - bottomViewModel.stackOffset * 4
        )
    }
    func test_calculatePopupHeight_withLargeHeightMode_whenOnePopupStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .large, popupHeight: 100)
        ]

        await appendPopupsAndCheckPopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            calculateForIndex: 0,
            expectedValue: screen.height - screen.safeArea.top
        )
    }
    func test_calculatePopupHeight_withLargeHeightMode_whenThreePopupStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .large, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .large, popupHeight: 700),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .large, popupHeight: 1000)
        ]

        await appendPopupsAndCheckPopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            calculateForIndex: 2,
            expectedValue: screen.height - screen.safeArea.top - bottomViewModel.stackOffset * 2
        )
    }
    func test_calculatePopupHeight_withFullscreenHeightMode_whenOnePopupStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 100)
        ]

        await appendPopupsAndCheckPopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            calculateForIndex: 0,
            expectedValue: screen.height
        )
    }
    func test_calculatePopupHeight_withFullscreenHeightMode_whenThreePopupsStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 2000),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 3000)
        ]

        await appendPopupsAndCheckPopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            calculateForIndex: 2,
            expectedValue: screen.height
        )
    }
    func test_calculatePopupHeight_withLargeHeightMode_whenThreePopupsStacked_popupPadding() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 2000),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .large, popupHeight: 3000, popupPadding: .init(top: 33, leading: 15, bottom: 21, trailing: 15))
        ]

        await appendPopupsAndCheckPopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            calculateForIndex: 2,
            expectedValue: screen.height - screen.safeArea.top - 2 * bottomViewModel.stackOffset
        )
    }
    func test_calculatePopupHeight_withFullscreenHeightMode_whenThreePopupsStacked_popupPadding() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 2000),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 3000, popupPadding: .init(top: 33, leading: 15, bottom: 21, trailing: 15))
        ]

        await appendPopupsAndCheckPopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            calculateForIndex: 2,
            expectedValue: screen.height
        )
    }
    func test_calculatePopupHeight_withLargeHeightMode_whenPopupsHaveTopAlignment() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .large, popupHeight: 100)
        ]

        await appendPopupsAndCheckPopupHeight(
            viewModel: topViewModel,
            popups: popups,
            calculateForIndex: 0,
            expectedValue: screen.height - screen.safeArea.bottom
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckPopupHeight(viewModel: ViewModel, popups: [AnyPopup], calculateForIndex index: Int, expectedValue: CGFloat) async {
        await appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: 0,
            calculatedValue: { $0.popups[index].height },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Active Popup Height
extension PopupVerticalStackViewModelTests {
    func test_calculateActivePopupHeight_withAutoHeightMode_whenLessThanScreen_onePopupStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 100)
        ]

        await appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: 100
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenBiggerThanScreen_threePopupsStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 3000),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1000),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 2000)
        ]

        await appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: screen.height - screen.safeArea.top - 2 * bottomViewModel.stackOffset
        )
    }
    func test_calculateActivePopupHeight_withLargeHeightMode_whenThreePopupsStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 1000),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .large, popupHeight: 2000)
        ]

        await appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: screen.height - screen.safeArea.top - 2 * bottomViewModel.stackOffset
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenGestureIsNegative_twoPopupsStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 2000)
        ]

        await appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -51,
            expectedValue: screen.height - screen.safeArea.top - bottomViewModel.stackOffset * 1 + 51
        )
    }
    func test_calculateActivePopupHeight_withLargeHeightMode_whenGestureIsNegative_onePopupStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .large, popupHeight: 350)
        ]

        await appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -99,
            expectedValue: screen.height - screen.safeArea.top + 99
        )
    }
    func test_calculateActivePopupHeight_withFullscreenHeightMode_whenGestureIsNegative_twoPopupsStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 250)
        ]

        await appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -21,
            expectedValue: screen.height
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenGestureIsPositive_threePopupsStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .large, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 1000),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 850)
        ]

        await appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 100,
            expectedValue: 850
        )
    }
    func test_calculateActivePopupHeight_withFullscreenHeightMode_whenGestureIsPositive_onePopupStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 350)
        ]

        await appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 31,
            expectedValue: screen.height
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenGestureIsNegative_hasDragHeightStored_twoPopupsStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 500, popupDragHeight: 100)
        ]

        await appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -93,
            expectedValue: 500 + 100 + 93
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenGestureIsPositive_hasDragHeightStored_onePopupStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1300, popupDragHeight: 100)
        ]

        await appendPopupsAndCheckActivePopupHeight(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 350,
            expectedValue: screen.height - screen.safeArea.top
        )
    }
    func test_calculateActivePopupHeight_withPopupsHaveTopAlignment() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .large, popupHeight: 1300)
        ]

        await appendPopupsAndCheckActivePopupHeight(
            viewModel: topViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: screen.height - screen.safeArea.bottom
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckActivePopupHeight(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: CGFloat) async {
        await appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { $0.activePopupProperties.height },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Offset
extension PopupVerticalStackViewModelTests {
    func test_calculateOffsetY_withZeroGestureTranslation_fivePopupsStacked_thirdElement() async {
        await bottomViewModel.updatePopups([
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 240),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 670),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 310)
        ])

        XCTAssertEqual(
            bottomViewModel.calculateOffsetY(for: bottomViewModel.popups[2]),
            -bottomViewModel.stackOffset * 2
        )
    }
    func test_calculateOffsetY_withZeroGestureTranslation_fivePopupsStacked_lastElement() async {
        await bottomViewModel.updatePopups([
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 240),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 670),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 310)
        ])

        XCTAssertEqual(
            bottomViewModel.calculateOffsetY(for: bottomViewModel.popups[4]),
            0
        )
    }
    func test_calculateOffsetY_withNegativeGestureTranslation_dragHeight_onePopupStacked() async {
        await bottomViewModel.updatePopups([
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 350, popupDragHeight: 100)
        ])
        await bottomViewModel.updateGestureTranslation(-100)

        XCTAssertEqual(
            bottomViewModel.calculateOffsetY(for: bottomViewModel.popups[0]),
            0
        )
    }
    func test_calculateOffsetY_withPositiveGestureTranslation_dragHeight_twoPopupsStacked_firstElement() async {
        await bottomViewModel.updatePopups([
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 350, popupDragHeight: 249),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 133, popupDragHeight: 21)
        ])
        await bottomViewModel.updateGestureTranslation(100)

        XCTAssertEqual(
            bottomViewModel.calculateOffsetY(for: bottomViewModel.popups[0]),
            -bottomViewModel.stackOffset
        )
    }
    func test_calculateOffsetY_withPositiveGestureTranslation_dragHeight_twoPopupsStacked_lastElement() async {
        await bottomViewModel.updatePopups([
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 350, popupDragHeight: 249),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 133, popupDragHeight: 21)
        ])
        await bottomViewModel.updateGestureTranslation(100)

        XCTAssertEqual(
            bottomViewModel.calculateOffsetY(for: bottomViewModel.popups[1]),
            100 - 21
        )
    }
    func test_calculateOffsetY_withStackingDisabled() async {
        await bottomViewModel.updatePopups([
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 350, popupDragHeight: 249),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 133, popupDragHeight: 21)
        ])
        GlobalConfigContainer.vertical.isStackingEnabled = false

        XCTAssertEqual(
            bottomViewModel.calculateOffsetY(for: bottomViewModel.popups[0]),
            0
        )
    }
    func test_calculateOffsetY_withPopupsHaveTopAlignment_1() async {
        await topViewModel.updatePopups([
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 350, popupDragHeight: 249),
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 133, popupDragHeight: 21)
        ])

        XCTAssertEqual(
            topViewModel.calculateOffsetY(for: topViewModel.popups[0]),
            topViewModel.stackOffset
        )
    }
    func test_calculateOffsetY_withPopupsHaveTopAlignment_2() async {
        await topViewModel.updatePopups([
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 350, popupDragHeight: 249),
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 133, popupDragHeight: 21)
        ])
        await topViewModel.updateGestureTranslation(-100)

        XCTAssertEqual(
            topViewModel.calculateOffsetY(for: topViewModel.popups[1]),
            21 - 100
        )
    }
}

// MARK: Outer Padding
extension PopupVerticalStackViewModelTests {
    func test_calculateOuterPadding_withAutoHeightMode_whenLessThanScreen() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 344, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        await appendPopupsAndCheckOuterPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 12, leading: 17, bottom: 33, trailing: 17)
        )
    }
    func test_calculateOuterPadding_withAutoHeightMode_almostLikeScreen_onlyOnePaddingShouldBeNonZero() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 877, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        await appendPopupsAndCheckOuterPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 17, bottom: 23, trailing: 17)
        )
    }
    func test_calculateOuterPadding_withAutoHeightMode_almostLikeScreen_bothPaddingsShouldBeNonZero() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 861, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        await appendPopupsAndCheckOuterPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 6, leading: 17, bottom: 33, trailing: 17)
        )
    }
    func test_calculateOuterPadding_withAutoHeightMode_almostLikeScreen_topPopupsAlignment() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 911, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        await appendPopupsAndCheckOuterPadding(
            viewModel: topViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 12, leading: 17, bottom: 27, trailing: 17)
        )
    }
    func test_calculateOuterPadding_withAutoHeightMode_whenBiggerThanScreen() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1100, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        await appendPopupsAndCheckOuterPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 17, bottom: 0, trailing: 17)
        )
    }
    func test_calculateOuterPadding_withLargeHeightMode() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .large, popupHeight: 344, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        await appendPopupsAndCheckOuterPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 17, bottom: 0, trailing: 17)
        )
    }
    func test_calculateOuterPadding_withFullscreenHeightMode() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 344, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        await appendPopupsAndCheckOuterPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 17, bottom: 0, trailing: 17)
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckOuterPadding(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: EdgeInsets) async {
        await appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { await $0.calculateActivePopupOuterPadding() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Inner Padding
extension PopupVerticalStackViewModelTests {
    func test_calculateInnerPadding_withDefaultSettings() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 350)
        ]

        await appendPopupsAndCheckInnerPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: screen.safeArea.top, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateInnerPadding_withIgnoringSafeArea_bottom() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 200, ignoredSafeAreaEdges: .bottom)
        ]

        await appendPopupsAndCheckInnerPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: screen.safeArea.leading, bottom: 0, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateInnerPadding_withIgnoringSafeArea_all() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1200, ignoredSafeAreaEdges: .all)
        ]

        await appendPopupsAndCheckInnerPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        )
    }
    func test_calculateInnerPadding_withPopupPadding() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1200, popupPadding: .init(top: 21, leading: 12, bottom: 37, trailing: 12))
        ]

        await appendPopupsAndCheckInnerPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateInnerPadding_withFullscreenHeightMode_ignoringSafeArea_top() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 100, ignoredSafeAreaEdges: .top)
        ]

        await appendPopupsAndCheckInnerPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateInnerPadding_withGestureTranslation() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 800)
        ]

        await appendPopupsAndCheckInnerPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -300,
            expectedValue: .init(top: screen.safeArea.top, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateInnerPadding_withGestureTranslation_dragHeight() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300, popupDragHeight: 700)
        ]

        await appendPopupsAndCheckInnerPadding(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 21,
            expectedValue: .init(top: screen.safeArea.top - 21, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateInnerPadding_withGestureTranslation_dragHeight_topPopupsAlignment() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 300, popupDragHeight: 700)
        ]

        await appendPopupsAndCheckInnerPadding(
            viewModel: topViewModel,
            popups: popups,
            gestureTranslation: -21,
            expectedValue: .init(top: screen.safeArea.top, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom - 21, trailing: screen.safeArea.trailing)
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckInnerPadding(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: EdgeInsets) async {
        await appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { await $0.calculateActivePopupInnerPadding() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Translation Progress
extension PopupVerticalStackViewModelTests {
    func test_calculateTranslationProgress_withNoGestureTranslation() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300)
        ]

        await appendPopupsAndCheckTranslationProgress(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: 0
        )
    }
    func test_calculateTranslationProgress_withPositiveGestureTranslation() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300)
        ]

        await appendPopupsAndCheckTranslationProgress(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 250,
            expectedValue: 250 / 300
        )
    }
    func test_calculateTranslationProgress_withPositiveGestureTranslation_dragHeight() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300, popupDragHeight: 120)
        ]

        await appendPopupsAndCheckTranslationProgress(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 250,
            expectedValue: (250 - 120) / 300
        )
    }
    func test_calculateTranslationProgress_withNegativeGestureTranslation() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300)
        ]

        await appendPopupsAndCheckTranslationProgress(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -175,
            expectedValue: 0
        )
    }
    func test_calculateTranslationProgress_withNegativeGestureTranslation_whenTopPopupsAlignment() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 300)
        ]

        await appendPopupsAndCheckTranslationProgress(
            viewModel: topViewModel,
            popups: popups,
            gestureTranslation: -175,
            expectedValue: 175 / 300
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckTranslationProgress(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: CGFloat) async {
        await appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { await $0.calculateActivePopupTranslationProgress() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Corner Radius
extension PopupVerticalStackViewModelTests {
    func test_calculateCornerRadius_withTwoPopupsStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300, cornerRadius: 1),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300, cornerRadius: 12)
        ]

        await appendPopupsAndCheckCornerRadius(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 12, .bottom: 0]
        )
    }
    func test_calculateCornerRadius_withPopupPadding_bottom_first() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300, popupPadding: .init(top: 0, leading: 0, bottom: 12, trailing: 0), cornerRadius: 1),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300, cornerRadius: 12)
        ]

        await appendPopupsAndCheckCornerRadius(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 12, .bottom: 0]
        )
    }
    func test_calculateCornerRadius_withPopupPadding_bottom_last() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300, cornerRadius: 1),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300, popupPadding: .init(top: 0, leading: 0, bottom: 12, trailing: 0), cornerRadius: 12)
        ]

        await appendPopupsAndCheckCornerRadius(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 12, .bottom: 12]
        )
    }
    func test_calculateCornerRadius_withPopupPadding_all() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300, cornerRadius: 1),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300, popupPadding: .init(top: 12, leading: 24, bottom: 12, trailing: 24), cornerRadius: 12)
        ]

        await appendPopupsAndCheckCornerRadius(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 12, .bottom: 12]
        )
    }
    func test_calculateCornerRadius_fullscreen() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 300, cornerRadius: 13)
        ]

        await appendPopupsAndCheckCornerRadius(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 0, .bottom: 0]
        )
    }
    func test_calculateCornerRadius_whenPopupsHaveTopAlignment() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 300, cornerRadius: 12)
        ]

        await appendPopupsAndCheckCornerRadius(
            viewModel: topViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 0, .bottom: 12]
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckCornerRadius(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: [MijickPopups.PopupAlignment: CGFloat]) async {
        await appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { await $0.calculateActivePopupCorners() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Scale X
extension PopupVerticalStackViewModelTests {
    func test_calculateScaleX_withNoGestureTranslation_threePopupsStacked_last() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 360)
        ]

        await appendPopupsAndCheckScaleX(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 2,
            expectedValueBuilder: {_ in 1 }
        )
    }
    func test_calculateScaleX_withNoGestureTranslation_fourPopupsStacked_second() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 360),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1360)
        ]

        await appendPopupsAndCheckScaleX(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 1,
            expectedValueBuilder: { 1 - $0.stackScaleFactor * 2 }
        )
    }
    func test_calculateScaleX_withNegativeGestureTranslation_fourPopupsStacked_third() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 360),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1360)
        ]

        await appendPopupsAndCheckScaleX(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -100,
            calculateForIndex: 2,
            expectedValueBuilder: { 1 - $0.stackScaleFactor * 1 }
        )
    }
    func test_calculateScaleX_withPositiveGestureTranslation_fivePopupsStacked_second() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 360),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 123)
        ]

        await appendPopupsAndCheckScaleX(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 100,
            calculateForIndex: 1,
            expectedValueBuilder: { await 1 - $0.stackScaleFactor * 3 * max(1 - $0.calculateActivePopupTranslationProgress(), $0.minScaleProgressMultiplier) }
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckScaleX(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, calculateForIndex index: Int, expectedValueBuilder: @escaping (ViewModel) async -> CGFloat) async {
        await appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { $0.calculateScaleX(for: $0.popups[index]) },
            expectedValueBuilder: expectedValueBuilder
        )
    }
}

// MARK: Fixed Size
extension PopupVerticalStackViewModelTests {
    func test_calculateFixedSize_withAutoHeightMode_whenLessThanScreen_twoPopupsStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 123)
        ]

        await appendPopupsAndCheckVerticalFixedSize(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: true
        )
    }
    func test_calculateFixedSize_withAutoHeightMode_whenBiggerThanScreen_twoPopupsStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1223)
        ]

        await appendPopupsAndCheckVerticalFixedSize(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: false
        )
    }
    func test_calculateFixedSize_withLargeHeightMode_threePopupsStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1223),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .large, popupHeight: 1223)
        ]

        await appendPopupsAndCheckVerticalFixedSize(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: false
        )
    }
    func test_calculateFixedSize_withFullscreenHeightMode_fivePopupsStacked() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1223),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .large, popupHeight: 1223),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1223),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 1223)
        ]

        await appendPopupsAndCheckVerticalFixedSize(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            expectedValue: false
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckVerticalFixedSize(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: Bool) async {
        await appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { await $0.calculateActivePopupVerticalFixedSize() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Stack Overlay Opacity
extension PopupVerticalStackViewModelTests {
    func test_calculateStackOverlayOpacity_withThreePopupsStacked_whenNoGestureTranslation_last() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 512)
        ]

        await appendPopupsAndCheckStackOverlayOpacity(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 2,
            expectedValueBuilder: { _ in 0 }
        )
    }
    func test_calculateStackOverlayOpacity_withFourPopupsStacked_whenNoGestureTranslation_second() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 512),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 812)
        ]

        await appendPopupsAndCheckStackOverlayOpacity(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 1,
            expectedValueBuilder: { $0.stackOverlayFactor * 2 }
        )
    }
    func test_calculateStackOverlayOpacity_withFourPopupsStacked_whenGestureTranslationIsNegative_last() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 512),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 812)
        ]

        await appendPopupsAndCheckStackOverlayOpacity(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -123,
            calculateForIndex: 3,
            expectedValueBuilder: { _ in 0 }
        )
    }
    func test_calculateStackOverlayOpacity_withTenPopupsStacked_whenGestureTranslationIsNegative_first() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 55),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 512),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 812),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 34),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 664),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 754),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 357),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 1234),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 356)
        ]

        await appendPopupsAndCheckStackOverlayOpacity(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: -123,
            calculateForIndex: 0,
            expectedValueBuilder: { min($0.stackOverlayFactor * 9, $0.maxStackOverlayFactor) }
        )
    }
    func test_calculateStackOverlayOpacity_withThreePopupsStacked_whenGestureTranslationIsPositive_last() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 512)
        ]

        await appendPopupsAndCheckStackOverlayOpacity(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 494,
            calculateForIndex: 2,
            expectedValueBuilder: { _ in 0 }
        )
    }
    func test_calculateStackOverlayOpacity_withFourPopupsStacked_whenGestureTranslationIsPositive_nextToLast() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 512),
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 343)
        ]

        await appendPopupsAndCheckStackOverlayOpacity(
            viewModel: bottomViewModel,
            popups: popups,
            gestureTranslation: 241,
            calculateForIndex: 2,
            expectedValueBuilder: { await (1 - $0.calculateActivePopupTranslationProgress()) * $0.stackOverlayFactor }
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckStackOverlayOpacity(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, calculateForIndex index: Int, expectedValueBuilder: @escaping (ViewModel) async -> CGFloat) async {
        await appendPopupsAndPerformChecks(
            viewModel: viewModel,
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { $0.calculateStackOverlayOpacity(for: $0.popups[index]) },
            expectedValueBuilder: expectedValueBuilder
        )
    }
}

// MARK: On Drag Gesture Changed
extension PopupVerticalStackViewModelTests {
    func test_calculateValuesOnDragGestureChanged_withPositiveDragValue_whenDragGestureDisabled() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 344, dragGestureEnabled: false)
        ]

        await appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: 11,
            expectedValues: (popupHeight: 344, gestureTranslation: 0)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withPositiveDragValue_whenDragGestureEnabled_bottomPopupsAlignment() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 344)
        ]

        await appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: 11,
            expectedValues: (popupHeight: 344, gestureTranslation: 11)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withPositiveDragValue_whenDragGestureEnabled_topPopupsAlignment() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 344)
        ]

        await appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: 11,
            expectedValues: (popupHeight: 344, gestureTranslation: 0)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withNegativeDragValue_whenNoDragDetents() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 344, dragDetents: [])
        ]

        await appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -133,
            expectedValues: (popupHeight: 344, gestureTranslation: 0)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withNegativeDragValue_whenDragDetents() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 344, dragDetents: [.height(450)])
        ]

        await appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -40,
            expectedValues: (popupHeight: 384, gestureTranslation: -40)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withNegativeDragValue_whenDragDetentsLessThanDragValue_bottomPopupsAlignment() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 344, dragDetents: [.height(370)])
        ]

        await appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -133,
            expectedValues: (popupHeight: 370 + bottomViewModel.dragTranslationThreshold, gestureTranslation: 344 - 370 - bottomViewModel.dragTranslationThreshold)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withNegativeDragValue_whenDragDetentsLessThanDragValue_topPopupsAlignment() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 344, dragDetents: [.height(370)])
        ]

        await appendPopupsAndCheckGestureTranslationOnChange(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: -133,
            expectedValues: (popupHeight: 344, gestureTranslation: -133)
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckGestureTranslationOnChange(viewModel: ViewModel, popups: [AnyPopup], gestureValue: CGFloat, expectedValues: (popupHeight: CGFloat, gestureTranslation: CGFloat)) async {
        await viewModel.updatePopups(popups)
        await updatePopups(viewModel)
        await viewModel.onPopupDragGestureChanged(gestureValue)

        XCTAssertEqual(viewModel.activePopupProperties.height, expectedValues.popupHeight)
        XCTAssertEqual(viewModel.activePopupProperties.gestureTranslation, expectedValues.gestureTranslation)
    }
}

// MARK: On Drag Gesture Ended
extension PopupVerticalStackViewModelTests {
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenNoDragDetents() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 344)
        ]

        await appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -200,
            expectedValues: (popupHeight: 344, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_bottomPopupsAlignment_1() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440)])
        ]

        await appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -200,
            expectedValues: (popupHeight: 440, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_bottomPopupsAlignment_2() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440), .height(520)])
        ]

        await appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -120,
            expectedValues: (popupHeight: 520, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_bottomPopupsAlignment_3() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440), .height(520)])
        ]

        await appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -42,
            expectedValues: (popupHeight: 440, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_bottomPopupsAlignment_4() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440), .height(520), .large, .fullscreen])
        ]

        await appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -300,
            expectedValues: (popupHeight: screen.height - screen.safeArea.top, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_bottomPopupsAlignment_5() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440), .height(520), .large, .fullscreen])
        ]

        await appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: -600,
            expectedValues: (popupHeight: screen.height, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_topPopupsAlignment_1() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440), .height(520), .large, .fullscreen])
        ]

        await appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: -300,
            expectedValues: (popupHeight: nil, shouldPopupBeDismissed: true)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_topPopupsAlignment_2() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 344, dragDetents: [.height(440), .height(520), .large, .fullscreen])
        ]

        await appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: -15,
            expectedValues: (popupHeight: 344, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withPositiveDragValue_bottomPopupsAlignment_1() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 400)
        ]

        await appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: 50,
            expectedValues: (popupHeight: 400, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withPositiveDragValue_bottomPopupsAlignment_2() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .bottom, heightMode: .auto, popupHeight: 400)
        ]

        await appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: bottomViewModel,
            popups: popups,
            gestureValue: 300,
            expectedValues: (popupHeight: nil, shouldPopupBeDismissed: true)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withPositiveDragValue_topPopupsAlignment_1() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 400)
        ]

        await appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: 400,
            expectedValues: (popupHeight: 400, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withPositiveDragValue_topPopupsAlignment_2() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 400, dragDetents: [.large])
        ]

        await appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: 100,
            expectedValues: (popupHeight: 400, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withPositiveDragValue_topPopupsAlignment_3() async {
        let popups = await [
            createPopupInstanceForPopupHeightTests(alignment: .top, heightMode: .auto, popupHeight: 400, dragDetents: [.large])
        ]

        await appendPopupsAndCheckGestureTranslationOnEnd(
            viewModel: topViewModel,
            popups: popups,
            gestureValue: 400,
            expectedValues: (popupHeight: screen.height - screen.safeArea.bottom, shouldPopupBeDismissed: false)
        )
    }
}
private extension PopupVerticalStackViewModelTests {
    func appendPopupsAndCheckGestureTranslationOnEnd(viewModel: ViewModel, popups: [AnyPopup], gestureValue: CGFloat, expectedValues: (popupHeight: CGFloat?, shouldPopupBeDismissed: Bool)) async {
        await viewModel.updatePopups(popups)
        await updatePopups(viewModel)
        await viewModel.updateGestureTranslation(gestureValue)
        await viewModel.onPopupDragGestureEnded(gestureValue)

        XCTAssertEqual(viewModel.popups.count, expectedValues.shouldPopupBeDismissed ? 0 : 1)
        XCTAssertEqual(viewModel.activePopupProperties.height, expectedValues.popupHeight)
    }
}



// MARK: - HELPERS



// MARK: Methods
private extension PopupVerticalStackViewModelTests {
    func createPopupInstanceForPopupHeightTests(alignment: PopupAlignment, heightMode: HeightMode, popupHeight: CGFloat, popupDragHeight: CGFloat = 0, ignoredSafeAreaEdges: Edge.Set = [], popupPadding: EdgeInsets = .init(), cornerRadius: CGFloat = 0, dragGestureEnabled: Bool = true, dragDetents: [DragDetent] = []) async -> AnyPopup {
        let popup = getTestPopup(alignment, heightMode, popupHeight, popupDragHeight, ignoredSafeAreaEdges, popupPadding, cornerRadius, dragGestureEnabled, dragDetents)
        return await AnyPopup(popup)
            .updatedHeight(popupHeight)
            .updatedDragHeight(popupDragHeight)
    }
    func appendPopupsAndPerformChecks<Value: Equatable & Sendable>(viewModel: ViewModel, popups: [AnyPopup], gestureTranslation: CGFloat, calculatedValue: @escaping (ViewModel) async -> (Value), expectedValueBuilder: @escaping (ViewModel) async -> Value) async {
        await viewModel.updatePopups(popups)
        await updatePopups(viewModel)
        await viewModel.updateGestureTranslation(gestureTranslation)

        let calculatedValue = await calculatedValue(viewModel)
        let expectedValue = await expectedValueBuilder(viewModel)
        XCTAssertEqual(calculatedValue, expectedValue)
    }
}
private extension PopupVerticalStackViewModelTests {
    func getTestPopup(_ alignment: PopupAlignment, _ heightMode: HeightMode, _ popupHeight: CGFloat, _ popupDragHeight: CGFloat, _ ignoredSafeAreaEdges: Edge.Set, _ popupPadding: EdgeInsets, _ cornerRadius: CGFloat, _ dragGestureEnabled: Bool, _ dragDetents: [DragDetent]) -> any Popup { switch alignment {
        case .top: TestTopPopup(popupPadding: popupPadding, cornerRadius: cornerRadius, ignoredSafeAreaEdges: ignoredSafeAreaEdges, heightMode: heightMode, dragDetents: dragDetents, dragGestureEnabled: dragGestureEnabled)
        case .bottom: TestBottomPopup(popupPadding: popupPadding, cornerRadius: cornerRadius, ignoredSafeAreaEdges: ignoredSafeAreaEdges, heightMode: heightMode, dragDetents: dragDetents, dragGestureEnabled: dragGestureEnabled)
        case .center: fatalError()
    }}
    func updatePopups(_ viewModel: ViewModel) async {
        for popup in viewModel.popups {
            await viewModel.updatePopupHeight(popup.height!, popup)
            await waitForResults()
        }
    }
    func waitForResults() async {
        await Task.sleep(seconds: 0.01)
    }
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

// MARK: Test Popups
private struct TestTopPopup: TopPopup {
    let popupPadding: EdgeInsets
    let cornerRadius: CGFloat
    let ignoredSafeAreaEdges: Edge.Set
    let heightMode: HeightMode
    let dragDetents: [DragDetent]
    let dragGestureEnabled: Bool


    func configurePopup(config: TopPopupConfig) -> TopPopupConfig { config
        .popupTopPadding(popupPadding.top)
        .popupBottomPadding(popupPadding.bottom)
        .popupHorizontalPadding(popupPadding.leading)
        .cornerRadius(cornerRadius)
        .ignoreSafeArea(edges: ignoredSafeAreaEdges)
        .heightMode(heightMode)
        .dragDetents(dragDetents)
        .enableDragGesture(dragGestureEnabled)
    }
    var body: some View { EmptyView() }
}
private struct TestBottomPopup: BottomPopup {
    let popupPadding: EdgeInsets
    let cornerRadius: CGFloat
    let ignoredSafeAreaEdges: Edge.Set
    let heightMode: HeightMode
    let dragDetents: [DragDetent]
    let dragGestureEnabled: Bool


    func configurePopup(config: BottomPopupConfig) -> BottomPopupConfig { config
        .popupTopPadding(popupPadding.top)
        .popupBottomPadding(popupPadding.bottom)
        .popupHorizontalPadding(popupPadding.leading)
        .cornerRadius(cornerRadius)
        .ignoreSafeArea(edges: ignoredSafeAreaEdges)
        .heightMode(heightMode)
        .dragDetents(dragDetents)
        .enableDragGesture(dragGestureEnabled)
    }
    var body: some View { EmptyView() }
}

// MARK: Others
extension VM.VerticalStack: @unchecked Sendable {}
