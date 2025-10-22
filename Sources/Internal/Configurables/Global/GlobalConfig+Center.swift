//
//  GlobalConfig+Center.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

@MainActor
public final class GlobalConfigCenter: GlobalConfig { required public init() {}
    // MARK: Active Variables
    public var popupPadding: EdgeInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
    public var cornerRadius: CGFloat = 24
    public var backgroundColor: Color = .white
    public var overlayColor: Color = .black.opacity(0.5)
    public var isTapOutsideToDismissEnabled: Bool = false

    // MARK: Inactive Variables
    public var ignoredSafeAreaEdges: Edge.Set = []
    public var heightMode: HeightMode = .auto
    public var dragDetents: [DragDetent] = []
    public var isDragGestureEnabled: Bool = false
    public var dragThreshold: CGFloat = 0
    public var isStackingEnabled: Bool = false
    public var dragGestureAreaSize: CGFloat = 0
}
