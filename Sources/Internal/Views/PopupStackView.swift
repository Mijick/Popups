//
//  PopupStackView.swift of MijickPopups
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import SwiftUI

struct PopupStackView<Config: LocalConfig.Vertical>: View {
    @ObservedObject var viewModel: ViewModel


    var body: some View {
        ZStack(alignment: (!viewModel.alignment).toAlignment(), content: createPopupStack)
            .frame(height: viewModel.screenSize.height, alignment: viewModel.alignment.toAlignment())
            .animation(heightAnimation, value: viewModel.items.map(\.height))
            .animation(heightAnimation, value: viewModel.items.map(\.dragHeight))
            .animation(isGestureActive ? nil : .transition, value: viewModel.gestureTranslation)
            .animation(.keyboard, value: isKeyboardVisible)
            .onDragGesture(onChanged: onPopupDragGestureChanged, onEnded: onPopupDragGestureEnded)
    }
}
private extension PopupStackView {
    func createPopupStack() -> some View {
        ForEach(viewModel.items, id: \.self, content: createPopup)
    }
}
private extension PopupStackView {
    func createPopup(_ item: AnyPopup) -> some View {
        Counter.increment()



        let config = getConfig(item)


        return item.body
            .padding(calculateBodyPadding(popupConfig: config))
            .fixedSize(horizontal: false, vertical: calculateVerticalFixedSize(popupConfig: config))
            .onHeightChange { save(height: $0, for: item, popupConfig: config) }
            .frame(height: viewModel.activePopupHeight, alignment: (!viewModel.alignment).toAlignment())
            .frame(maxWidth: .infinity)
            .background(getBackgroundColour(popupConfig: config), overlayColour: getStackOverlayColour(for: item), corners: calculateCornerRadius(), shadow: popupShadow)
            .offset(y: calculateOffset(for: item))
            .scaleEffect(x: calculateScale(for: item))
            .focusSectionIfAvailable()
            .padding(calculatePopupPadding())
            .transition(transition)
            .zIndex(calculateZIndex(for: item))
            .compositingGroup()
    }
}

// MARK: - Calculating Paddings For Popup Body
private extension PopupStackView {
    func calculateBodyPadding(popupConfig: Config) -> EdgeInsets { let activePopupHeight = viewModel.activePopupHeight ?? 0; return .init(
        top: calculateTopBodyPadding(activePopupHeight: activePopupHeight, popupConfig: popupConfig),
        leading: calculateLeadingBodyPadding(),
        bottom: calculateBottomBodyPadding(activePopupHeight: activePopupHeight, popupConfig: popupConfig),
        trailing: calculateTrailingBodyPadding()
    )}
}
private extension PopupStackView {
    func calculateTopBodyPadding(activePopupHeight: CGFloat, popupConfig: Config) -> CGFloat {
        if popupConfig.ignoredSafeAreaEdges.contains(.top) { return 0 }

        return switch viewModel.alignment {
            case .top: calculateVerticalPaddingAdhereEdge(safeAreaHeight: viewModel.safeArea.top, popupPadding: calculatePopupPadding().top)
            case .bottom: calculateVerticalPaddingCounterEdge(popupHeight: activePopupHeight, safeArea: viewModel.safeArea.top)
        }
    }
    func calculateBottomBodyPadding(activePopupHeight: CGFloat, popupConfig: Config) -> CGFloat {
        if isKeyboardVisible { return viewModel.keyboardHeight + distanceFromKeyboard }
        if popupConfig.ignoredSafeAreaEdges.contains(.bottom) { return 0 }

        return switch viewModel.alignment {
            case .top: calculateVerticalPaddingCounterEdge(popupHeight: activePopupHeight, safeArea: viewModel.safeArea.bottom)
            case .bottom: calculateVerticalPaddingAdhereEdge(safeAreaHeight: viewModel.safeArea.bottom, popupPadding: calculatePopupPadding().bottom)
        }
    }
    func calculateLeadingBodyPadding() -> CGFloat {
        viewModel.safeArea.leading
    }
    func calculateTrailingBodyPadding() -> CGFloat {
        viewModel.safeArea.trailing
    }
}
private extension PopupStackView {
    func calculateVerticalPaddingCounterEdge(popupHeight: CGFloat, safeArea: CGFloat) -> CGFloat {
        let paddingValueCandidate = safeArea + popupHeight - viewModel.screenSize.height
        return max(paddingValueCandidate, 0)
    }
    func calculateVerticalPaddingAdhereEdge(safeAreaHeight: CGFloat, popupPadding: CGFloat) -> CGFloat {
        let paddingValueCandidate = safeAreaHeight - popupPadding
        return max(paddingValueCandidate, 0)
    }
}

