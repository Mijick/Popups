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
import Combine
@testable import MijickPopups

final class PopupStackViewModelTests: XCTestCase {
    @ObservedObject private var topViewModel: ViewModel = .init(alignment: .top)
    @ObservedObject private var bottomViewModel: ViewModel = .init(alignment: .bottom)
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        bottomViewModel.screen = screen
        bottomViewModel.updatePopup = { [self] in if let index = bottomViewModel.popups.firstIndex(of: $0) {
            bottomViewModel.popups[index] = $0
            testHook.recalculateActivePopupHeight()
        }}
        bottomViewModel.closePopup = { [self] in if let popup = $0, let index = bottomViewModel.popups.firstIndex(of: popup) {
            bottomViewModel.popups.remove(at: index)
        }}
    }
}



// MARK: - Test Cases



// MARK: Popup Height
extension PopupStackViewModelTests {
    func test_calculatePopupHeight_withAutoHeightMode_whenLessThanScreen_onePopupStacked() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 150)
        ]

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            150.0
        )
    }
    func test_calculatePopupHeight_withAutoHeightMode_whenLessThanScreen_fourPopupsStacked() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 200),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 100)
        ]

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            100.0
        )
    }
    func test_calculatePopupHeight_withAutoHeightMode_whenBiggerThanScreen_onePopupStacked() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 2000)
        ]

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            fullscreenHeight - screen.safeArea.top
        )
    }
    func test_calculatePopupHeight_withAutoHeightMode_whenBiggerThanScreen_fivePopupStacked() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 150),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 200),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 2000)
        ]

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            fullscreenHeight - screen.safeArea.top - testHook.stackOffset * 4
        )
    }
    func test_calculatePopupHeight_withLargeHeightMode_whenOnePopupStacked() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .large, popupHeight: 100)
        ]

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            fullscreenHeight - screen.safeArea.top
        )
    }
    func test_calculatePopupHeight_withLargeHeightMode_whenThreePopupStacked() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .large, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(heightMode: .large, popupHeight: 700),
            createPopupInstanceForPopupHeightTests(heightMode: .large, popupHeight: 1000)
        ]

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            fullscreenHeight - screen.safeArea.top - testHook.stackOffset * 2
        )
    }
    func test_calculatePopupHeight_withFullscreenHeightMode_whenOnePopupStacked() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 100)
        ]

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            fullscreenHeight
        )
    }
    func test_calculatePopupHeight_withFullscreenHeightMode_whenThreePopupsStacked() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 2000),
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 3000)
        ]

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            fullscreenHeight
        )
    }
    func test_calculatePopupHeight_withLargeHeightMode_whenThreePopupsStacked_popupPadding() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 2000),
            createPopupInstanceForPopupHeightTests(heightMode: .large, popupHeight: 3000, popupPadding: .init(top: 33, leading: 15, bottom: 21, trailing: 15))
        ]

        XCTAssertEqual(
            calculateLastPopupHeight(bottomViewModel),
            fullscreenHeight - screen.safeArea.top - 2 * testHook.stackOffset
        )
    }
    func test_calculatePopupHeight_withFullscreenHeightMode_whenThreePopupsStacked_popupPadding() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 2000),
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 3000, popupPadding: .init(top: 33, leading: 15, bottom: 21, trailing: 15))
        ]

        XCTAssertEqual(
            calculateLastPopupHeight(),
            fullscreenHeight
        )
    }
}
private extension PopupStackViewModelTests {
    func calculateLastPopupHeight() -> CGFloat {
        testHook.calculatePopupHeight(height: bottomViewModel.popups.last!.height!, popupConfig: bottomViewModel.popups.last!.config as! Config)
    }
}

