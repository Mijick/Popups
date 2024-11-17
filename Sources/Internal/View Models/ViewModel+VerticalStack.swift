//
//  ViewModel+VerticalStack.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

extension VM { class VerticalStack: ViewModel { required init() {}
    var alignment: PopupAlignment = .center
    var popups: [AnyPopup] = []
    var activePopupProperties: ActivePopupProperties = .init()
    var screen: Screen = .init()
    var updatePopupAction: ((AnyPopup) async -> ())!
    var closePopupAction: ((AnyPopup) async -> ())!
}}



// MARK: - METHODS / VIEW MODEL / ACTIVE POPUP



// MARK: Height
extension VM.VerticalStack {
    func calculateActivePopupHeight() async -> CGFloat? {
        guard let activePopupHeight = popups.last?.height, let activePopupDragHeight = popups.last?.dragHeight else { return nil }

        let popupHeightFromGestureTranslation = activePopupHeight + activePopupDragHeight + activePopupProperties.gestureTranslation * getDragTranslationMultiplier()

        let newHeightCandidate = max(activePopupHeight, popupHeightFromGestureTranslation)
        return min(newHeightCandidate, screen.height)
    }
}
private extension VM.VerticalStack {
    func getDragTranslationMultiplier() -> CGFloat { switch alignment {
        case .top: 1
        case .bottom: -1
        case .center: fatalError()
    }}
}

// MARK: Outer Padding
extension VM.VerticalStack {
    func calculateActivePopupOuterPadding() async -> EdgeInsets { guard let activePopupConfig = popups.last?.config else { return .init() }; return .init(
        top: calculateVerticalOuterPadding(for: .top, activePopupConfig: activePopupConfig),
        leading: calculateLeadingOuterPadding(activePopupConfig: activePopupConfig),
        bottom: calculateVerticalOuterPadding(for: .bottom, activePopupConfig: activePopupConfig),
        trailing: calculateTrailingOuterPadding(activePopupConfig: activePopupConfig)
    )}
}
private extension VM.VerticalStack {
    func calculateVerticalOuterPadding(for edge: PopupAlignment, activePopupConfig: AnyPopupConfig) -> CGFloat {
        let largeScreenHeight = calculateLargeScreenHeight(),
            activePopupHeight = activePopupProperties.height ?? 0,
            priorityPopupPaddingValue = calculatePriorityOuterPaddingValue(for: edge, activePopupConfig: activePopupConfig),
            remainingHeight = largeScreenHeight - activePopupHeight - priorityPopupPaddingValue

        let popupPaddingCandidate = min(remainingHeight, activePopupConfig.popupPadding[edge])
        return max(popupPaddingCandidate, 0)
    }
    func calculateLeadingOuterPadding(activePopupConfig: AnyPopupConfig) -> CGFloat {
        activePopupConfig.popupPadding.leading
    }
    func calculateTrailingOuterPadding(activePopupConfig: AnyPopupConfig) -> CGFloat {
        activePopupConfig.popupPadding.trailing
    }
}
private extension VM.VerticalStack {
    func calculatePriorityOuterPaddingValue(for edge: PopupAlignment, activePopupConfig: AnyPopupConfig) -> CGFloat { switch edge == alignment {
        case true: 0
        case false: activePopupConfig.popupPadding[!edge]
    }}
}

