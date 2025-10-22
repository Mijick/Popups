//
//  GlobalConfig+Vertical.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

@MainActor
public final class GlobalConfigVertical: GlobalConfig { required public init() {}
    // MARK: Content
    public var popupPadding: EdgeInsets = .init()
    public var cornerRadius: CGFloat = 40
    public var backgroundColor: Color = .white
    public var overlayColor: Color = .black.opacity(0.5)
    public var isStackingEnabled: Bool = true

    // MARK: Gestures
    public var isTapOutsideToDismissEnabled: Bool = false
    public var isDragGestureEnabled: Bool = true
    public var dragThreshold: CGFloat = 1/3
    public var dragGestureAreaSize: CGFloat = 30

    // MARK: Non-Customizable
    public var ignoredSafeAreaEdges: Edge.Set = []
    public var heightMode: HeightMode = .auto
    public var dragDetents: [DragDetent] = []
}
