//
//  PopupTopStackView.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

struct PopupTopStackView: PopupStack {
    let items: [AnyPopup<TopPopupConfig>]
    let globalConfig: GlobalConfig
    @Binding var enable: Bool
    @State var gestureTranslation: CGFloat = 0
    @State var heights: [ID: CGFloat] = [:]
    @State var dragHeights: [ID: CGFloat] = [:]
    @GestureState var isGestureActive: Bool = false
    @ObservedObject private var screenManager: ScreenManager = .shared

    
    var body: some View {
        ZStack(alignment: .bottom, content: createPopupStack)
            .background(createTapArea())
            .animation(getHeightAnimation(isAnimationDisabled: screenManager.animationsDisabled), value: heights)
            .animation(isGestureActive ? dragGestureAnimation : transitionRemovalAnimation, value: gestureTranslation)
            .onDragGesture(
                $isGestureActive,
                enable: $enable,
                onChanged: onPopupDragGestureChanged,
                onEnded: onPopupDragGestureEnded
            )
    }
}

private extension PopupTopStackView {
    func createPopupStack() -> some View {
        ForEach(items, id: \.self, content: createPopup)
    }
}

private extension PopupTopStackView {
    func createPopup(_ item: AnyPopup<TopPopupConfig>) -> some View {
        item.body
            .padding(.top, contentTopPadding)
            .padding(.leading, screenManager.safeArea.left)
            .padding(.trailing, screenManager.safeArea.right)
            .readHeight { saveHeight($0, for: item) }
            .frame(height: height, alignment: .bottom).frame(maxWidth: .infinity)
            .background(getBackgroundColour(for: item), overlayColour: getStackOverlayColour(item), radius: getCornerRadius(item), corners: getCorners(), shadow: popupShadow)
            .padding(.horizontal, lastPopupConfig.popupPadding.horizontal)
            .offset(y: getOffset(item))
            .scaleEffect(x: getScale(item))
            .opacity(getOpacity(item))
            .compositingGroup()
            .focusSectionIfAvailable()
            .align(to: .top, popupTopPadding)
            .transition(transition)
            .zIndex(getZIndex(item))
    }
}

// MARK: - Gestures

// MARK: On Changed
private extension PopupTopStackView {
    func onPopupDragGestureChanged(_ value: CGFloat) { if canDragGestureBeUsed() {
        updateGestureTranslation(value)
    }}
}
private extension PopupTopStackView {
    func canDragGestureBeUsed() -> Bool { lastPopupConfig.dragGestureEnabled ?? globalConfig.bottom.dragGestureEnabled }
    func updateGestureTranslation(_ value: CGFloat) { switch lastPopupConfig.dragDetents.isEmpty {
        case true: gestureTranslation = calculateGestureTranslationWhenNoDragDetents(value)
        case false: gestureTranslation = calculateGestureTranslationWhenDragDetents(value)
    }}
}
private extension PopupTopStackView {
    func calculateGestureTranslationWhenNoDragDetents(_ value: CGFloat) -> CGFloat { min(value, 0) }
    func calculateGestureTranslationWhenDragDetents(_ value: CGFloat) -> CGFloat { guard value > 0, let lastPopupHeight = getLastPopupHeight() else { return value }
        let maxHeight = calculateMaxHeightForDragGesture(lastPopupHeight)
        let dragTranslation = calculateDragTranslation(maxHeight, lastPopupHeight)
        return min(dragTranslation, value)
    }
}
private extension PopupTopStackView {
    func calculateMaxHeightForDragGesture(_ lastPopupHeight: CGFloat) -> CGFloat {
        let maxHeight1 = (calculatePopupTargetHeightsFromDragDetents(lastPopupHeight).max() ?? 0) + dragTranslationThreshold
        let maxHeight2 = screenManager.size.height
        return min(maxHeight1, maxHeight2)
    }
    func calculateDragTranslation(_ maxHeight: CGFloat, _ lastPopupHeight: CGFloat) -> CGFloat {
        let translation = maxHeight - lastPopupHeight - getLastDragHeight()
        return translation
    }
}
private extension PopupTopStackView {
    var dragTranslationThreshold: CGFloat { 8 }
}