// MARK: Active Popup Height
extension PopupStackViewModelTests {
    func test_calculateActivePopupHeight_withAutoHeightMode_whenLessThanScreen_onePopupStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 100)
        ]

        appendPopupsAndCheckActivePopupHeight(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: 100
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenBiggerThanScreen_threePopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 3000),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1000),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 2000)
        ]

        appendPopupsAndCheckActivePopupHeight(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: fullscreenHeight - screen.safeArea.top - 2 * testHook.stackOffset
        )
    }
    func test_calculateActivePopupHeight_withLargeHeightMode_whenThreePopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 1000),
            createPopupInstanceForPopupHeightTests(heightMode: .large, popupHeight: 2000)
        ]

        appendPopupsAndCheckActivePopupHeight(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: fullscreenHeight - screen.safeArea.top - 2 * testHook.stackOffset
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenGestureIsNegative_twoPopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 2000)
        ]

        appendPopupsAndCheckActivePopupHeight(
            popups: popups,
            gestureTranslation: -51,
            expectedValue: fullscreenHeight - screen.safeArea.top - testHook.stackOffset * 1 + 51
        )
    }
    func test_calculateActivePopupHeight_withLargeHeightMode_whenGestureIsNegative_onePopupStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .large, popupHeight: 350)
        ]

        appendPopupsAndCheckActivePopupHeight(
            popups: popups,
            gestureTranslation: -99,
            expectedValue: fullscreenHeight - screen.safeArea.top + 99
        )
    }
    func test_calculateActivePopupHeight_withFullscreenHeightMode_whenGestureIsNegative_twoPopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 100),
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 250)
        ]

        appendPopupsAndCheckActivePopupHeight(
            popups: popups,
            gestureTranslation: -21,
            expectedValue: fullscreenHeight
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenGestureIsPositive_threePopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .large, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 1000),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 850)
        ]

        appendPopupsAndCheckActivePopupHeight(
            popups: popups,
            gestureTranslation: 100,
            expectedValue: 850
        )
    }
    func test_calculateActivePopupHeight_withFullscreenHeightMode_whenGestureIsPositive_onePopupStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 350)
        ]

        appendPopupsAndCheckActivePopupHeight(
            popups: popups,
            gestureTranslation: 31,
            expectedValue: fullscreenHeight
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenGestureIsNegative_hasDragHeightStored_twoPopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 500, popupDragHeight: 100)
        ]

        appendPopupsAndCheckActivePopupHeight(
            popups: popups,
            gestureTranslation: -93,
            expectedValue: 500 + 100 + 93
        )
    }
    func test_calculateActivePopupHeight_withAutoHeightMode_whenGestureIsPositive_hasDragHeightStored_onePopupStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1300, popupDragHeight: 100)
        ]

        appendPopupsAndCheckActivePopupHeight(
            popups: popups,
            gestureTranslation: 350,
            expectedValue: fullscreenHeight - screen.safeArea.top
        )
    }
}
private extension PopupStackViewModelTests {
    func appendPopupsAndCheckActivePopupHeight(popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: CGFloat) {
        appendPopupsAndPerformChecks(
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { $0 },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Offset
extension PopupStackViewModelTests {
    func test_calculateOffsetY_withZeroGestureTranslation_fivePopupsStacked_thirdElement() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 240),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 670),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 310)
        ]

        XCTAssertEqual(
            testHook.calculatePopupOffsetY(for: bottomViewModel.popups[2]),
            -testHook.stackOffset * 2
        )
    }
    func test_calculateOffsetY_withZeroGestureTranslation_fivePopupsStacked_lastElement() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 350),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 240),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 670),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 310)
        ]

        XCTAssertEqual(
            testHook.calculatePopupOffsetY(for: bottomViewModel.popups[4]),
            0
        )
    }
    func test_calculateOffsetY_withNegativeGestureTranslation_dragHeight_onePopupStacked() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 350, popupDragHeight: 100)
        ]
        bottomViewModel.gestureTranslation = -100

        XCTAssertEqual(
            testHook.calculatePopupOffsetY(for: bottomViewModel.popups[0]),
            0
        )
    }
    func test_calculateOffsetY_withPositiveGestureTranslation_dragHeight_twoPopupsStacked_firstElement() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 350, popupDragHeight: 249),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 133, popupDragHeight: 21)
        ]
        bottomViewModel.gestureTranslation = 100

        XCTAssertEqual(
            testHook.calculatePopupOffsetY(for: bottomViewModel.popups[0]),
            -testHook.stackOffset
        )
    }
    func test_calculateOffsetY_withPositiveGestureTranslation_dragHeight_twoPopupsStacked_lastElement() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 350, popupDragHeight: 249),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 133, popupDragHeight: 21)
        ]
        bottomViewModel.gestureTranslation = 100

        XCTAssertEqual(
            testHook.calculatePopupOffsetY(for: bottomViewModel.popups[1]),
            100 - 21
        )
    }
    func test_calculateOffsetY_withStackingDisabled() {
        bottomViewModel.popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 350, popupDragHeight: 249),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 133, popupDragHeight: 21)
        ]
        ConfigContainer.vertical.isStackingPossible = false

        XCTAssertEqual(
            testHook.calculatePopupOffsetY(for: bottomViewModel.popups[0]),
            0
        )
    }
}

