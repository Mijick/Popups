//
//  EdgeInsets++.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

extension EdgeInsets {
    subscript(_ edge: PopupAlignment) -> CGFloat { switch edge {
        case .top: top
        case .centre: 0
        case .bottom: bottom
    }}
}
