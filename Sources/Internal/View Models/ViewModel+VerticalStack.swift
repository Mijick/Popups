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

extension VM { class VerticalStack<Config: LocalConfig.Vertical>: ViewModel<Config> {
    // MARK: Attributes
    private(set) var alignment: VerticalEdge
    private(set) var gestureTranslation: CGFloat = 0
    private(set) var translationProgress: CGFloat = 0

    // MARK: Overridden Methods
    override func recalculateAndSave(height: CGFloat, for popup: AnyPopup) { _recalculateAndSave(height: height, for: popup) }
    override func calculateHeightForActivePopup() -> CGFloat? { _calculateHeightForActivePopup() }
    override func calculatePopupPadding() -> EdgeInsets { _calculatePopupPadding() }
    override func calculateCornerRadius() -> [VerticalEdge : CGFloat] { _calculateCornerRadius() }
    override func calculateVerticalFixedSize(for popup: AnyPopup) -> Bool { _calculateVerticalFixedSize(for: popup) }

    // MARK: Initialise
    override init() { self.alignment = .init(Config.self) }
}}



// MARK: - SETUP & UPDATE



// MARK: Update
private extension VM.VerticalStack {
    func updateGestureTranslation(_ newGestureTranslation: CGFloat) {
        gestureTranslation = newGestureTranslation
        translationProgress = calculateTranslationProgress()
        activePopupHeight = calculateHeightForActivePopup()

        withAnimation(gestureTranslation == 0 ? .transition : nil) { objectWillChange.send() }
    }
}



// MARK: - VIEW METHODS



