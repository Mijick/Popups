//
//  PopupAlignment.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

enum PopupAlignment {
    case top
    case center
    case bottom
}

// MARK: Initialize
extension PopupAlignment {
    init(_ config: LocalConfig.Type) { switch config.self {
        case is TopPopupConfig.Type: self = .top
        case is CenterPopupConfig.Type: self = .center
        case is BottomPopupConfig.Type: self = .bottom
        default: fatalError()
    }}
}

// MARK: Negation
extension PopupAlignment {
    static prefix func !(lhs: Self) -> Self { switch lhs {
        case .top: .bottom
        case .center: .center
        case .bottom: .top
    }}
}

// MARK: Type Casting
extension PopupAlignment {
    func toEdge() -> Edge { switch self {
        case .top: .top
        case .center: .bottom
        case .bottom: .bottom
    }}
    func toAlignment() -> Alignment { switch self {
        case .top: .top
        case .center: .center
        case .bottom: .bottom
    }}
}