// MARK: Inner Padding
extension VM.VerticalStack {
    func calculateActivePopupInnerPadding() async -> EdgeInsets { guard let popup = popups.last else { return .init() }; return .init(
        top: calculateTopInnerPadding(popup: popup),
        leading: calculateLeadingInnerPadding(popup: popup),
        bottom: calculateBottomInnerPadding(popup: popup),
        trailing: calculateTrailingInnerPadding(popup: popup)
    )}
}
private extension VM.VerticalStack {
    func calculateTopInnerPadding(popup: AnyPopup) -> CGFloat {
        if popup.config.ignoredSafeAreaEdges.contains(.top) { return 0 }

        return switch alignment {
            case .top: calculateVerticalInnerPaddingAdhereEdge(safeAreaHeight: screen.safeArea.top, popupOuterPadding: activePopupProperties.outerPadding.top)
            case .bottom: calculateVerticalInnerPaddingCounterEdge(popupHeight: activePopupProperties.height ?? 0, safeArea: screen.safeArea.top)
            case .center: fatalError()
        }
    }
    func calculateBottomInnerPadding(popup: AnyPopup) -> CGFloat {
        if popup.config.ignoredSafeAreaEdges.contains(.bottom) && !screen.isKeyboardActive { return 0 }

        return switch alignment {
            case .top: calculateVerticalInnerPaddingCounterEdge(popupHeight: activePopupProperties.height ?? 0, safeArea: screen.safeArea.bottom)
            case .bottom: calculateVerticalInnerPaddingAdhereEdge(safeAreaHeight: screen.safeArea.bottom, popupOuterPadding: activePopupProperties.outerPadding.bottom)
            case .center: fatalError()
        }
    }
    func calculateLeadingInnerPadding(popup: AnyPopup) -> CGFloat { switch popup.config.ignoredSafeAreaEdges.contains(.leading) {
        case true: 0
        case false: screen.safeArea.leading
    }}
    func calculateTrailingInnerPadding(popup: AnyPopup) -> CGFloat { switch popup.config.ignoredSafeAreaEdges.contains(.trailing) {
        case true: 0
        case false: screen.safeArea.trailing
    }}
}
private extension VM.VerticalStack {
    func calculateVerticalInnerPaddingCounterEdge(popupHeight: CGFloat, safeArea: CGFloat) -> CGFloat {
        let paddingValueCandidate = safeArea + popupHeight - screen.height
        return max(paddingValueCandidate, 0)
    }
    func calculateVerticalInnerPaddingAdhereEdge(safeAreaHeight: CGFloat, popupOuterPadding: CGFloat) -> CGFloat {
        let paddingValueCandidate = safeAreaHeight - popupOuterPadding
        return max(paddingValueCandidate, 0)
    }
}

// MARK: Corners
extension VM.VerticalStack {
    func calculateActivePopupCorners() async -> [PopupAlignment: CGFloat] { guard let activePopup = popups.last else { return [.top: 0, .bottom: 0] }
        let cornerRadiusValue = calculateCornerRadiusValue(activePopup)
        return [
            .top: calculateTopCornerRadius(cornerRadiusValue),
            .bottom: calculateBottomCornerRadius(cornerRadiusValue)
        ]
    }
}
private extension VM.VerticalStack {
    func calculateCornerRadiusValue(_ activePopup: AnyPopup) -> CGFloat { switch activePopup.config.heightMode {
        case .auto, .large: activePopup.config.cornerRadius
        case .fullscreen: 0
    }}
    func calculateTopCornerRadius(_ cornerRadiusValue: CGFloat) -> CGFloat { switch alignment {
        case .top: activePopupProperties.outerPadding.top != 0 ? cornerRadiusValue : 0
        case .bottom: cornerRadiusValue
        case .center: fatalError()
    }}
    func calculateBottomCornerRadius(_ cornerRadiusValue: CGFloat) -> CGFloat { switch alignment {
        case .top: cornerRadiusValue
        case .bottom: activePopupProperties.outerPadding.bottom != 0 ? cornerRadiusValue : 0
        case .center: fatalError()
    }}
}

// MARK: Vertical Fixed Size
extension VM.VerticalStack {
    func calculateActivePopupVerticalFixedSize() async -> Bool { guard let popup = popups.last else { return true }; return switch popup.config.heightMode {
        case .fullscreen, .large: false
        case .auto: activePopupProperties.height != calculateLargeScreenHeight()
    }}
}

