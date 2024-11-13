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

struct Screen: Sendable {
    let height: CGFloat
    let safeArea: EdgeInsets
    let isKeyboardActive: Bool


    init(height: CGFloat = .zero, safeArea: EdgeInsets = .init(), isKeyboardActive: Bool = false) {
        self.height = height
        self.safeArea = safeArea
        self.isKeyboardActive = isKeyboardActive
    }
}
