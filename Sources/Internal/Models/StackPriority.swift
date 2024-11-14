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
    var center: CGFloat { values[1] }
    var bottom: CGFloat { values[2] }
    var overlay: CGFloat { 1 }

    private var values: [CGFloat] = [0, 0, 0]
}

// MARK: Reshuffled
extension StackPriority {
    func reshuffled(_ newPopups: [AnyPopup]) -> StackPriority { switch newPopups.last?.config.alignment {
        case .top: reshuffled(0)
        case .center: reshuffled(1)
        case .bottom: reshuffled(2)
        default: self
    }}
}
private extension StackPriority {
    func reshuffled(_ index: Int) -> StackPriority {
        guard values[index] != maxPriority else { return self }

        let newValues = values.enumerated().map { $0.offset == index ? maxPriority : $0.element - 2 }
        return .init(values: newValues)
    }
}
private extension StackPriority {
    var maxPriority: CGFloat { 2 }
}