// MARK: Recalculate & Update Popup Height
private extension VM.VerticalStack {
    func _recalculateAndSave(height: CGFloat, for popup: AnyPopup) { if gestureTranslation.isZero, height != popup.height {
        let popupConfig = getConfig(popup)
        let newHeight = calculateHeight(height, popupConfig)
        updateHeight(newHeight, popup)
    }}
}
private extension VM.VerticalStack {
    func calculateHeight(_ heightCandidate: CGFloat, _ popupConfig: Config) -> CGFloat { switch popupConfig.heightMode {
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
        let numberOfStackedItems = max(popups.count - 1, 0)

        let stackedItemsHeight = stackOffset * .init(numberOfStackedItems)
        return stackedItemsHeight
    }
}

// MARK: Popup Padding
private extension VM.VerticalStack {
    func _calculatePopupPadding() -> EdgeInsets { .init(
        top: calculateVerticalPopupPadding(for: .top),
        leading: calculateLeadingPopupPadding(),
        bottom: calculateVerticalPopupPadding(for: .bottom),
        trailing: calculateTrailingPopupPadding()
    )}
}
private extension VM.VerticalStack {
    func calculateVerticalPopupPadding(for edge: PopupAlignment) -> CGFloat {
        guard let activePopupHeight else { return 0 }
        
        let largeScreenHeight = calculateLargeScreenHeight(),
            priorityPopupPaddingValue = calculatePriorityPopupPaddingValue(for: edge),
            remainingHeight = largeScreenHeight - activePopupHeight - priorityPopupPaddingValue

        let popupPaddingCandidate = min(remainingHeight, getActivePopupConfig().popupPadding[edge])
        return max(popupPaddingCandidate, 0)
    }
    func calculateLeadingPopupPadding() -> CGFloat {
        getActivePopupConfig().popupPadding.leading
    }
    func calculateTrailingPopupPadding() -> CGFloat {
        getActivePopupConfig().popupPadding.trailing
    }
}
private extension VM.VerticalStack {
    func calculatePriorityPopupPaddingValue(for edge: PopupAlignment) -> CGFloat { switch edge == alignment {
        case true: 0
        case false: getActivePopupConfig().popupPadding[!edge]
    }}
}

// MARK: Body Padding
extension VM.VerticalStack {
    func calculateBodyPadding(for popup: AnyPopup) -> EdgeInsets { let activePopupHeight = activePopupHeight ?? 0, popupConfig = getConfig(popup); return .init(
        top: calculateTopBodyPadding(activePopupHeight: activePopupHeight, popupConfig: popupConfig),
        leading: calculateLeadingBodyPadding(popupConfig: popupConfig),
        bottom: calculateBottomBodyPadding(activePopupHeight: activePopupHeight, popupConfig: popupConfig),
        trailing: calculateTrailingBodyPadding(popupConfig: popupConfig)
    )}
}
private extension VM.VerticalStack {
    func calculateTopBodyPadding(activePopupHeight: CGFloat, popupConfig: Config) -> CGFloat {
        if popupConfig.ignoredSafeAreaEdges.contains(.top) { return 0 }

        return switch alignment {
            case .top: calculateVerticalPaddingAdhereEdge(safeAreaHeight: screen.safeArea.top, popupPadding: calculatePopupPadding().top)
            case .bottom: calculateVerticalPaddingCounterEdge(popupHeight: activePopupHeight, safeArea: screen.safeArea.top)
        }
    }
    func calculateBottomBodyPadding(activePopupHeight: CGFloat, popupConfig: Config) -> CGFloat {
        if popupConfig.ignoredSafeAreaEdges.contains(.bottom) && !isKeyboardActive { return 0 }

        return switch alignment {
            case .top: calculateVerticalPaddingCounterEdge(popupHeight: activePopupHeight, safeArea: screen.safeArea.bottom)
            case .bottom: calculateVerticalPaddingAdhereEdge(safeAreaHeight: screen.safeArea.bottom, popupPadding: calculatePopupPadding().bottom)
        }
    }
    func calculateLeadingBodyPadding(popupConfig: Config) -> CGFloat { switch popupConfig.ignoredSafeAreaEdges.contains(.leading) {
        case true: 0
        case false: screen.safeArea.leading
    }}
    func calculateTrailingBodyPadding(popupConfig: Config) -> CGFloat { switch popupConfig.ignoredSafeAreaEdges.contains(.trailing) {
        case true: 0
        case false: screen.safeArea.trailing
    }}
}
private extension VM.VerticalStack {
    func calculateVerticalPaddingCounterEdge(popupHeight: CGFloat, safeArea: CGFloat) -> CGFloat {
        let paddingValueCandidate = safeArea + popupHeight - screen.height
        return max(paddingValueCandidate, 0)
    }
    func calculateVerticalPaddingAdhereEdge(safeAreaHeight: CGFloat, popupPadding: CGFloat) -> CGFloat {
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
private extension VM.VerticalStack {
    var minScaleProgressMultiplier: CGFloat { 0.7 }
}

// MARK: Corner Radius
private extension VM.VerticalStack {
    func _calculateCornerRadius() -> [PopupAlignment: CGFloat] {
        let cornerRadiusValue = calculateCornerRadiusValue(getActivePopupConfig())
        return [
            .top: calculateTopCornerRadius(cornerRadiusValue),
            .bottom: calculateBottomCornerRadius(cornerRadiusValue)
        ]
    }
}
private extension VM.VerticalStack {
    func calculateCornerRadiusValue(_ activePopupConfig: AnyPopupConfig) -> CGFloat { switch activePopupConfig.heightMode {
        case .auto, .large: activePopupConfig.cornerRadius
        case .fullscreen: 0
    }}
    func calculateTopCornerRadius(_ cornerRadiusValue: CGFloat) -> CGFloat { switch alignment {
        case .top: calculatePopupPadding().top != 0 ? cornerRadiusValue : 0
        case .bottom: cornerRadiusValue
        case .centre: fatalError()
    }}
    func calculateBottomCornerRadius(_ cornerRadiusValue: CGFloat) -> CGFloat { switch alignment {
        case .top: cornerRadiusValue
        case .bottom: calculatePopupPadding().bottom != 0 ? cornerRadiusValue : 0
        case .centre: fatalError()
    }}
}

// MARK: Fixed Size
private extension VM.VerticalStack {
    func _calculateVerticalFixedSize(for popup: AnyPopup) -> Bool { switch getConfig(popup).heightMode {
        case .fullscreen, .large: false
        case .auto: activePopupHeight != calculateLargeScreenHeight()
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
    func calculateStackOverlayOpacity(for popup: AnyPopup) -> Double {
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
    func _calculateHeightForActivePopup() -> CGFloat? {
        guard let activePopupHeight = popups.last?.height else { return nil }

        let activePopupDragHeight = popups.last?.dragHeight ?? 0
        let popupHeightFromGestureTranslation = activePopupHeight + activePopupDragHeight + gestureTranslation * getDragTranslationMultiplier()

        let newHeightCandidate1 = max(activePopupHeight, popupHeightFromGestureTranslation),
            newHeightCanditate2 = screen.height
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
    func calculateTranslationProgress() -> CGFloat { guard let activePopupHeight = popups.last?.height else { return 0 }; return switch alignment {
        case .top: abs(min(gestureTranslation + (popups.last?.dragHeight ?? 0), 0)) / activePopupHeight
        case .bottom: max(gestureTranslation - (popups.last?.dragHeight ?? 0), 0) / activePopupHeight
        case .centre: fatalError()
    }}
}

// MARK: Others
private extension VM.VerticalStack {
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
    var dragGestureEnabled: Bool { getActivePopupConfig().isDragGestureEnabled }
}



// MARK: - GESTURES



// MARK: On Changed
extension VM.VerticalStack {
    func onPopupDragGestureChanged(_ value: CGFloat) { if dragGestureEnabled {
        let newGestureTranslation = calculateGestureTranslation(value)
        updateGestureTranslation(newGestureTranslation)
    }}
}
private extension VM.VerticalStack {
    func calculateGestureTranslation(_ value: CGFloat) -> CGFloat { switch getActivePopupConfig().dragDetents.isEmpty {
        case true: calculateGestureTranslationWhenNoDragDetents(value)
        case false: calculateGestureTranslationWhenDragDetents(value)
    }}
}
private extension VM.VerticalStack {
    func calculateGestureTranslationWhenNoDragDetents(_ value: CGFloat) -> CGFloat {
        calculateDragExtremeValue(value, 0)
    }
    func calculateGestureTranslationWhenDragDetents(_ value: CGFloat) -> CGFloat { guard value * getDragTranslationMultiplier() > 0, let activePopupHeight = popups.last?.height else { return value }
        let maxHeight = calculateMaxHeightForDragGesture(activePopupHeight)
        let dragTranslation = calculateDragTranslation(maxHeight, activePopupHeight)
        return calculateDragExtremeValue(dragTranslation, value)
    }
}
private extension VM.VerticalStack {
    func calculateMaxHeightForDragGesture(_ activePopupHeight: CGFloat) -> CGFloat {
        let maxHeight1 = (calculatePopupTargetHeightsFromDragDetents(activePopupHeight).max() ?? 0) + dragTranslationThreshold
        let maxHeight2 = screen.height
        return min(maxHeight1, maxHeight2)
    }
    func calculateDragTranslation(_ maxHeight: CGFloat, _ activePopupHeight: CGFloat) -> CGFloat {
        let translation = maxHeight - activePopupHeight - (popups.last?.dragHeight ?? 0)
        return translation * getDragTranslationMultiplier()
    }
    func calculateDragExtremeValue(_ value1: CGFloat, _ value2: CGFloat) -> CGFloat { switch alignment {
        case .top: min(value1, value2)
        case .bottom: max(value1, value2)
        case .centre: fatalError()
    }}
}
private extension VM.VerticalStack {
    var dragTranslationThreshold: CGFloat { 8 }
}

// MARK: On Ended
extension VM.VerticalStack {
    func onPopupDragGestureEnded(_ value: CGFloat) { if value != 0 {
        dismissLastItemIfNeeded()
        updateTranslationValues()
    }}
}
private extension VM.VerticalStack {
    func dismissLastItemIfNeeded() { if shouldDismissPopup() { if let popup = popups.last {
        closePopupAction(popup)
    }}}
    func updateTranslationValues() { if let activePopupHeight = popups.last?.height {
        let currentPopupHeight = calculateCurrentPopupHeight(activePopupHeight)
        let popupTargetHeights = calculatePopupTargetHeightsFromDragDetents(activePopupHeight)
        let targetHeight = calculateTargetPopupHeight(currentPopupHeight, popupTargetHeights)
        let targetDragHeight = calculateTargetDragHeight(targetHeight, activePopupHeight)

        resetGestureTranslation()
        updateDragHeight(targetDragHeight)
    }}
}
private extension VM.VerticalStack {
    func calculateCurrentPopupHeight(_ activePopupHeight: CGFloat) -> CGFloat {
        let activePopupDragHeight = popups.last?.dragHeight ?? 0
        let currentDragHeight = activePopupDragHeight + gestureTranslation * getDragTranslationMultiplier()

        let currentPopupHeight = activePopupHeight + currentDragHeight
        return currentPopupHeight
    }
    func calculatePopupTargetHeightsFromDragDetents(_ activePopupHeight: CGFloat) -> [CGFloat] {
        getActivePopupConfig().dragDetents
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
    func updateDragHeight(_ targetDragHeight: CGFloat) { if let activePopup = popups.last {
        updatePopupAction(activePopup.settingDragHeight(targetDragHeight))
    }}
    func resetGestureTranslation() {
        updateGestureTranslation(0)
    }
    func shouldDismissPopup() -> Bool {
        translationProgress >= dragThreshold
    }
}



// MARK: - TESTS
#if DEBUG



// MARK: Methods
extension VM.VerticalStack {
    func t_calculatePopupPadding() -> EdgeInsets { calculatePopupPadding() }
    func t_calculateBodyPadding(for popup: AnyPopup) -> EdgeInsets { calculateBodyPadding(for: popup) }
    func t_calculateHeight(heightCandidate: CGFloat, popupConfig: AnyPopupConfig) -> CGFloat { calculateHeight(heightCandidate, popupConfig) }
    func t_calculateOffsetY(for popup: AnyPopup) -> CGFloat { calculateOffsetY(for: popup) }
    func t_calculateScaleX(for popup: AnyPopup) -> CGFloat { calculateScaleX(for: popup) }
    func t_calculateVerticalFixedSize(for popup: AnyPopup) -> Bool { calculateVerticalFixedSize(for: popup) }
    func t_calculateStackOverlayOpacity(for popup: AnyPopup) -> CGFloat { calculateStackOverlayOpacity(for: popup) }
    func t_calculateCornerRadius() -> [PopupAlignment: CGFloat] { calculateCornerRadius() }
    func t_calculateTranslationProgress() -> CGFloat { calculateTranslationProgress() }
    func t_getInvertedIndex(of popup: AnyPopup) -> Int { getInvertedIndex(of: popup) }

    func t_calculateAndUpdateTranslationProgress() { translationProgress = calculateTranslationProgress() }
    func t_updateGestureTranslation(_ newGestureTranslation: CGFloat) { updateGestureTranslation(newGestureTranslation) }

    func t_onPopupDragGestureChanged(_ value: CGFloat) { onPopupDragGestureChanged(value) }
    func t_onPopupDragGestureEnded(_ value: CGFloat) { onPopupDragGestureEnded(value) }
}

// MARK: Variables
extension VM.VerticalStack {
    var t_stackOffset: CGFloat { stackOffset }
    var t_stackScaleFactor: CGFloat { stackScaleFactor }
    var t_stackOverlayFactor: CGFloat { stackOverlayFactor }
    var t_minScaleProgressMultiplier: CGFloat { minScaleProgressMultiplier }
    var t_minStackOverlayProgressMultiplier: CGFloat { minStackOverlayProgressMultiplier }
    var t_maxStackOverlayFactor: CGFloat { maxStackOverlayFactor }
    var t_dragTranslationThreshold: CGFloat { dragTranslationThreshold }
    var t_gestureTranslation: CGFloat { gestureTranslation }
}
#endif