// MARK: - Calculating Corner Radius
private extension PopupStackView {
    func calculateCornerRadius() -> [VerticalEdge: CGFloat] {
        let cornerRadiusValue = calculateCornerRadiusValue(activePopupConfig)
        return [
            .top: calculateTopCornerRadius(cornerRadiusValue),
            .bottom: calculateBottomCornerRadius(cornerRadiusValue)
        ]
    }
}
private extension PopupStackView {
    func calculateCornerRadiusValue(_ activePopupConfig: Config) -> CGFloat { switch activePopupConfig.heightMode {
        case .auto, .large: activePopupConfig.cornerRadius
        case .fullscreen: 0
    }}
    func calculateTopCornerRadius(_ cornerRadiusValue: CGFloat) -> CGFloat { switch viewModel.alignment {
        case .top: calculatePopupPadding().top != 0 ? cornerRadiusValue : 0
        case .bottom: cornerRadiusValue
    }}
    func calculateBottomCornerRadius(_ cornerRadiusValue: CGFloat) -> CGFloat { switch viewModel.alignment {
        case .top: cornerRadiusValue
        case .bottom: calculatePopupPadding().bottom != 0 ? cornerRadiusValue : 0
    }}
}

// MARK: - Saving Height For Item
private extension PopupStackView {
    func save(height: CGFloat, for popup: AnyPopup, popupConfig: Config) { if !isGestureActive {
        let newHeight = calculateHeight(height, popupConfig)
        updateHeight(newHeight, popup)
    }}
}
private extension PopupStackView {
    func calculateHeight(_ height: CGFloat, _ popupConfig: Config) -> CGFloat { switch popupConfig.heightMode {
        case .auto: min(height, calculateLargeScreenHeight())
        case .large: calculateLargeScreenHeight()
        case .fullscreen: getFullscreenHeight()
    }}
    func updateHeight(_ newHeight: CGFloat, _ item: AnyPopup) { if item.height != newHeight {
        viewModel.update(popup: item) { $0.height = newHeight }
    }}
}
private extension PopupStackView {
    func calculateLargeScreenHeight() -> CGFloat { let popupPadding = calculatePopupPadding()
        let fullscreenHeight = getFullscreenHeight(),
            safeAreaHeight = viewModel.safeArea[!viewModel.alignment],
            popupPaddings = popupPadding.top + popupPadding.bottom,
            stackHeight = calculateStackHeight()
        return fullscreenHeight - safeAreaHeight - popupPaddings - stackHeight
    }
    func getFullscreenHeight() -> CGFloat {
        viewModel.screenSize.height
    }
}
private extension PopupStackView {
    func calculateStackHeight() -> CGFloat {
        let numberOfStackedItems = max(viewModel.items.count - 1, 0)

        let stackedItemsHeight = stackOffset * .init(numberOfStackedItems)
        return stackedItemsHeight
    }
}

