//
//  PopupStackContainer.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import Foundation

@MainActor class PopupStackContainer {
    static private(set) var stacks: [PopupStack] = []
}

// MARK: Register
extension PopupStackContainer {
    static func register(stack: PopupStack) -> PopupStack {
        if let alreadyRegisteredStack = stacks.first(where: { $0.id == stack.id }) { return alreadyRegisteredStack }

        stacks.append(stack)
        return stack
    }
}

// MARK: Clean
extension PopupStackContainer {
    static func clean() { stacks = [] }
}