// MARK: Translation Progress
extension VM.VerticalStack {
    func calculateActivePopupTranslationProgress() async -> CGFloat { guard let activePopupHeight = popups.last?.height else { return 0 }; return switch alignment {
        case .top: abs(min(activePopupProperties.gestureTranslation + (popups.last?.dragHeight ?? 0), 0)) / activePopupHeight
        case .bottom: max(activePopupProperties.gestureTranslation - (popups.last?.dragHeight ?? 0), 0) / activePopupHeight
        case .center: fatalError()
    }}
}



// MARK: - METHODS / VIEW MODEL / SELECTED POPUP



// MARK: Height
extension VM.VerticalStack {
    func calculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat {
        guard activePopupProperties.gestureTranslation.isZero else { return popup.height ?? 0 }

        let popupHeight = calculateNewPopupHeight(heightCandidate, popup.config)
        return popupHeight
    }
}
private extension VM.VerticalStack {
    func calculateNewPopupHeight(_ heightCandidate: CGFloat, _ popupConfig: AnyPopupConfig) -> CGFloat { switch popupConfig.heightMode {
        case .auto: min(heightCandidate, calculateLargeScreenHeight())
        case .large: calculateLargeScreenHeight()
        case .fullscreen: getFullscreenHeight()
    }}
}
private extension VM.VerticalStack {
    func calculateLargeScreenHeight() -> CGFloat {
        let fullscreenHeight = getFullscreenHeight(),
            safeAreaHeight = screen.safeArea[!alignment],
            stackHeight = calculateStackHeight()
        return fullscreenHeight - safeAreaHeight - stackHeight
    }
    func getFullscreenHeight() -> CGFloat {
        screen.height
    }
}
private extension VM.VerticalStack {
    func calculateStackHeight() -> CGFloat {
        let numberOfStackedItems = max(popups.count - 1, 0),
            numberOfVisibleItems = min(numberOfStackedItems, maxNumberOfVisiblePopups)

        let stackedItemsHeight = stackOffset * .init(numberOfVisibleItems)
        return stackedItemsHeight
    }
}



// MARK: - METHODS / VIEW



// MARK: Is Popup Active
extension VM.VerticalStack {
    @MainActor func isPopupActive(_ popup: AnyPopup) -> Bool {
        popups.getInvertedIndex(of: popup) < maxNumberOfVisiblePopups
    }
}

// MARK: Offset Y
extension VM.VerticalStack {
    @MainActor func calculateOffsetY(for popup: AnyPopup) -> CGFloat { switch popup == popups.last {
        case true: calculateOffsetForActivePopup()
        case false: calculateOffsetForStackedPopup(popup)
    }}
}
private extension VM.VerticalStack {
    func calculateOffsetForActivePopup() -> CGFloat {
        let lastPopupDragHeight = popups.last?.dragHeight ?? 0

        return switch alignment {
            case .top: min(activePopupProperties.gestureTranslation + lastPopupDragHeight, 0)
            case .bottom: max(activePopupProperties.gestureTranslation - lastPopupDragHeight, 0)
            case .center: fatalError()
        }
    }
    func calculateOffsetForStackedPopup(_ popup: AnyPopup) -> CGFloat {
        let invertedIndex = popups.getInvertedIndex(of: popup)
        let offsetValue = stackOffset * .init(invertedIndex)
        let alignmentMultiplier = switch alignment {
            case .top: 1.0
            case .bottom: -1.0
            case .center: fatalError()
        }

        return offsetValue * alignmentMultiplier
    }
}

// MARK: Scale X
extension VM.VerticalStack {
    @MainActor func calculateScaleX(for popup: AnyPopup) -> CGFloat {
        guard popup != popups.last else { return 1 }

        let invertedIndex = popups.getInvertedIndex(of: popup),
            remainingTranslationProgress = 1 - activePopupProperties.translationProgress

        let progressMultiplier = invertedIndex == 1 ? remainingTranslationProgress : max(minScaleProgressMultiplier, remainingTranslationProgress)
        let scaleValue = .init(invertedIndex) * stackScaleFactor * progressMultiplier
        return 1 - scaleValue
    }
}