// MARK: - Calculating Offset
private extension PopupStackView {
    func calculateOffset(for popup: AnyPopup) -> CGFloat { switch popup == viewModel.items.last {
        case true: calculateOffsetForActivePopup()
        case false: calculateOffsetForStackedPopup(popup)
    }}
}
private extension PopupStackView {
    func calculateOffsetForActivePopup() -> CGFloat {
        let lastPopupDragHeight = viewModel.items.last?.dragHeight ?? 0

        return switch viewModel.alignment {
            case .top: min(viewModel.gestureTranslation + lastPopupDragHeight, 0)
            case .bottom: max(viewModel.gestureTranslation - lastPopupDragHeight, 0)
        }
    }
    func calculateOffsetForStackedPopup(_ popup: AnyPopup) -> CGFloat {
        let invertedIndex = getInvertedIndex(of: popup)
        let offsetValue = stackOffset * .init(invertedIndex)
        let alignmentMultiplier = switch viewModel.alignment {
            case .top: 1.0
            case .bottom: -1.0
        }

        return offsetValue * alignmentMultiplier
    }
}

// MARK: - Calculating Scale
private extension PopupStackView {
    func calculateScale(for popup: AnyPopup) -> CGFloat { guard popup != viewModel.items.last else { return 1 }
        let invertedIndex = getInvertedIndex(of: popup),
            remainingTranslationProgress = 1 - viewModel.translationProgress

        let progressMultiplier = invertedIndex == 1 ? remainingTranslationProgress : max(0.7, remainingTranslationProgress)
        let scaleValue = .init(invertedIndex) * stackScaleFactor * progressMultiplier
        return 1 - scaleValue
    }
}

// MARK: - Fixed Size
private extension PopupStackView {
    func calculateVerticalFixedSize(popupConfig: Config) -> Bool { switch popupConfig.heightMode {
        case .fullscreen, .large: false
        case .auto: viewModel.activePopupHeight != calculateLargeScreenHeight()
    }}
}

// MARK: - Stack Overlay Colour
private extension PopupStackView {
    func getStackOverlayColour(for popup: AnyPopup) -> Color {
        let opacity = calculateStackOverlayOpacity(popup)
        return stackOverlayColour.opacity(opacity)
    }
}
private extension PopupStackView {
    func calculateStackOverlayOpacity(_ popup: AnyPopup) -> Double { guard popup != viewModel.items.last else { return 0 }
        let invertedIndex = getInvertedIndex(of: popup),
            remainingTranslationProgress = 1 - viewModel.translationProgress

        let progressMultiplier = invertedIndex == 1 ? remainingTranslationProgress : max(0.6, remainingTranslationProgress)
        let overlayValue = min(stackOverlayFactor * .init(invertedIndex), maxStackOverlayFactor)

        let opacity = overlayValue * progressMultiplier
        return max(opacity, 0)
    }
}

// MARK: - Background Colour
private extension PopupStackView {
    func getBackgroundColour(popupConfig: Config) -> Color {
        popupConfig.backgroundColour
    }
}

// MARK: - Popup Padding
private extension PopupStackView {
    func calculatePopupPadding() -> EdgeInsets { guard activePopupConfig.heightMode != .fullscreen else { return .init() }; return .init(
        top: activePopupConfig.popupPadding.top,
        leading: activePopupConfig.popupPadding.horizontal,
        bottom: activePopupConfig.popupPadding.bottom,
        trailing: activePopupConfig.popupPadding.horizontal
    )}
}

// MARK: - Item ZIndex
private extension PopupStackView {
    func calculateZIndex(for popup: AnyPopup) -> Double {
        .init(viewModel.items.firstIndex(of: popup) ?? 2137)
    }
}



// MARK: - Attributes
private extension PopupStackView {
    var isKeyboardVisible: Bool { viewModel.keyboardHeight > 0 }
    var activePopupConfig: Config { getConfig(viewModel.items.last) }
    var globalConfig: GlobalConfig.Vertical { ConfigContainer.vertical }
}

