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
    @Binding var items: [AnyPopup]
    let edge: PopupEdge
    @State private var gestureTranslation: CGFloat = 0
    @GestureState private var isGestureActive: Bool = false
    @ObservedObject private var screenManager: ScreenManager = .shared
    @ObservedObject private var keyboardManager: KeyboardManager = .shared


    var body: some View {
        ZStack(alignment: getStackAlignment(), content: createPopupStack)
            .frame(height: screenManager.size.height, alignment: getVVV())
            .frame(maxWidth: .infinity)
            .animation(getHeightAnimation(isAnimationDisabled: screenManager.animationsDisabled), value: items.map(\.height))
            .animation(isGestureActive ? .drag : .transition, value: gestureTranslation)
            .animation(.keyboard, value: isKeyboardVisible)
            .onDragGesture($isGestureActive, onChanged: onPopupDragGestureChanged, onEnded: onPopupDragGestureEnded)
    }
}
private extension PopupStackView {
    func createPopupStack() -> some View {
        ForEach($items, id: \.self, content: createPopup)
    }
}
private extension PopupStackView {
    func createPopup(_ item: Binding<AnyPopup>) -> some View {
        let config = getConfig(item.wrappedValue),
            lastItemConfig = getConfig(items.last),
            height = calculateHeight(for: item.wrappedValue)


        return item.wrappedValue.body
            .padding(.top, getContentTopPadding(height: height ?? 0))
            .padding(.bottom, getContentBottomPadding(height: height ?? 0))
            .padding(.leading, screenManager.safeArea.leading)
            .padding(.trailing, screenManager.safeArea.trailing)
            .fixedSize(horizontal: false, vertical: getFixedSize(config: config, height: height ?? 0))
            .onHeightChange { saveHeight($0, for: item) }
            .frame(height: height, alignment: getStackAlignment())
            .frame(maxWidth: .infinity, maxHeight: height)
            .background(getBackgroundColour(for: item.wrappedValue), overlayColour: getStackOverlayColour(item.wrappedValue), radius: getCornerRadius(item.wrappedValue), corners: getCorners(), shadow: popupShadow)
            .padding(.horizontal, popupHorizontalPadding)
            .offset(y: getOffset(item.wrappedValue))
            .scaleEffect(x: getScale(item.wrappedValue))
            .opacity(getOpacity(item.wrappedValue))
            .focusSectionIfAvailable()
            .padding(getPopupAlignment(), lastItemConfig.heightMode == .fullscreen ? 0 : getPopupPadding())
            .transition(getTransition())
            .zIndex(getZIndex(item.wrappedValue))
            .compositingGroup()
    }
}

// MARK: - Popup Body Paddings
// Kiedy się je stosuje?
// 1. Safe Area
// 2. Keyboard distance
// 3. Drag Indicies
private extension PopupStackView {
    func calculateBodyPadding(config: Config) -> EdgeInsets { .init(
        top: calculateTopBodyPadding(),
        leading: calculateLeadingBodyPadding(),
        bottom: calculateBottomBodyPadding(),
        trailing: calculateTrailingBodyPadding()
    )}
}
private extension PopupStackView {
    func calculateTopBodyPadding() -> CGFloat {
        0
    }
    func calculateBottomBodyPadding() -> CGFloat {
        0
    }
    func calculateLeadingBodyPadding() -> CGFloat {
        screenManager.safeArea.leading
    }
    func calculateTrailingBodyPadding() -> CGFloat {
        screenManager.safeArea.trailing
    }
}
private extension PopupStackView {
    func calculateContentPaddingForOppositeEdge(_ edge: PopupEdge, height: CGFloat) -> CGFloat {
        max(getSafeAreaValue(edge) + height - screenManager.size.height, 0)

    }
    func calculateContentPaddingForSameEdge(_ edge: PopupEdge) -> CGFloat {
        max(getSafeAreaValue(edge) - (edge == .top ? popupTopPadding : popupBottomPadding), 0)
    }