// MARK: Z Index
extension VM.VerticalStack {
    @MainActor func calculateZIndex() -> CGFloat {
        popups.last == nil ? 2137 : .init(popups.count)
    }
}

// MARK: - Stack Overlay Opacity
extension VM.VerticalStack {
    @MainActor func calculateStackOverlayOpacity(for popup: AnyPopup) -> CGFloat {
        guard popup != popups.last else { return 0 }

        let invertedIndex = popups.getInvertedIndex(of: popup),
            remainingTranslationProgress = 1 - activePopupProperties.translationProgress

        let progressMultiplier = invertedIndex == 1 ? remainingTranslationProgress : max(minStackOverlayProgressMultiplier, remainingTranslationProgress)
        let overlayValue = stackOverlayFactor * .init(invertedIndex)

        let opacity = overlayValue * progressMultiplier
        return max(opacity, 0)
    }
}

// MARK: Attributes
extension VM.VerticalStack {
    var stackScaleFactor: CGFloat { 0.025 }
    var stackOverlayFactor: CGFloat { 0.2 }
    var stackOffset: CGFloat { GlobalConfigContainer.vertical.isStackingEnabled ? 8 : 0 }
    var dragThreshold: CGFloat { GlobalConfigContainer.vertical.dragThreshold }
    var dragGestureEnabled: Bool { popups.last?.config.isDragGestureEnabled ?? false }
    var dragTranslationThreshold: CGFloat { 32 }
    var minScaleProgressMultiplier: CGFloat { 0.7 }
    var minStackOverlayProgressMultiplier: CGFloat { 0.6 }
    var maxNumberOfVisiblePopups: Int { 3 }
}



// MARK: - GESTURES



// MARK: On Changed
extension VM.VerticalStack {
    @MainActor func onPopupDragGestureChanged(_ value: CGFloat) async {
        guard dragGestureEnabled else { return }
        
        let newGestureTranslation = await calculateGestureTranslation(value)
        await updateGestureTranslation(newGestureTranslation)
    }
}
private extension VM.VerticalStack {
    func calculateGestureTranslation(_ value: CGFloat) async -> CGFloat { switch popups.last?.config.dragDetents.isEmpty ?? true {
        case true: calculateGestureTranslationWhenNoDragDetents(value)
        case false: calculateGestureTranslationWhenDragDetents(value)
    }}
}
private extension VM.VerticalStack {
    func calculateGestureTranslationWhenNoDragDetents(_ value: CGFloat) -> CGFloat {
        calculateDragExtremeValue(value, 0)
    }
    func calculateGestureTranslationWhenDragDetents(_ value: CGFloat) -> CGFloat {
        guard value * getDragTranslationMultiplier() > 0, let activePopup = popups.last, let activePopupHeight = activePopup.height else { return value }

        let maxHeight = calculateMaxHeightForDragGesture(activePopupHeight, activePopup.config)
        let dragTranslation = calculateDragTranslation(maxHeight, activePopupHeight)
        return calculateDragExtremeValue(dragTranslation, value)
    }
}
private extension VM.VerticalStack {
    func calculateMaxHeightForDragGesture(_ activePopupHeight: CGFloat, _ activePopupConfig: AnyPopupConfig) -> CGFloat {
        let maxDragDetent = calculatePopupTargetHeightsFromDragDetents(activePopupHeight, activePopupConfig).max() ?? 0
        let maxHeightCandidate = maxDragDetent + dragTranslationThreshold
        return min(maxHeightCandidate, screen.height)
    }
    func calculateDragTranslation(_ maxHeight: CGFloat, _ activePopupHeight: CGFloat) -> CGFloat {
        let activePopupDragHeight = popups.last?.dragHeight ?? 0
        let translation = maxHeight - activePopupHeight - activePopupDragHeight
        return translation * getDragTranslationMultiplier()
    }
    func calculateDragExtremeValue(_ value1: CGFloat, _ value2: CGFloat) -> CGFloat { switch alignment {
        case .top: min(value1, value2)
        case .bottom: max(value1, value2)
        case .center: fatalError()
    }}
}

