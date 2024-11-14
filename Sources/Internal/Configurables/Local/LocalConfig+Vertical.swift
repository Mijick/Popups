//
//  LocalConfig+Vertical.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

public class LocalConfigVertical: LocalConfig { required public init() {}
    // MARK: Content
    public var popupPadding: EdgeInsets = GlobalConfigContainer.vertical.popupPadding
    public var cornerRadius: CGFloat = GlobalConfigContainer.vertical.cornerRadius
    public var ignoredSafeAreaEdges: Edge.Set = GlobalConfigContainer.vertical.ignoredSafeAreaEdges
    public var backgroundColor: Color = GlobalConfigContainer.vertical.backgroundColor
    public var overlayColor: Color = GlobalConfigContainer.vertical.overlayColor
    public var heightMode: HeightMode = GlobalConfigContainer.vertical.heightMode
    public var dragDetents: [DragDetent] = GlobalConfigContainer.vertical.dragDetents

    // MARK: Gestures
    public var isTapOutsideToDismissEnabled: Bool = GlobalConfigContainer.vertical.isTapOutsideToDismissEnabled
    public var isDragGestureEnabled: Bool = GlobalConfigContainer.vertical.isDragGestureEnabled
}

// MARK: Subclasses
public extension LocalConfigVertical {
    class Top: LocalConfigVertical {}
    class Bottom: LocalConfigVertical {}
}