    func getContentTopPadding(height: CGFloat) -> CGFloat {
        if getConfig(items.last).ignoredSafeAreaEdges.contains(.top) { return 0 }

        return switch edge {
            case .top: calculateContentPaddingForSameEdge(.top)
            case .bottom: calculateContentPaddingForOppositeEdge(.top, height: height)
        }
    }
    func getContentBottomPadding(height: CGFloat) -> CGFloat {
        if isKeyboardVisible { return keyboardManager.height + distanceFromKeyboard }
        if getConfig(items.last).ignoredSafeAreaEdges.contains(.bottom) { return 0 }

        return switch edge {
            case .top: calculateContentPaddingForOppositeEdge(.bottom, height: height)
            case .bottom: calculateContentPaddingForSameEdge(.bottom)
        }
    }
}

// MARK: - Popup Height
private extension PopupStackView {
    func calculateHeight(for item: AnyPopup) -> CGFloat? { guard let activePopupHeight = items.last?.height else { return nil }
        let activePopupDragHeight = items.last?.dragHeight ?? 0
        let popupHeightFromGestureTranslation = activePopupHeight + activePopupDragHeight + gestureTranslation * getDragTranslationMultiplier()

        let newHeightCandidate1 = max(activePopupHeight, popupHeightFromGestureTranslation),
            newHeightCanditate2 = screenManager.size.height - keyboardManager.height
        return min(newHeightCandidate1, newHeightCanditate2)
    }
}



// MARK: - View Modifiers
private extension PopupStackView {
    func getCorners() -> RectCorner { switch getPopupPadding() {
        case 0: return getPopupRectCorners()
        default: return .allCorners
    }}
    func saveHeight(_ height: CGFloat, for item: Binding<AnyPopup>) { if !isGestureActive {
        let config = getConfig(item.wrappedValue)
        let newHeight = calculateHeight(height, config)

        updateHeight(newHeight, item)
    }}







    func getFixedSize(config: Config, height: CGFloat) -> Bool { !(config.heightMode == .fullscreen || config.heightMode == .large || height == maxHeight) }
    func getBackgroundColour(for item: AnyPopup) -> Color { getConfig(item).backgroundColour }
}
private extension PopupStackView {
    func calculateHeight(_ height: CGFloat, _ config: Config) -> CGFloat { switch config.heightMode {
        case .auto: min(height, maxHeight)
        case .large: getMaxHeight()
        case .fullscreen: screenManager.size.height
    }}
    func updateHeight(_ newHeight: CGFloat, _ item: Binding<AnyPopup>) { if item.wrappedValue.height != newHeight { Task { @MainActor in
        item.wrappedValue.height = newHeight
    }}}
}


extension PopupStackView {
    var popupTopPadding: CGFloat { getConfig(items.last).popupPadding.top }
    var popupBottomPadding: CGFloat { getConfig(items.last).popupPadding.bottom }
    var popupHorizontalPadding: CGFloat { getConfig(items.last).popupPadding.horizontal }
    var popupShadow: Shadow { getGlobalConfig().shadow }



    var distanceFromKeyboard: CGFloat { getConfig(items.last).distanceFromKeyboard }
    var maxHeightStackedFactor: CGFloat { 0.85 }
    var isKeyboardVisible: Bool { keyboardManager.height > 0 }



    var stackLimit: Int { getGlobalConfig().stackLimit }
    var stackScaleFactor: CGFloat { getGlobalConfig().stackScaleFactor }
    var stackOffsetValue: CGFloat { getGlobalConfig().stackOffset * getOffsetMultiplier() }
    var stackCornerRadiusMultiplier: CGFloat { getGlobalConfig().stackCornerRadiusMultiplier }






    var translationProgress: CGFloat { guard let popupHeight = getLastPopupHeight() else { return 0 }
        let translationProgress = calculateTranslationProgress(popupHeight)
        return translationProgress
    }
    var gestureClosingThresholdFactor: CGFloat { getGlobalConfig().dragGestureProgressToClose }
}








extension PopupStackView { enum PopupEdge {
    case top
    case bottom
}}
private extension PopupStackView {
    func getDragExtremeValue(_ value1: CGFloat, _ value2: CGFloat) -> CGFloat { switch edge {
        case .top: min(value1, value2)
        case .bottom: max(value1, value2)
    }}
    func getDragTranslationMultiplier() -> CGFloat { switch edge {
        case .top: 1
        case .bottom: -1
    }}






