//
//  AnyPopupConfig.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

struct AnyPopupConfig: LocalConfig, Sendable { init() {}
    // MARK: Content
    var alignment: PopupAlignment = .center
    var popupPadding: EdgeInsets = .init()
    var cornerRadius: CGFloat = 0
    var ignoredSafeAreaEdges: Edge.Set = []
    var backgroundColor: Color = .clear
    var overlayColor: Color = .clear
    var heightMode: HeightMode = .auto
    var dragDetents: [DragDetent] = []

    // MARK: Gestures
    var isTapOutsideToDismissEnabled: Bool = false
    var isDragGestureEnabled: Bool = false
}

// MARK: Initialization
extension AnyPopupConfig {
    init<Config: LocalConfig>(_ config: Config) {
        self.alignment = .init(Config.self)
        self.popupPadding = config.popupPadding
        self.cornerRadius = config.cornerRadius
        self.ignoredSafeAreaEdges = config.ignoredSafeAreaEdges
        self.backgroundColor = config.backgroundColor
        self.overlayColor = config.overlayColor
        self.heightMode = config.heightMode
        self.dragDetents = config.dragDetents
        self.isTapOutsideToDismissEnabled = config.isTapOutsideToDismissEnabled
        self.isDragGestureEnabled = config.isDragGestureEnabled
    }
}