// MARK: - Configurable Attributes
private extension PopupStackView {
    var popupShadow: Shadow { globalConfig.shadow }
    var stackOffset: CGFloat { globalConfig.isStackingPossible ? 8 : 0 }
    var stackScaleFactor: CGFloat { 0.025 }
    var stackOverlayColour: Color { .black }
    var stackOverlayFactor: CGFloat { 0.1 }
    var maxStackOverlayFactor: CGFloat { 0.48 }
    var transition: AnyTransition { .move(edge: viewModel.alignment.toEdge()) }
    var heightAnimation: Animation? { screenManager.animationsDisabled ? nil : .transition }
    var gestureClosingThresholdFactor: CGFloat { globalConfig.dragGestureProgressToClose }
    var distanceFromKeyboard: CGFloat { activePopupConfig.distanceFromKeyboard }
    var dragGestureEnabled: Bool { activePopupConfig.dragGestureEnabled }
}

// MARK: - Helpers
private extension PopupStackView {
    func getInvertedIndex(of popup: AnyPopup) -> Int {
        let index = viewModel.items.firstIndex(of: popup) ?? 0
        let invertedIndex = viewModel.items.count - 1 - index
        return invertedIndex
    }
    func getConfig(_ item: AnyPopup?) -> Config {
        let config = item?.config as? Config
        return config ?? .init()
    }
}


// MARK: - Gestures

// MARK: On Changed
private extension PopupStackView {
    func onPopupDragGestureChanged(_ value: CGFloat) { if dragGestureEnabled {
        updateGestureTranslation(value)
    }}
}
private extension PopupStackView {
    func updateGestureTranslation(_ value: CGFloat) { switch activePopupConfig.dragDetents.isEmpty {
        case true: viewModel.gestureTranslation = calculateGestureTranslationWhenNoDragDetents(value)
        case false: viewModel.gestureTranslation = calculateGestureTranslationWhenDragDetents(value)
    }}
}
private extension PopupStackView {
    func calculateGestureTranslationWhenNoDragDetents(_ value: CGFloat) -> CGFloat {
        calculateDragExtremeValue(value, 0)
    }
    func calculateGestureTranslationWhenDragDetents(_ value: CGFloat) -> CGFloat { guard value * getDragTranslationMultiplier() > 0, let activePopupHeight = viewModel.items.last?.height else { return value }
        let maxHeight = calculateMaxHeightForDragGesture(activePopupHeight)
        let dragTranslation = calculateDragTranslation(maxHeight, activePopupHeight)
        return calculateDragExtremeValue(dragTranslation, value)
    }
}
private extension PopupStackView {
    func calculateMaxHeightForDragGesture(_ activePopupHeight: CGFloat) -> CGFloat {
        let maxHeight1 = (calculatePopupTargetHeightsFromDragDetents(activePopupHeight).max() ?? 0) + dragTranslationThreshold
        let maxHeight2 = viewModel.screenSize.height
        return min(maxHeight1, maxHeight2)
    }
    func calculateDragTranslation(_ maxHeight: CGFloat, _ activePopupHeight: CGFloat) -> CGFloat {
        let translation = maxHeight - activePopupHeight - (viewModel.items.last?.dragHeight ?? 0)
        return translation * getDragTranslationMultiplier()
    }
    func calculateDragExtremeValue(_ value1: CGFloat, _ value2: CGFloat) -> CGFloat { switch viewModel.alignment {
        case .top: min(value1, value2)
        case .bottom: max(value1, value2)
    }}
}
private extension PopupStackView {
    var dragTranslationThreshold: CGFloat { 8 }
}