    func getStackAlignment() -> Alignment { switch edge {
        case .top: .bottom
        case .bottom: .top
    }}
    func getVVV() -> Alignment { switch edge {
        case .top: .top
        case .bottom: .bottom
    }}
    func getPopupAlignment() -> Edge.Set { switch edge {
        case .top: .top
        case .bottom: .bottom
    }}
    func getPopupPadding() -> CGFloat { switch edge {
        case .top: popupTopPadding
        case .bottom: popupBottomPadding
    }}
    func getKeySafeArea() -> CGFloat { switch edge {
        case .top: screenManager.safeArea.bottom
        case .bottom: screenManager.safeArea.top
    }}



    func getOffsetMultiplier() -> CGFloat { switch edge {
        case .top: 1
        case .bottom: -1
    }}


    func calculateTranslationProgress(_ popupHeight: CGFloat) -> CGFloat { switch edge {
        case .top: abs(min(gestureTranslation + getLastDragHeight(), 0)) / popupHeight
        case .bottom: max(gestureTranslation - getLastDragHeight(), 0) / popupHeight
    }}



    func getSafeAreaValue(_ edge: PopupEdge) -> CGFloat { switch edge {
        case .top: screenManager.safeArea.top
        case .bottom: screenManager.safeArea.bottom
    }}
}



// MARK: - Helpers
private extension PopupStackView {
    func isLast(_ item: AnyPopup) -> Bool { items.last == item }
    func isNextToLast(_ item: AnyPopup) -> Bool { invertedIndex(item) == 1 }
    func invertedIndex(_ item: AnyPopup) -> Int { items.count - 1 - index(item) }
    func index(_ item: AnyPopup) -> Int { items.firstIndex(of: item) ?? 0 }
}
private extension PopupStackView {
    var remainingTranslationProgress: CGFloat { 1 - translationProgress }
}




// MARK: - Scale
extension PopupStackView {
    func getScale(_ item: AnyPopup) -> CGFloat {
        let scaleValue = .init(invertedIndex(item)) * stackScaleFactor
        let progressDifference = isNextToLast(item) ? remainingTranslationProgress : max(0.7, remainingTranslationProgress)
        let scale = 1 - scaleValue * progressDifference
        return min(1, scale)
    }
}



// MARK: - Stack Overlay Colour
extension PopupStackView {
    func getStackOverlayColour(_ item: AnyPopup) -> Color {
        let opacity = calculateStackOverlayOpacity(item)
        return stackOverlayColour.opacity(opacity)
    }
}
private extension PopupStackView {
    func calculateStackOverlayOpacity(_ item: AnyPopup) -> Double {
        let overlayValue = .init(invertedIndex(item)) * stackOverlayFactor
        let remainingTranslationProgressValue = isNextToLast(item) ? remainingTranslationProgress : max(0.6, remainingTranslationProgress)
        let opacity = overlayValue * remainingTranslationProgressValue
        return max(0, opacity)
    }
}
private extension PopupStackView {
    var stackOverlayColour: Color { .black }
    var stackOverlayFactor: CGFloat { 1 / .init(stackLimit) * 0.5 }
}

// MARK: - Stack Opacity
extension PopupStackView {
    func getOpacity(_ item: AnyPopup) -> Double { invertedIndex(item) <= stackLimit ? 1 : 0.000000001 }
}



// MARK: - Item ZIndex
extension PopupStackView {
    func getZIndex(_ item: AnyPopup) -> Double { .init(items.firstIndex(of: item) ?? 2137) }
}





// MARK: - Stack Offset
extension PopupStackView {
    func getOffset(_ item: AnyPopup) -> CGFloat { switch isLast(item) {
        case true: calculateOffsetForLastItem()
        case false: calculateOffsetForOtherItems(item)
    }}
}
private extension PopupStackView {
    func calculateOffsetForLastItem() -> CGFloat { switch edge {
        case .top: min(gestureTranslation + getLastDragHeight(), 0)
        case .bottom: max(gestureTranslation - getLastDragHeight(), 0)
    }}
    func calculateOffsetForOtherItems(_ item: AnyPopup) -> CGFloat {
        .init(invertedIndex(item)) * stackOffsetValue
    }
}



