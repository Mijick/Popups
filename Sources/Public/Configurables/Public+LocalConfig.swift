//
//  Public+LocalConfig.swift of MijickPopups
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import SwiftUI

// MARK: All
public extension LocalConfig {
    /// Corner radius of the popup at the top of the stack
    func cornerRadius(_ value: CGFloat) -> Self { self.cornerRadius = value; return self }

    /// Background color of the popup
    func backgroundColor(_ color: Color) -> Self { self.backgroundColor = color; return self }

    /// Color of the overlay covering the view behind the popup. Use .clear to hide the overlay
    func overlayColor(_ color: Color) -> Self { self.overlayColor = color; return self }

    /// Dismisses the active popup when tapped outside its area if enabled
    func tapOutsideToDismissPopup(_ value: Bool) -> Self { self.isTapOutsideToDismissEnabled = value; return self }
}

// MARK: Centre
public extension CentrePopupConfig {

    /// Distance of the entire popup (including its background) from the horizontal edges
    func horizontalPadding(_ value: CGFloat) -> Self { self.popupPadding = .init(top: 0, leading: value, bottom: 0, trailing: value); return self }
}

// MARK: Vertical
public extension LocalConfig.Vertical {
    /// Whether content should ignore safe area
    func ignoresSafeArea(edges: Edge.Set) -> Self { self.ignoredSafeAreaEdges = edges; return self }

    func changeHeightMode(_ value: HeightMode) -> Self { self.heightMode = value; return self }


    /// Distance of the entire popup (including its background) from the bottom edge
    func topPadding(_ value: CGFloat) -> Self { self.popupPadding.top = value; return self }

    /// Distance of the entire popup (including its background) from the bottom edge
    func bottomPadding(_ value: CGFloat) -> Self { self.popupPadding.bottom = value; return self }

    /// Distance of the entire popup (including its background) from the horizontal edges
    func horizontalPadding(_ value: CGFloat) -> Self { self.popupPadding.leading = value; self.popupPadding.trailing = value; return self }

    /// Popup can be closed with drag gesture if enabled
    func dragGestureEnabled(_ value: Bool) -> Self { self.isDragGestureEnabled = value; return self }

    /// Sets available detents for the popupSets the available detents for the enclosing sheet
    func dragDetents(_ value: [DragDetent]) -> Self { self.dragDetents = value; return self }
}