// MARK: On Ended
private extension PopupTopStackView {
    func onPopupDragGestureEnded(_ value: CGFloat) { guard value != 0 else { return }
        dismissLastItemIfNeeded()
        updateTranslationValues()
    }
}
private extension PopupTopStackView {
    func dismissLastItemIfNeeded() { if shouldDismissPopup() {
        items.last?.remove()
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
private extension PopupTopStackView {
    func calculateCurrentPopupHeight(_ lastPopupHeight: CGFloat) -> CGFloat {
        let lastDragHeight = getLastDragHeight()
        let currentDragHeight = lastDragHeight + gestureTranslation

        let currentPopupHeight = lastPopupHeight + currentDragHeight
        return currentPopupHeight
    }
    func calculatePopupTargetHeightsFromDragDetents(_ lastPopupHeight: CGFloat) -> [CGFloat] { lastPopupConfig.dragDetents
        .map { switch $0 {
            case .fixed(let targetHeight): min(targetHeight, screenManager.size.height)
            case .fraction(let fraction): min(fraction * lastPopupHeight, screenManager.size.height)
            case .fullscreen(let stackVisible): stackVisible ? screenManager.size.height - screenManager.safeArea.bottom : screenManager.size.height
        }}
        .appending(lastPopupHeight)
        .sorted(by: <)
    }
    func calculateTargetPopupHeight(_ currentPopupHeight: CGFloat, _ popupTargetHeights: [CGFloat]) -> CGFloat {
        guard let lastPopupHeight = getLastPopupHeight(),
              currentPopupHeight < screenManager.size.height
        else { return popupTargetHeights.last ?? 0 }

        let initialIndex = popupTargetHeights.firstIndex(where: { $0 >= currentPopupHeight }) ?? popupTargetHeights.count - 1,
            targetIndex = gestureTranslation > 0 ? initialIndex : max(0, initialIndex - 1)
        let previousPopupHeight = getLastDragHeight() + lastPopupHeight,
            popupTargetHeight = popupTargetHeights[targetIndex],
            deltaHeight = abs(previousPopupHeight - popupTargetHeight)
        let progress = abs(currentPopupHeight - previousPopupHeight) / deltaHeight

        if progress < gestureClosingThresholdFactor {
            let index = gestureTranslation > 0 ? max(0, initialIndex - 1) : initialIndex
            return popupTargetHeights[index]
        }
        return popupTargetHeights[targetIndex]
    }
    func calculateTargetDragHeight(_ targetHeight: CGFloat, _ lastPopupHeight: CGFloat) -> CGFloat {
        targetHeight - lastPopupHeight
    }
    func updateDragHeight(_ targetDragHeight: CGFloat) { if let id = items.last?.id { DispatchQueue.main.async {
        dragHeights[id] = targetDragHeight
    }}}
    func resetGestureTranslation() {
        let resetAfter = items.count == 1 && shouldDismissPopup() ? 0.25 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + resetAfter) { gestureTranslation = 0 }
    }
    func shouldDismissPopup() -> Bool { translationProgress >= gestureClosingThresholdFactor }
}

// MARK: - View Modifiers
private extension PopupTopStackView {
    func getCorners() -> RectCorner {
        switch popupTopPadding {
            case 0: return [.bottomLeft, .bottomRight]
            default: return .allCorners
        }
    }
    func getBackgroundColour(for item: AnyPopup<TopPopupConfig>) -> Color { getConfig(item).backgroundColour ?? globalConfig.top.backgroundColour }
    func saveHeight(_ height: CGFloat, for item: AnyPopup<TopPopupConfig>) { if !isGestureActive { heights[item.id] = height }}
}

// MARK: - Flags & Values
extension PopupTopStackView {
    var contentTopPadding: CGFloat { lastPopupConfig.contentIgnoresSafeArea ? 0 : max(screenManager.safeArea.top - popupTopPadding, 0) }
    var popupTopPadding: CGFloat { lastPopupConfig.popupPadding.top }
    var popupShadow: Shadow { globalConfig.top.shadow }
    var height: CGFloat {
        let lastDragHeight = getLastDragHeight(),
            lastPopupHeight = getLastPopupHeight() ?? getInitialHeight()
        let dragTranslation = lastPopupHeight + lastDragHeight + gestureTranslation - popupTopPadding
        let newHeight = max(lastPopupHeight, dragTranslation)

        switch lastPopupHeight + lastDragHeight > screenManager.size.height && !lastPopupConfig.contentIgnoresSafeArea {
            case true: return newHeight == screenManager.size.height ? newHeight : newHeight - screenManager.safeArea.top
            case false: return newHeight
        }
    }
    var cornerRadius: CGFloat { lastPopupConfig.cornerRadius ?? globalConfig.top.cornerRadius }

    var stackLimit: Int { globalConfig.top.stackLimit }
    var stackScaleFactor: CGFloat { globalConfig.top.stackScaleFactor }
    var stackOffsetValue: CGFloat { globalConfig.top.stackOffset }
    var stackCornerRadiusMultiplier: CGFloat { globalConfig.top.stackCornerRadiusMultiplier }

    var translationProgress: CGFloat { guard let popupHeight = getLastPopupHeight() else { return 0 }; return abs(min(gestureTranslation + getLastDragHeight(), 0)) / popupHeight }
    var gestureClosingThresholdFactor: CGFloat { globalConfig.top.dragGestureProgressToClose }
    var transition: AnyTransition { .move(edge: .top) }

    var tapOutsideClosesPopup: Bool { lastPopupConfig.tapOutsideClosesView ?? globalConfig.top.tapOutsideClosesView }
}
