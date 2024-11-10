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
    private(set) var height: CGFloat
    private(set) var safeArea: EdgeInsets
    private(set) var isKeyboardActive: Bool


    init(height: CGFloat = .zero, safeArea: EdgeInsets = .init(), isKeyboardActive: Bool = false) {
        self.height = height
        self.safeArea = safeArea
        self.isKeyboardActive = isKeyboardActive
    }
}

// MARK: Update
extension Screen {
    mutating func update(screenReader: GeometryProxy?, isKeyboardActive: Bool?) {
        if let screenReader {
            self.height = screenReader.size.height + screenReader.safeAreaInsets.top + screenReader.safeAreaInsets.bottom
            self.safeArea = screenReader.safeAreaInsets
        }
        if let isKeyboardActive {
            self.isKeyboardActive = isKeyboardActive
        }
    }
}