// MARK: Popup Padding
extension PopupStackViewModelTests {
    func test_calculatePopupPaddings_withAutoHeightMode_whenLessThanScreen() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 344, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        appendPopupsAndCheckPopupPadding(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 12, leading: 17, bottom: 33, trailing: 17)
        )
    }
    func test_calculatePopupPaddings_withAutoHeightMode_almostLikeScreen_onlyOnePaddingShouldBeNonZero() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 877, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        appendPopupsAndCheckPopupPadding(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 17, bottom: 23, trailing: 17)
        )
    }
    func test_calculatePopupPaddings_withAutoHeightMode_almostLikeScreen_bothPaddingsShouldBeNonZero() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 861, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        appendPopupsAndCheckPopupPadding(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 6, leading: 17, bottom: 33, trailing: 17)
        )
    }
    func test_calculatePopupPaddings_withAutoHeightMode_whenBiggerThanScreen() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1100, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        appendPopupsAndCheckPopupPadding(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 17, bottom: 0, trailing: 17)
        )
    }
    func test_calculatePopupPaddings_withLargeHeightMode() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .large, popupHeight: 344, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        appendPopupsAndCheckPopupPadding(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 17, bottom: 0, trailing: 17)
        )
    }
    func test_calculatePopupPaddings_withFullscreenHeightMode() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 344, popupPadding: .init(top: 12, leading: 17, bottom: 33, trailing: 17))
        ]

        appendPopupsAndCheckPopupPadding(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 17, bottom: 0, trailing: 17)
        )
    }
}
private extension PopupStackViewModelTests {
    func appendPopupsAndCheckPopupPadding(popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: EdgeInsets) {
        appendPopupsAndPerformChecks(
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { [self] _ in testHook.calculatePopupPadding() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Body Padding
extension PopupStackViewModelTests {
    func test_calculateBodyPadding_withDefaultSettings() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 350)
        ]

        appendPopupsAndCheckBodyPadding(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: screen.safeArea.top, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateBodyPadding_withIgnoringSafeArea_bottom() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 200, ignoredSafeAreaEdges: .bottom)
        ]

        appendPopupsAndCheckBodyPadding(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: screen.safeArea.leading, bottom: 0, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateBodyPadding_withIgnoringSafeArea_all() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1200, ignoredSafeAreaEdges: .all)
        ]