// MARK: - Config Related
extension PopupStackView {
    func getConfig(_ item: AnyPopup?) -> Config { item.getConfig() }
    func getGlobalConfig() -> GlobalConfig.Vertical { switch edge {
        case .top: ConfigContainer.vertical
        case .bottom: ConfigContainer.vertical
    }}
}
extension AnyPopup? {
    func getConfig<Config: LocalConfig>() -> Config {
        (self?.config as? Config) ?? .init()
    }
}

// MARK: - Height Related
extension PopupStackView {
    func getInitialHeight() -> CGFloat { items.nextToLast?.height ?? 30 }
    func getLastDragHeight() -> CGFloat { items.last?.dragHeight ?? 0 }
    func getLastPopupHeight() -> CGFloat? {
        let height = items.last?.height
        return height == 0 ? getInitialHeight() : height
    }
    var maxHeight: CGFloat { getMaxHeight() - popupTopPadding - popupBottomPadding }

    func getMaxHeight() -> CGFloat {
        let basicHeight = screenManager.size.height - getKeySafeArea() - getPopupPadding()
        let stackedViewsCount = min(max(0, getGlobalConfig().stackLimit - 1), items.count - 1)
        let stackedViewsHeight = getGlobalConfig().stackOffset * .init(stackedViewsCount) * maxHeightStackedFactor
        return basicHeight - stackedViewsHeight
    }
}

// MARK: - Animation Related
extension PopupStackView {
    func getHeightAnimation(isAnimationDisabled: Bool) -> Animation? { !isAnimationDisabled ? .transition : nil }
    func getTransition() -> AnyTransition { switch edge {
        case .top: .move(edge: .top)
        case .bottom: .move(edge: .bottom)
    }}
}

// MARK: - Corner Radius Related
extension PopupStackView {
    func getCornerRadius(_ item: AnyPopup) -> CGFloat {
        if isLast(item) { return cornerRadius }
        if translationProgress.isZero || translationProgress.isNaN || !isNextToLast(item) { return stackedCornerRadius }

        let difference = cornerRadius - stackedCornerRadius
        let differenceProgress = difference * translationProgress
        return stackedCornerRadius + differenceProgress
    }
    var cornerRadius: CGFloat {
        let cornerRadius = getConfig(items.last).cornerRadius
        return getConfig(items.last).heightMode == .fullscreen ? 0 : cornerRadius
    }
    func getPopupRectCorners() -> RectCorner { switch edge {
        case .top: [.bottomLeft, .bottomRight]
        case .bottom: [.topLeft, .topRight]
    }}
}
private extension PopupStackView {
    var stackedCornerRadius: CGFloat { cornerRadius * stackCornerRadiusMultiplier }
}























// MARK: - Gestures

