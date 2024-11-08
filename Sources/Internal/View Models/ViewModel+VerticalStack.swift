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

extension VM { class VerticalStack: ViewModel {
    // MARK: Overridden Methods
    override func calculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat { await _calculatePopupHeight(heightCandidate, popup) }
    override func calculatePopupPadding() async -> EdgeInsets { await _calculatePopupPadding() }
    override func calculateHeightForActivePopup() async -> CGFloat? { await _calculateHeightForActivePopup() }
    override func calculateCornerRadius() async -> [PopupAlignment: CGFloat] { await _calculateCornerRadius() }
    override func calculateBodyPadding() async -> EdgeInsets { await _calculateBodyPadding() }
    override func calculateTranslationProgress() async -> CGFloat { await _calculateTranslationProgress() }
    override func calculateVerticalFixedSize() async -> Bool { await _calculateVerticalFixedSize() }
}}



// MARK: - VIEW METHODS



// MARK: Popup Height
private extension VM.VerticalStack {
    nonisolated func _calculatePopupHeight(_ heightCandidate: CGFloat, _ popup: AnyPopup) async -> CGFloat {
        guard await gestureTranslation.isZero else { return popup.height ?? 0 }

        let popupHeight = await calculateNewPopupHeight(heightCandidate, popup.config)
        return popupHeight
    }
}
private extension VM.VerticalStack {
    nonisolated func calculateNewPopupHeight(_ heightCandidate: CGFloat, _ popupConfig: AnyPopupConfig) async -> CGFloat { switch popupConfig.heightMode {
        case .auto: await min(heightCandidate, calculateLargeScreenHeight())
        case .large: await calculateLargeScreenHeight()
        case .fullscreen: await getFullscreenHeight()
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
        let numberOfStackedItems = max(popups.count - 1, 0)

        let stackedItemsHeight = stackOffset * .init(numberOfStackedItems)
        return stackedItemsHeight
    }
}

// MARK: Popup Padding
private extension VM.VerticalStack {
    nonisolated func _calculatePopupPadding() async -> EdgeInsets { guard let activePopupConfig = await popups.last?.config else { return .init() }; return await .init(
        top: calculateVerticalPopupPadding(for: .top, activePopupConfig: activePopupConfig),
        leading: calculateLeadingPopupPadding(activePopupConfig: activePopupConfig),
        bottom: calculateVerticalPopupPadding(for: .bottom, activePopupConfig: activePopupConfig),
        trailing: calculateTrailingPopupPadding(activePopupConfig: activePopupConfig)
    )}
}
private extension VM.VerticalStack {
    nonisolated func calculateVerticalPopupPadding(for edge: PopupAlignment, activePopupConfig: AnyPopupConfig) async -> CGFloat {
        let largeScreenHeight = await calculateLargeScreenHeight(),
            activePopupHeight = await activePopup.height ?? 0,
            priorityPopupPaddingValue = await calculatePriorityPopupPaddingValue(for: edge, activePopupConfig: activePopupConfig),
            remainingHeight = largeScreenHeight - activePopupHeight - priorityPopupPaddingValue

        let popupPaddingCandidate = min(remainingHeight, activePopupConfig.popupPadding[edge])
        return max(popupPaddingCandidate, 0)
    }
    nonisolated func calculateLeadingPopupPadding(activePopupConfig: AnyPopupConfig) async -> CGFloat {
        activePopupConfig.popupPadding.leading
    }
    nonisolated func calculateTrailingPopupPadding(activePopupConfig: AnyPopupConfig) async -> CGFloat {
        activePopupConfig.popupPadding.trailing
    }
}
private extension VM.VerticalStack {
    nonisolated func calculatePriorityPopupPaddingValue(for edge: PopupAlignment, activePopupConfig: AnyPopupConfig) async -> CGFloat { switch edge == alignment {
        case true: 0
        case false: activePopupConfig.popupPadding[!edge]
    }}
}

// MARK: Body Padding
private extension VM.VerticalStack {
    nonisolated func _calculateBodyPadding() async -> EdgeInsets { guard let popup = await popups.last else { return .init() }; return await .init(
        top: calculateTopBodyPadding(popup: popup),
        leading: calculateLeadingBodyPadding(popup: popup),
        bottom: calculateBottomBodyPadding(popup: popup),
        trailing: calculateTrailingBodyPadding(popup: popup)
    )}
}
private extension VM.VerticalStack {
    nonisolated func calculateTopBodyPadding(popup: AnyPopup) async -> CGFloat {
        if popup.config.ignoredSafeAreaEdges.contains(.top) { return 0 }

        return switch alignment {
            case .top: await calculateVerticalPaddingAdhereEdge(safeAreaHeight: screen.safeArea.top, popupPadding: activePopup.outerPadding.top)
            case .bottom: await calculateVerticalPaddingCounterEdge(popupHeight: activePopup.height ?? 0, safeArea: screen.safeArea.top)
            case .centre: fatalError()
        }
    }
    func calculateBottomBodyPadding(popup: AnyPopup) async -> CGFloat {
        if popup.config.ignoredSafeAreaEdges.contains(.bottom) && !screen.isKeyboardActive { return 0 }

        return switch alignment {
            case .top: await calculateVerticalPaddingCounterEdge(popupHeight: activePopup.height ?? 0, safeArea: screen.safeArea.bottom)
            case .bottom: await calculateVerticalPaddingAdhereEdge(safeAreaHeight: screen.safeArea.bottom, popupPadding: activePopup.outerPadding.bottom)
            case .centre: fatalError()
        }
    }
    nonisolated func calculateLeadingBodyPadding(popup: AnyPopup) async -> CGFloat { switch popup.config.ignoredSafeAreaEdges.contains(.leading) {
        case true: 0
        case false: await screen.safeArea.leading
    }}
    nonisolated func calculateTrailingBodyPadding(popup: AnyPopup) async -> CGFloat { switch popup.config.ignoredSafeAreaEdges.contains(.trailing) {
        case true: 0
        case false: await screen.safeArea.trailing
    }}
}
private extension VM.VerticalStack {
    nonisolated func calculateVerticalPaddingCounterEdge(popupHeight: CGFloat, safeArea: CGFloat) async -> CGFloat {
        let paddingValueCandidate = await safeArea + popupHeight - screen.height
        return max(paddingValueCandidate, 0)
    }
    nonisolated func calculateVerticalPaddingAdhereEdge(safeAreaHeight: CGFloat, popupPadding: CGFloat) async -> CGFloat {
        let paddingValueCandidate = safeAreaHeight - popupPadding
        return max(paddingValueCandidate, 0)
    }
}

// MARK: Offset Y
extension VM.VerticalStack {
    func calculateOffsetY(for popup: AnyPopup) -> CGFloat { switch popup == popups.last {
        case true: calculateOffsetForActivePopup()
        case false: calculateOffsetForStackedPopup(popup)
    }}
}
private extension VM.VerticalStack {
    func calculateOffsetForActivePopup() -> CGFloat {
        let lastPopupDragHeight = popups.last?.dragHeight ?? 0

        return switch alignment {
            case .top: min(gestureTranslation + lastPopupDragHeight, 0)
            case .bottom: max(gestureTranslation - lastPopupDragHeight, 0)
            case .centre: fatalError()
        }
    }
    func calculateOffsetForStackedPopup(_ popup: AnyPopup) -> CGFloat {
        let invertedIndex = getInvertedIndex(of: popup)
        let offsetValue = stackOffset * .init(invertedIndex)
        let alignmentMultiplier = switch alignment {
            case .top: 1.0
            case .bottom: -1.0
            case .centre: fatalError()
        }

        return offsetValue * alignmentMultiplier
    }
}

// MARK: Scale X
extension VM.VerticalStack {
    func calculateScaleX(for popup: AnyPopup) -> CGFloat {
        guard popup != popups.last else { return 1 }

        let invertedIndex = getInvertedIndex(of: popup),
            remainingTranslationProgress = 1 - translationProgress

        let progressMultiplier = invertedIndex == 1 ? remainingTranslationProgress : max(minScaleProgressMultiplier, remainingTranslationProgress)
        let scaleValue = .init(invertedIndex) * stackScaleFactor * progressMultiplier
        return 1 - scaleValue
    }
}

// MARK: Corner Radius
private extension VM.VerticalStack {
    nonisolated func _calculateCornerRadius() async -> [PopupAlignment: CGFloat] {
        guard let activePopup = await popups.last else { return [:] }

        let cornerRadiusValue = await calculateCornerRadiusValue(activePopup)
        return await [
            .top: calculateTopCornerRadius(cornerRadiusValue),
            .bottom: calculateBottomCornerRadius(cornerRadiusValue)
        ]
    }
}
private extension VM.VerticalStack {
    nonisolated func calculateCornerRadiusValue(_ activePopup: AnyPopup) async -> CGFloat { switch activePopup.config.heightMode {
        case .auto, .large: activePopup.config.cornerRadius
        case .fullscreen: 0
    }}
    nonisolated func calculateTopCornerRadius(_ cornerRadiusValue: CGFloat) async -> CGFloat { switch alignment {
        case .top: await activePopup.outerPadding.top != 0 ? cornerRadiusValue : 0
        case .bottom: cornerRadiusValue
        case .centre: fatalError()
    }}
    nonisolated func calculateBottomCornerRadius(_ cornerRadiusValue: CGFloat) async -> CGFloat { switch alignment {
        case .top: cornerRadiusValue
        case .bottom: await activePopup.outerPadding.bottom != 0 ? cornerRadiusValue : 0
        case .centre: fatalError()
    }}
}

// MARK: Fixed Size
extension VM.VerticalStack {
    nonisolated func _calculateVerticalFixedSize() async -> Bool { guard let popup = await popups.last else { return true }; return switch popup.config.heightMode {
        case .fullscreen, .large: false
        case .auto: await activePopup.height != calculateLargeScreenHeight()
    }}
}

// MARK: Z Index
extension VM.VerticalStack {
    func calculateZIndex() -> CGFloat {
        popups.last == nil ? 2137 : .init(popups.count)
    }
}

// MARK: - Stack Overlay Opacity
extension VM.VerticalStack {
    func calculateStackOverlayOpacity(for popup: AnyPopup) -> CGFloat {
        guard popup != popups.last else { return 0 }

        let invertedIndex = getInvertedIndex(of: popup),
            remainingTranslationProgress = 1 - translationProgress

        let progressMultiplier = invertedIndex == 1 ? remainingTranslationProgress : max(minStackOverlayProgressMultiplier, remainingTranslationProgress)
        let overlayValue = min(stackOverlayFactor * .init(invertedIndex), maxStackOverlayFactor)

        let opacity = overlayValue * progressMultiplier
        return max(opacity, 0)
    }
}
private extension VM.VerticalStack {
    var minStackOverlayProgressMultiplier: CGFloat { 0.6 }
}



// MARK: - HELPERS



// MARK: Active Popup Height
private extension VM.VerticalStack {
    nonisolated func _calculateHeightForActivePopup() async -> CGFloat? {
        guard let activePopupHeight = await popups.last?.height else { return nil }

        let activePopupDragHeight = await popups.last?.dragHeight ?? 0
        let popupHeightFromGestureTranslation = await activePopupHeight + activePopupDragHeight + gestureTranslation * getDragTranslationMultiplier()

        let newHeightCandidate1 = max(activePopupHeight, popupHeightFromGestureTranslation),
            newHeightCanditate2 = await screen.height
        return min(newHeightCandidate1, newHeightCanditate2)
    }
}
private extension VM.VerticalStack {
    func getDragTranslationMultiplier() -> CGFloat { switch alignment {
        case .top: 1
        case .bottom: -1
        case .centre: fatalError()
    }}
}

// MARK: Translation Progress
private extension VM.VerticalStack {
    nonisolated func _calculateTranslationProgress() async -> CGFloat { guard let activePopupHeight = await popups.last?.height else { return 0 }; return switch alignment {
        case .top: await abs(min(gestureTranslation + (popups.last?.dragHeight ?? 0), 0)) / activePopupHeight
        case .bottom: await max(gestureTranslation - (popups.last?.dragHeight ?? 0), 0) / activePopupHeight
        case .centre: fatalError()
    }}
}

// MARK: Others
extension VM.VerticalStack {
    func getInvertedIndex(of popup: AnyPopup) -> Int {
        let index = popups.firstIndex(of: popup) ?? 0
        let invertedIndex = popups.count - 1 - index
        return invertedIndex
    }
}

// MARK: Attributes
extension VM.VerticalStack {
    var stackScaleFactor: CGFloat { 0.025 }
    var stackOverlayFactor: CGFloat { 0.1 }
    var maxStackOverlayFactor: CGFloat { 0.48 }
    var stackOffset: CGFloat { GlobalConfigContainer.vertical.isStackingEnabled ? 8 : 0 }
    var dragThreshold: CGFloat { GlobalConfigContainer.vertical.dragThreshold }
    var dragGestureEnabled: Bool { popups.last?.config.isDragGestureEnabled ?? false }
    var dragTranslationThreshold: CGFloat { 8 }
    var minScaleProgressMultiplier: CGFloat { 0.7 }
}



// MARK: - GESTURES



// MARK: On Changed
extension VM.VerticalStack {
    nonisolated func onPopupDragGestureChanged(_ value: CGFloat) async { if await dragGestureEnabled {
        let newGestureTranslation = await calculateGestureTranslation(value)
        await updateGestureTranslation(newGestureTranslation)
    }}
}
private extension VM.VerticalStack {
    nonisolated func calculateGestureTranslation(_ value: CGFloat) async -> CGFloat { switch await popups.last?.config.dragDetents.isEmpty ?? true {
        case true: await calculateGestureTranslationWhenNoDragDetents(value)
        case false: await calculateGestureTranslationWhenDragDetents(value)
    }}
}
private extension VM.VerticalStack {
    nonisolated func calculateGestureTranslationWhenNoDragDetents(_ value: CGFloat) async -> CGFloat {
        await calculateDragExtremeValue(value, 0)
    }
    nonisolated func calculateGestureTranslationWhenDragDetents(_ value: CGFloat) async -> CGFloat { guard await value * getDragTranslationMultiplier() > 0, let activePopupHeight = await popups.last?.height else { return value }
        let maxHeight = await calculateMaxHeightForDragGesture(activePopupHeight)
        let dragTranslation = await calculateDragTranslation(maxHeight, activePopupHeight)
        return await calculateDragExtremeValue(dragTranslation, value)
    }
}
private extension VM.VerticalStack {
    nonisolated func calculateMaxHeightForDragGesture(_ activePopupHeight: CGFloat) async -> CGFloat {
        let maxHeight1 = await (calculatePopupTargetHeightsFromDragDetents(activePopupHeight).max() ?? 0) + dragTranslationThreshold
        let maxHeight2 = await screen.height
        return min(maxHeight1, maxHeight2)
    }
    nonisolated func calculateDragTranslation(_ maxHeight: CGFloat, _ activePopupHeight: CGFloat) async -> CGFloat {
        let translation = await maxHeight - activePopupHeight - (popups.last?.dragHeight ?? 0)
        return await translation * getDragTranslationMultiplier()
    }
    nonisolated func calculateDragExtremeValue(_ value1: CGFloat, _ value2: CGFloat) async -> CGFloat { switch alignment {
        case .top: min(value1, value2)
        case .bottom: max(value1, value2)
        case .centre: fatalError()
    }}
}

// MARK: On Ended
extension VM.VerticalStack {
    nonisolated func onPopupDragGestureEnded(_ value: CGFloat) async { if value != 0 {
        await dismissLastItemIfNeeded()
        await updateTranslationValues()
    }}
}
private extension VM.VerticalStack {
    func dismissLastItemIfNeeded() async { if shouldDismissPopup() { if let popup = popups.last {
        await closePopupAction(popup)
    }}}
    func updateTranslationValues() async { if let activePopupHeight = popups.last?.height {
        let currentPopupHeight = calculateCurrentPopupHeight(activePopupHeight)
        let popupTargetHeights = calculatePopupTargetHeightsFromDragDetents(activePopupHeight)
        let targetHeight = calculateTargetPopupHeight(currentPopupHeight, popupTargetHeights)
        let targetDragHeight = calculateTargetDragHeight(targetHeight, activePopupHeight)

        await resetGestureTranslation()
        await updateDragHeight(targetDragHeight)
    }}
}
private extension VM.VerticalStack {
    func calculateCurrentPopupHeight(_ activePopupHeight: CGFloat) -> CGFloat {
        let activePopupDragHeight = popups.last?.dragHeight ?? 0
        let currentDragHeight = activePopupDragHeight + gestureTranslation * getDragTranslationMultiplier()

        let currentPopupHeight = activePopupHeight + currentDragHeight
        return currentPopupHeight
    }
    func calculatePopupTargetHeightsFromDragDetents(_ activePopupHeight: CGFloat) -> [CGFloat] { guard let dragDetents = popups.last?.config.dragDetents else { return [activePopupHeight] }; return
        dragDetents
            .map { switch $0 {
                case .height(let targetHeight): min(targetHeight, calculateLargeScreenHeight())
                case .fraction(let fraction): min(fraction * activePopupHeight, calculateLargeScreenHeight())
                case .large: calculateLargeScreenHeight()
                case .fullscreen: screen.height
            }}
            .appending(activePopupHeight)
            .sorted(by: <)
    }
    func calculateTargetPopupHeight(_ currentPopupHeight: CGFloat, _ popupTargetHeights: [CGFloat]) -> CGFloat {
        guard let activePopupHeight = popups.last?.height,
              currentPopupHeight < screen.height
        else { return popupTargetHeights.last ?? 0 }

        let initialIndex = popupTargetHeights.firstIndex(where: { $0 >= currentPopupHeight }) ?? popupTargetHeights.count - 1,
            targetIndex = gestureTranslation * getDragTranslationMultiplier() > 0 ? initialIndex : max(0, initialIndex - 1)
        let previousPopupHeight = (popups.last?.dragHeight ?? 0) + activePopupHeight,
            popupTargetHeight = popupTargetHeights[targetIndex],
            deltaHeight = abs(previousPopupHeight - popupTargetHeight)
        let progress = abs(currentPopupHeight - previousPopupHeight) / deltaHeight

        if progress < dragThreshold {
            let index = gestureTranslation * getDragTranslationMultiplier() > 0 ? max(0, initialIndex - 1) : initialIndex
            return popupTargetHeights[index]
        }
        return popupTargetHeights[targetIndex]
    }
    func calculateTargetDragHeight(_ targetHeight: CGFloat, _ activePopupHeight: CGFloat) -> CGFloat {
        targetHeight - activePopupHeight
    }
    func updateDragHeight(_ targetDragHeight: CGFloat) async { if let activePopup = popups.last {
        var newPopup = activePopup
        newPopup.dragHeight = targetDragHeight
        await updatePopupAction(newPopup)
    }}
    nonisolated func resetGestureTranslation() async {
        await updateGestureTranslation(0)
    }
    func shouldDismissPopup() -> Bool {
        translationProgress >= dragThreshold
    }
}