        appendPopupsAndCheckBodyPadding(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        )
    }
    func test_calculateBodyPadding_withPopupPadding() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1200, popupPadding: .init(top: 21, leading: 12, bottom: 37, trailing: 12))
        ]

        appendPopupsAndCheckBodyPadding(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateBodyPadding_withFullscreenHeightMode_ignoringSafeArea_top() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 100, ignoredSafeAreaEdges: .top)
        ]

        appendPopupsAndCheckBodyPadding(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: .init(top: 0, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateBodyPadding_withGestureTranslation() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 800)
        ]

        appendPopupsAndCheckBodyPadding(
            popups: popups,
            gestureTranslation: -300,
            expectedValue: .init(top: screen.safeArea.top, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
    func test_calculateBodyPadding_withGestureTranslation_dragHeight() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300, popupDragHeight: 700)
        ]

        appendPopupsAndCheckBodyPadding(
            popups: popups,
            gestureTranslation: 21,
            expectedValue: .init(top: screen.safeArea.top - 21, leading: screen.safeArea.leading, bottom: screen.safeArea.bottom, trailing: screen.safeArea.trailing)
        )
    }
}
private extension PopupStackViewModelTests {
    func appendPopupsAndCheckBodyPadding(popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: EdgeInsets) {
        appendPopupsAndPerformChecks(
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { [self] _ in testHook.calculateBodyPadding(for: popups.last!) },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Translation Progress
extension PopupStackViewModelTests {
    func test_calculateTranslationProgress_withNoGestureTranslation() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300)
        ]

        appendPopupsAndCheckTranslationProgress(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: 0
        )
    }
    func test_calculateTranslationProgress_withPositiveGestureTranslation() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300)
        ]

        appendPopupsAndCheckTranslationProgress(
            popups: popups,
            gestureTranslation: 250,
            expectedValue: 250 / 300
        )
    }
    func test_calculateTranslationProgress_withPositiveGestureTranslation_dragHeight() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300, popupDragHeight: 120)
        ]

        appendPopupsAndCheckTranslationProgress(
            popups: popups,
            gestureTranslation: 250,
            expectedValue: (250 - 120) / 300
        )
    }
    func test_calculateTranslationProgress_withNegativeGestureTranslation() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300)
        ]

        appendPopupsAndCheckTranslationProgress(
            popups: popups,
            gestureTranslation: -175,
            expectedValue: 0
        )
    }
}
private extension PopupStackViewModelTests {
    func appendPopupsAndCheckTranslationProgress(popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: CGFloat) {
        appendPopupsAndPerformChecks(
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { [self] _ in testHook.calculateTranslationProgress() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Corner Radius
extension PopupStackViewModelTests {
    func test_calculateCornerRadius_withTwoPopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300, cornerRadius: 1),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300, cornerRadius: 12)
        ]

        appendPopupsAndCheckCornerRadius(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 12, .bottom: 0]
        )
    }
    func test_calculateCornerRadius_withPopupPadding_bottom_first() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300, popupPadding: .init(top: 0, leading: 0, bottom: 12, trailing: 0), cornerRadius: 1),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300, cornerRadius: 12)
        ]

        appendPopupsAndCheckCornerRadius(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 12, .bottom: 0]
        )
    }
    func test_calculateCornerRadius_withPopupPadding_bottom_last() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300, cornerRadius: 1),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300, popupPadding: .init(top: 0, leading: 0, bottom: 12, trailing: 0), cornerRadius: 12)
        ]

        appendPopupsAndCheckCornerRadius(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 12, .bottom: 12]
        )
    }
    func test_calculateCornerRadius_withPopupPadding_all() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300, cornerRadius: 1),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300, popupPadding: .init(top: 12, leading: 24, bottom: 12, trailing: 24), cornerRadius: 12)
        ]

        appendPopupsAndCheckCornerRadius(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 12, .bottom: 12]
        )
    }
    func test_calculateCornerRadius_fullscreen() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 300, cornerRadius: 13)
        ]

        appendPopupsAndCheckCornerRadius(
            popups: popups,
            gestureTranslation: 0,
            expectedValue: [.top: 0, .bottom: 0]
        )
    }
}
private extension PopupStackViewModelTests {
    func appendPopupsAndCheckCornerRadius(popups: [AnyPopup], gestureTranslation: CGFloat, expectedValue: [MijickPopups.VerticalEdge: CGFloat]) {
        appendPopupsAndPerformChecks(
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { [self] _ in testHook.calculateCornerRadius() },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Scale X
extension PopupStackViewModelTests {
    func test_calculateScaleX_withNoGestureTranslation_threePopupsStacked_last() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 360)
        ]

        appendPopupsAndCheckScaleX(
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 2,
            expectedValueBuilder: {_ in 1 }
        )
    }
    func test_calculateScaleX_withNoGestureTranslation_fourPopupsStacked_second() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 360),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1360)
        ]

        appendPopupsAndCheckScaleX(
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 1,
            expectedValueBuilder: { 1 - $0.testHook.stackScaleFactor * 2 }
        )
    }
    func test_calculateScaleX_withNegativeGestureTranslation_fourPopupsStacked_third() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 360),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1360)
        ]

        appendPopupsAndCheckScaleX(
            popups: popups,
            gestureTranslation: -100,
            calculateForIndex: 2,
            expectedValueBuilder: { 1 - $0.testHook.stackScaleFactor * 1 }
        )
    }
    func test_calculateScaleX_withPositiveGestureTranslation_fivePopupsStacked_second() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 300),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 120),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 360),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 123)
        ]

        appendPopupsAndCheckScaleX(
            popups: popups,
            gestureTranslation: 100,
            calculateForIndex: 1,
            expectedValueBuilder: { 1 - $0.testHook.stackScaleFactor * 3 * max(1 - $0.testHook.calculateTranslationProgress(), $0.testHook.minScaleProgressMultiplier) }
        )
    }
}
private extension PopupStackViewModelTests {
    func appendPopupsAndCheckScaleX(popups: [AnyPopup], gestureTranslation: CGFloat, calculateForIndex index: Int, expectedValueBuilder: @escaping (ViewModel) -> CGFloat) {
        appendPopupsAndPerformChecks(
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { [self] _ in testHook.calculateScaleX(for: bottomViewModel.popups[index]) },
            expectedValueBuilder: expectedValueBuilder
        )
    }
}

