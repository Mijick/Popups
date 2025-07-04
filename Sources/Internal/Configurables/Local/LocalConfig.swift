//
//  LocalConfig.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

@MainActor
public protocol LocalConfig { init()
    // MARK: Content
    var popupPadding: EdgeInsets { get set }
    var cornerRadius: CGFloat { get set }
    var ignoredSafeAreaEdges: Edge.Set { get set }
    var backgroundColor: Color { get set }
    var overlayColor: Color { get set }
    var heightMode: HeightMode { get set }
    var dragDetents: [DragDetent] { get set }

    // MARK: Gestures
    var isTapOutsideToDismissEnabled: Bool { get set }
    var isDragGestureEnabled: Bool { get set }
}