// MARK: On Changed
private extension PopupStackView {
    func onPopupDragGestureChanged(_ value: CGFloat) { if canDragGestureBeUsed() {
        updateGestureTranslation(value)
    }}
}
private extension PopupStackView {
    func canDragGestureBeUsed() -> Bool { getConfig(items.last).dragGestureEnabled }
    func updateGestureTranslation(_ value: CGFloat) { switch getConfig(items.last).dragDetents.isEmpty {
        case true: gestureTranslation = calculateGestureTranslationWhenNoDragDetents(value)
        case false: gestureTranslation = calculateGestureTranslationWhenDragDetents(value)
    }}
}
private extension PopupStackView {
    func calculateGestureTranslationWhenNoDragDetents(_ value: CGFloat) -> CGFloat { getDragExtremeValue(value, 0) }
    func calculateGestureTranslationWhenDragDetents(_ value: CGFloat) -> CGFloat { guard value * getDragTranslationMultiplier() > 0, let lastPopupHeight = getLastPopupHeight() else { return value }
        let maxHeight = calculateMaxHeightForDragGesture(lastPopupHeight)
        let dragTranslation = calculateDragTranslation(maxHeight, lastPopupHeight)
        return getDragExtremeValue(dragTranslation, value)
    }
}
private extension PopupStackView {
    func calculateMaxHeightForDragGesture(_ lastPopupHeight: CGFloat) -> CGFloat {
        let maxHeight1 = (calculatePopupTargetHeightsFromDragDetents(lastPopupHeight).max() ?? 0) + dragTranslationThreshold
        let maxHeight2 = screenManager.size.height
        return min(maxHeight1, maxHeight2)
    }
    func calculateDragTranslation(_ maxHeight: CGFloat, _ lastPopupHeight: CGFloat) -> CGFloat {
        let translation = maxHeight - lastPopupHeight - getLastDragHeight()
        return translation * getDragTranslationMultiplier()
    }
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
        PopupManager.dismissPopup(id: items.last?.id.value ?? "")
    }}
    func updateTranslationValues() { if let lastPopupHeight = getLastPopupHeight() {
        let currentPopupHeight = calculateCurrentPopupHeight(lastPopupHeight)
        let popupTargetHeights = calculatePopupTargetHeightsFromDragDetents(lastPopupHeight)
        let targetHeight = calculateTargetPopupHeight(currentPopupHeight, popupTargetHeights)
        let targetDragHeight = calculateTargetDragHeight(targetHeight, lastPopupHeight)

        resetGestureTranslation()
        updateDragHeight(targetDragHeight)
    }}
}
private extension PopupStackView {
    func calculateCurrentPopupHeight(_ lastPopupHeight: CGFloat) -> CGFloat {
        let lastDragHeight = getLastDragHeight()
        let currentDragHeight = lastDragHeight + gestureTranslation * getDragTranslationMultiplier()

        let currentPopupHeight = lastPopupHeight + currentDragHeight
        return currentPopupHeight
    }
    func calculatePopupTargetHeightsFromDragDetents(_ lastPopupHeight: CGFloat) -> [CGFloat] { getConfig(items.last).dragDetents
            .map { switch $0 {
                case .fixed(let targetHeight): min(targetHeight, getMaxHeight())
                case .fraction(let fraction): min(fraction * lastPopupHeight, getMaxHeight())
                case .fullscreen(let stackVisible): stackVisible ? getMaxHeight() : screenManager.size.height
            }}
            .appending(lastPopupHeight)
            .sorted(by: <)
    }
    func calculateTargetPopupHeight(_ currentPopupHeight: CGFloat, _ popupTargetHeights: [CGFloat]) -> CGFloat {
        guard let lastPopupHeight = getLastPopupHeight(),
              currentPopupHeight < screenManager.size.height
        else { return popupTargetHeights.last ?? 0 }

        let initialIndex = popupTargetHeights.firstIndex(where: { $0 >= currentPopupHeight }) ?? popupTargetHeights.count - 1,
            targetIndex = gestureTranslation * getDragTranslationMultiplier() > 0 ? initialIndex : max(0, initialIndex - 1)
        let previousPopupHeight = getLastDragHeight() + lastPopupHeight,
            popupTargetHeight = popupTargetHeights[targetIndex],
            deltaHeight = abs(previousPopupHeight - popupTargetHeight)
        let progress = abs(currentPopupHeight - previousPopupHeight) / deltaHeight

        if progress < gestureClosingThresholdFactor {
            let index = gestureTranslation * getDragTranslationMultiplier() > 0 ? max(0, initialIndex - 1) : initialIndex
            return popupTargetHeights[index]
        }
        return popupTargetHeights[targetIndex]
    }
    func calculateTargetDragHeight(_ targetHeight: CGFloat, _ lastPopupHeight: CGFloat) -> CGFloat {
        targetHeight - lastPopupHeight
    }
    func updateDragHeight(_ targetDragHeight: CGFloat) { Task { @MainActor in
        items.lastElement?.dragHeight = targetDragHeight
    }}
    func resetGestureTranslation() { Task { @MainActor in
        gestureTranslation = 0
    }}
    func shouldDismissPopup() -> Bool {
        translationProgress >= gestureClosingThresholdFactor
    }
}