// MARK: Fixed Size
extension PopupStackViewModelTests {
    func test_calculateFixedSize_withAutoHeightMode_whenLessThanScreen_twoPopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 123)
        ]

        appendPopupsAndCheckVerticalFixedSize(
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 1,
            expectedValue: true
        )
    }
    func test_calculateFixedSize_withAutoHeightMode_whenBiggerThanScreen_twoPopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1223)
        ]

        appendPopupsAndCheckVerticalFixedSize(
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 1,
            expectedValue: false
        )
    }
    func test_calculateFixedSize_withLargeHeightMode_threePopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1223),
            createPopupInstanceForPopupHeightTests(heightMode: .large, popupHeight: 1223)
        ]

        appendPopupsAndCheckVerticalFixedSize(
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 2,
            expectedValue: false
        )
    }
    func test_calculateFixedSize_withFullscreenHeightMode_fivePopupsStacked() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1223),
            createPopupInstanceForPopupHeightTests(heightMode: .large, popupHeight: 1223),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1223),
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 1223)
        ]

        appendPopupsAndCheckVerticalFixedSize(
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 4,
            expectedValue: false
        )
    }
}
private extension PopupStackViewModelTests {
    func appendPopupsAndCheckVerticalFixedSize(popups: [AnyPopup], gestureTranslation: CGFloat, calculateForIndex index: Int, expectedValue: Bool) {
        appendPopupsAndPerformChecks(
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { [self] _ in testHook.calculateVerticalFixedSize(for: bottomViewModel.popups[index]) },
            expectedValueBuilder: { _ in expectedValue }
        )
    }
}

