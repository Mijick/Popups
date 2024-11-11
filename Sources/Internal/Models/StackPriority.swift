//
//  StackPriority.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import Foundation

struct StackPriority: Equatable, Sendable {
    var top: CGFloat { values[0] }
    var centre: CGFloat { values[1] }
    var bottom: CGFloat { values[2] }
    var overlay: CGFloat { 1 }

    private var values: [CGFloat] = [0, 0, 0]
}

// MARK: Reshuffle
extension StackPriority {
    @MainActor mutating func reshuffle(newPopups: [AnyPopup]) { switch newPopups.last?.config.alignment {
        case .top: reshuffle(0)
        case .centre: reshuffle(1)
        case .bottom: reshuffle(2)
        default: return
    }}
}
private extension StackPriority {
    mutating func reshuffle(_ index: Int) {
        guard values[index] != maxPriority else { return }

        let newValues = values.enumerated().map { $0.offset == index ? maxPriority : $0.element - 2 }
        values = newValues
    }
}
private extension StackPriority {
    var maxPriority: CGFloat { 2 }
}
