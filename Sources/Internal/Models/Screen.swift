//
//  Screen.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

struct Screen {
    var height: CGFloat
    var safeArea: EdgeInsets
    var isKeyboardActive: Bool


    init(height: CGFloat = .zero, safeArea: EdgeInsets = .init()) {
        self.height = height
        self.safeArea = safeArea
        self.isKeyboardActive = false
    }
}

// MARK: Update
extension Screen {
    mutating func update(_ screenReader: GeometryProxy) {
        self.height = screenReader.size.height + screenReader.safeAreaInsets.top + screenReader.safeAreaInsets.bottom
        self.safeArea = screenReader.safeAreaInsets
    }
}