// MARK: On Ended
private extension PopupStackView {
    func onPopupDragGestureEnded(_ value: CGFloat) { guard value != 0 else { return }
        dismissLastItemIfNeeded()
        updateTranslationValues()
    }
}
private extension PopupStackView {
    func dismissLastItemIfNeeded() { if shouldDismissPopup() {
        PopupManager.dismissPopup(id: viewModel.items.last?.id.value ?? "")
    }}
    func updateTranslationValues() { if let activePopupHeight = viewModel.items.last?.height {
        let currentPopupHeight = calculateCurrentPopupHeight(activePopupHeight)
        let popupTargetHeights = calculatePopupTargetHeightsFromDragDetents(activePopupHeight)
        let targetHeight = calculateTargetPopupHeight(currentPopupHeight, popupTargetHeights)
        let targetDragHeight = calculateTargetDragHeight(targetHeight, activePopupHeight)

        resetGestureTranslation()
        updateDragHeight(targetDragHeight)
    }}
}
private extension PopupStackView {
    func calculateCurrentPopupHeight(_ activePopupHeight: CGFloat) -> CGFloat {
        let activePopupDragHeight = viewModel.items.last?.dragHeight ?? 0
        let currentDragHeight = activePopupDragHeight + viewModel.gestureTranslation * getDragTranslationMultiplier()

        let currentPopupHeight = activePopupHeight + currentDragHeight
        return currentPopupHeight
    }
    func calculatePopupTargetHeightsFromDragDetents(_ activePopupHeight: CGFloat) -> [CGFloat] { activePopupConfig.dragDetents
            .map { switch $0 {
                case .fixed(let targetHeight): min(targetHeight, calculateLargeScreenHeight())
                case .fraction(let fraction): min(fraction * activePopupHeight, calculateLargeScreenHeight())
                case .fullscreen(let stackVisible): stackVisible ? calculateLargeScreenHeight() : viewModel.screenSize.height
            }}
            .appending(activePopupHeight)
            .sorted(by: <)
    }
    func calculateTargetPopupHeight(_ currentPopupHeight: CGFloat, _ popupTargetHeights: [CGFloat]) -> CGFloat {
        guard let activePopupHeight = viewModel.items.last?.height,
              currentPopupHeight < viewModel.screenSize.height
        else { return popupTargetHeights.last ?? 0 }

        let initialIndex = popupTargetHeights.firstIndex(where: { $0 >= currentPopupHeight }) ?? popupTargetHeights.count - 1,
            targetIndex = viewModel.gestureTranslation * getDragTranslationMultiplier() > 0 ? initialIndex : max(0, initialIndex - 1)
        let previousPopupHeight = (viewModel.items.last?.dragHeight ?? 0) + activePopupHeight,
            popupTargetHeight = popupTargetHeights[targetIndex],
            deltaHeight = abs(previousPopupHeight - popupTargetHeight)
        let progress = abs(currentPopupHeight - previousPopupHeight) / deltaHeight

        if progress < gestureClosingThresholdFactor {
            let index = viewModel.gestureTranslation * getDragTranslationMultiplier() > 0 ? max(0, initialIndex - 1) : initialIndex
            return popupTargetHeights[index]
        }
        return popupTargetHeights[targetIndex]
    }
    func calculateTargetDragHeight(_ targetHeight: CGFloat, _ activePopupHeight: CGFloat) -> CGFloat {
        targetHeight - activePopupHeight
    }
    func updateDragHeight(_ targetDragHeight: CGFloat) { if let activePopup = viewModel.items.last {
        viewModel.update(popup: activePopup) { $0.dragHeight = targetDragHeight }
    }}
    func resetGestureTranslation() {
        viewModel.gestureTranslation = 0
    }
    func shouldDismissPopup() -> Bool {
        viewModel.translationProgress >= gestureClosingThresholdFactor
    }
}

// MARK: Helpers
private extension PopupStackView {
    func getDragTranslationMultiplier() -> CGFloat { switch viewModel.alignment {
        case .top: 1
        case .bottom: -1
    }}
}
private extension PopupStackView {
    var isGestureActive: Bool { viewModel.gestureTranslation != 0 }
}