// MARK: Stack Overlay Opacity
extension PopupStackViewModelTests {
    func test_calculateStackOverlayOpacity_withThreePopupsStacked_whenNoGestureTranslation_last() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 512)
        ]

        appendPopupsAndCheckStackOverlayOpacity(
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 2,
            expectedValueBuilder: { _ in 0 }
        )
    }
    func test_calculateStackOverlayOpacity_withFourPopupsStacked_whenNoGestureTranslation_second() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 512),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 812)
        ]

        appendPopupsAndCheckStackOverlayOpacity(
            popups: popups,
            gestureTranslation: 0,
            calculateForIndex: 1,
            expectedValueBuilder: { $0.testHook.stackOverlayFactor * 2 }
        )
    }
    func test_calculateStackOverlayOpacity_withFourPopupsStacked_whenGestureTranslationIsNegative_last() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 512),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 812)
        ]

        appendPopupsAndCheckStackOverlayOpacity(
            popups: popups,
            gestureTranslation: -123,
            calculateForIndex: 3,
            expectedValueBuilder: { _ in 0 }
        )
    }
    func test_calculateStackOverlayOpacity_withTenPopupsStacked_whenGestureTranslationIsNegative_first() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 55),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 512),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 812),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 34),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 664),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 754),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 357),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 1234),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 356)
        ]

        appendPopupsAndCheckStackOverlayOpacity(
            popups: popups,
            gestureTranslation: -123,
            calculateForIndex: 0,
            expectedValueBuilder: { min($0.testHook.stackOverlayFactor * 9, $0.testHook.maxStackOverlayFactor) }
        )
    }
    func test_calculateStackOverlayOpacity_withThreePopupsStacked_whenGestureTranslationIsPositive_last() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 512)
        ]

        appendPopupsAndCheckStackOverlayOpacity(
            popups: popups,
            gestureTranslation: 494,
            calculateForIndex: 2,
            expectedValueBuilder: { _ in 0 }
        )
    }
    func test_calculateStackOverlayOpacity_withFourPopupsStacked_whenGestureTranslationIsPositive_nextToLast() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .fullscreen, popupHeight: 1360),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 233),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 512),
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 343)
        ]

        appendPopupsAndCheckStackOverlayOpacity(
            popups: popups,
            gestureTranslation: 241,
            calculateForIndex: 2,
            expectedValueBuilder: { (1 - $0.testHook.calculateTranslationProgress()) * $0.stackOverlayFactor }
        )
    }
}
private extension PopupStackViewModelTests {
    func appendPopupsAndCheckStackOverlayOpacity(popups: [AnyPopup], gestureTranslation: CGFloat, calculateForIndex index: Int, expectedValueBuilder: @escaping (ViewModel) -> CGFloat) {
        appendPopupsAndPerformChecks(
            popups: popups,
            gestureTranslation: gestureTranslation,
            calculatedValue: { [self] _ in testHook.calculateStackOverlayOpacity(for: bottomViewModel.popups[index]) },
            expectedValueBuilder: expectedValueBuilder
        )
    }
}