// MARK: On Ended
extension VM.VerticalStack {
    @MainActor func onPopupDragGestureEnded(_ value: CGFloat) async { Task {
        guard value != 0, let activePopup = popups.last else { return }

        await dismissLastPopupIfNeeded(activePopup)

        let targetDragHeight = await calculateTargetDragHeight(activePopup)
        await updateGestureTranslation(0)
        await updatePopupDragHeight(targetDragHeight, activePopup)
    }}
}
private extension VM.VerticalStack {
    func dismissLastPopupIfNeeded(_ popup: AnyPopup) async { switch activePopupProperties.translationProgress >= dragThreshold {
        case true: await closePopupAction(popup)
        case false: return
    }}
    func calculateTargetDragHeight(_ activePopup: AnyPopup) async -> CGFloat {
        guard let activePopupHeight = activePopup.height else { return 0 }

        let currentPopupHeight = calculateCurrentPopupHeight(activePopupHeight: activePopupHeight, activePopupDragHeight: activePopup.dragHeight)
        let popupTargetHeights = calculatePopupTargetHeightsFromDragDetents(activePopupHeight, activePopup.config)
        let targetHeight = calculateTargetPopupHeight(activePopupHeight: activePopupHeight, activePopupDragHeight: activePopup.dragHeight, currentPopupHeight: currentPopupHeight, popupTargetHeights: popupTargetHeights)
        let targetDragHeight = calculateTargetDragHeight(targetHeight, activePopupHeight)
        return targetDragHeight
    }
}
private extension VM.VerticalStack {
    func calculateCurrentPopupHeight(activePopupHeight: CGFloat, activePopupDragHeight: CGFloat) -> CGFloat {
        let currentDragHeight = activePopupDragHeight + activePopupProperties.gestureTranslation * getDragTranslationMultiplier()
        let currentPopupHeight = activePopupHeight + currentDragHeight
        return currentPopupHeight
    }
    func calculatePopupTargetHeightsFromDragDetents(_ activePopupHeight: CGFloat, _ activePopupConfig: AnyPopupConfig) -> [CGFloat] {
        activePopupConfig.dragDetents
            .map { switch $0 {
                case .height(let targetHeight): min(targetHeight, calculateLargeScreenHeight())
                case .fraction(let fraction): min(fraction * activePopupHeight, calculateLargeScreenHeight())
                case .large: calculateLargeScreenHeight()
                case .fullscreen: screen.height
            }}
            .modified { $0.append(activePopupHeight) }
            .sorted(by: <)
    }
    func calculateTargetPopupHeight(activePopupHeight: CGFloat, activePopupDragHeight: CGFloat, currentPopupHeight: CGFloat, popupTargetHeights: [CGFloat]) -> CGFloat {
        guard currentPopupHeight < screen.height else { return popupTargetHeights.last ?? 0 }

        let initialIndex = popupTargetHeights.firstIndex { $0 >= currentPopupHeight } ?? popupTargetHeights.count - 1,
            targetIndex = activePopupProperties.gestureTranslation * getDragTranslationMultiplier() > 0 ? initialIndex : max(0, initialIndex - 1)
        let previousPopupHeight = activePopupDragHeight + activePopupHeight,
            popupTargetHeight = popupTargetHeights[targetIndex],
            deltaHeight = abs(previousPopupHeight - popupTargetHeight)
        let progress = abs(currentPopupHeight - previousPopupHeight) / deltaHeight

        if progress < dragThreshold {
            let index = activePopupProperties.gestureTranslation * getDragTranslationMultiplier() > 0 ? max(0, initialIndex - 1) : initialIndex
            return popupTargetHeights[index]
        }
        return popupTargetHeights[targetIndex]
    }
    func calculateTargetDragHeight(_ targetHeight: CGFloat, _ activePopupHeight: CGFloat) -> CGFloat {
        targetHeight - activePopupHeight
    }
}
