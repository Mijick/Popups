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
    static private(set) var instances: [PopupStack] = []
}

// MARK: Register
extension PopupStackContainer {
    static func register(popupManager: PopupStack) -> PopupStack {
        if let alreadyRegisteredInstance = instances.first(where: { $0.id == popupManager.id }) { return alreadyRegisteredInstance }

        instances.append(popupManager)
        return popupManager
    }
}

// MARK: Clean
extension PopupStackContainer {
    static func clean() { instances = [] }
}