// MARK: On Drag Gesture Changed
extension PopupStackViewModelTests {
    func test_calculateValuesOnDragGestureChanged_withPositiveDragValue_whenDragGestureDisabled() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 344, dragGestureEnabled: false)
        ]

        appendPopupsAndCheckGestureTranslationOnChange(
            popups: popups,
            gestureValue: 11,
            dragGestureEnabled: false,
            expectedValues: (popupHeight: 344, gestureTranslation: 0)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withPositiveDragValue_whenDragGestureEnabled() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 344)
        ]

        appendPopupsAndCheckGestureTranslationOnChange(
            popups: popups,
            gestureValue: 11,
            dragGestureEnabled: true,
            expectedValues: (popupHeight: 344, gestureTranslation: 11)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withNegativeDragValue_whenNoDragDetents() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 344, dragDetents: [])
        ]

        appendPopupsAndCheckGestureTranslationOnChange(
            popups: popups,
            gestureValue: -133,
            dragGestureEnabled: true,
            expectedValues: (popupHeight: 344, gestureTranslation: 0)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withNegativeDragValue_whenDragDetents() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 344, dragDetents: [.fixed(450)])
        ]

        appendPopupsAndCheckGestureTranslationOnChange(
            popups: popups,
            gestureValue: -40,
            dragGestureEnabled: true,
            expectedValues: (popupHeight: 384, gestureTranslation: -40)
        )
    }
    func test_calculateValuesOnDragGestureChanged_withNegativeDragValue_whenDragDetentsLessThanDragValue() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 344, dragDetents: [.fixed(370)])
        ]

        appendPopupsAndCheckGestureTranslationOnChange(
            popups: popups,
            gestureValue: -133,
            dragGestureEnabled: true,
            expectedValues: (popupHeight: 370 + testHook.dragTranslationThreshold, gestureTranslation: 344 - 370 - testHook.dragTranslationThreshold)
        )
    }
}
private extension PopupStackViewModelTests {
    func appendPopupsAndCheckGestureTranslationOnChange(popups: [AnyPopup], gestureValue: CGFloat, dragGestureEnabled: Bool, expectedValues: (popupHeight: CGFloat, gestureTranslation: CGFloat)) {
        bottomViewModel.popups = popups
        bottomViewModel.popups = recalculatePopupHeights()
        testHook.onPopupDragGestureChanged(gestureValue)

        let expect = expectation(description: "results")
        bottomViewModel.$activePopupHeight
            .receive(on: RunLoop.main)
            .dropFirst(dragGestureEnabled ? 3 : 2)
            .sink { [self] _ in
                XCTAssertEqual(bottomViewModel.activePopupHeight, expectedValues.popupHeight)
                XCTAssertEqual(bottomViewModel.gestureTranslation, expectedValues.gestureTranslation)
                expect.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expect], timeout: 3)
    }
}

// MARK: On Drag Gesture Ended
extension PopupStackViewModelTests {
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenNoDragDetents() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 344)
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            popups: popups,
            gestureValue: -200,
            expectedValues: (popupHeight: 344, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_1() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 344, dragDetents: [.fixed(440)])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            popups: popups,
            gestureValue: -200,
            expectedValues: (popupHeight: 440, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_2() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 344, dragDetents: [.fixed(440), .fixed(520)])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            popups: popups,
            gestureValue: -120,
            expectedValues: (popupHeight: 520, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_3() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 344, dragDetents: [.fixed(440), .fixed(520)])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            popups: popups,
            gestureValue: -42,
            expectedValues: (popupHeight: 440, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_4() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 344, dragDetents: [.fixed(440), .fixed(520), .large, .fullscreen])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            popups: popups,
            gestureValue: -300,
            expectedValues: (popupHeight: fullscreenHeight - screen.safeArea.top, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withNegativeDragValue_whenDragDetentsSet_5() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 344, dragDetents: [.fixed(440), .fixed(520), .large, .fullscreen])
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            popups: popups,
            gestureValue: -600,
            expectedValues: (popupHeight: fullscreenHeight, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withPositiveDragValue_1() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 400)
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            popups: popups,
            gestureValue: 50,
            expectedValues: (popupHeight: 400, shouldPopupBeDismissed: false)
        )
    }
    func test_calculateValuesOnDragGestureEnded_withPositiveDragValue_2() {
        let popups = [
            createPopupInstanceForPopupHeightTests(heightMode: .auto, popupHeight: 400)
        ]

        appendPopupsAndCheckGestureTranslationOnEnd(
            popups: popups,
            gestureValue: 300,
            expectedValues: (popupHeight: 400, shouldPopupBeDismissed: true)
        )
    }
}
private extension PopupStackViewModelTests {
    func appendPopupsAndCheckGestureTranslationOnEnd(popups: [AnyPopup], gestureValue: CGFloat, expectedValues: (popupHeight: CGFloat, shouldPopupBeDismissed: Bool)) {
        bottomViewModel.popups = popups
        bottomViewModel.popups = recalculatePopupHeights()
        bottomViewModel.gestureTranslation = gestureValue
        testHook.recalculateTranslationProgress()
        testHook.onPopupDragGestureEnded(gestureValue)

        let expect = expectation(description: "results")
        bottomViewModel.$activePopupHeight
            .dropFirst(expectedValues.shouldPopupBeDismissed ? 4 : 6)
            .sink { [self] _ in
                XCTAssertEqual(bottomViewModel.popups.count, expectedValues.shouldPopupBeDismissed ? 0 : 1)
                XCTAssertEqual(bottomViewModel.activePopupHeight, expectedValues.popupHeight)
                expect.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expect], timeout: 3)
    }
}



// MARK: - Helpers



// MARK: Methods
private extension PopupStackViewModelTests {
    func createPopupInstanceForPopupHeightTests(heightMode: HeightMode, popupHeight: CGFloat, popupDragHeight: CGFloat? = nil, ignoredSafeAreaEdges: Edge.Set = [], popupPadding: EdgeInsets = .init(), cornerRadius: CGFloat = 0, dragGestureEnabled: Bool = true, dragDetents: [DragDetent] = []) -> AnyPopup {
        let config = getConfigForPopupHeightTests(heightMode: heightMode, ignoredSafeAreaEdges: ignoredSafeAreaEdges, popupPadding: popupPadding, cornerRadius: cornerRadius, dragGestureEnabled: dragGestureEnabled, dragDetents: dragDetents)

        var popup = AnyPopup(config: config)
        popup.height = popupHeight
        popup.dragHeight = popupDragHeight
        return popup
    }
    func appendPopupsAndPerformChecks<Value: Equatable>(popups: [AnyPopup], gestureTranslation: CGFloat, calculatedValue: @escaping (CGFloat?) -> (Value), expectedValueBuilder: @escaping (ViewModel) -> Value) {
        bottomViewModel.popups = popups
        bottomViewModel.popups = recalculatePopupHeights()
        bottomViewModel.gestureTranslation = gestureTranslation

        let expect = expectation(description: "results")
        bottomViewModel.$activePopupHeight
            .receive(on: RunLoop.main)
            .dropFirst(3)
            .sink { [self] in
                XCTAssertEqual(calculatedValue($0), expectedValueBuilder(bottomViewModel))
                expect.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expect], timeout: 3)
    }
}
private extension PopupStackViewModelTests {
    func getConfigForPopupHeightTests(heightMode: HeightMode, ignoredSafeAreaEdges: Edge.Set, popupPadding: EdgeInsets, cornerRadius: CGFloat, dragGestureEnabled: Bool, dragDetents: [DragDetent]) -> Config { .init(
        cornerRadius: cornerRadius,
        ignoredSafeAreaEdges: ignoredSafeAreaEdges,
        heightMode: heightMode,
        popupPadding: popupPadding,
        dragGestureEnabled: dragGestureEnabled,
        dragDetents: dragDetents
    )}
    func recalculatePopupHeights() -> [AnyPopup] { bottomViewModel.popups.map {
        var popup = $0
        popup.height = testHook.calculatePopupHeight(height: $0.height!, popupConfig: $0.config as! Config)
        return popup
    }}
}

// MARK: Screen
private extension PopupStackViewModelTests {
    var screen: ScreenProperties { .init(
        height: 1000,
        safeArea: .init(top: 100, leading: 20, bottom: 50, trailing: 30)
    )}
    var fullscreenHeight: CGFloat { screen.height }
    var largeScreenHeight: CGFloat { fullscreenHeight - screen.safeArea.top }
}

// MARK: Typealiases
private extension PopupStackViewModelTests {
    typealias Config = LocalConfig.Vertical
    typealias ViewModel = PopupStackView<Config>.ViewModel

    var testHook: PopupStackView<Config>.ViewModel.TestHook { bottomViewModel.testHook }
}