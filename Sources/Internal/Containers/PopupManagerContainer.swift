//
//  PopupManagerContainer.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import Foundation

@MainActor class PopupManagerContainer {
    static private(set) var instances: [PopupManager] = []
}

// MARK: Register
extension PopupManagerContainer {
    static func register(popupManager: PopupManager) -> PopupManager {
        if let alreadyRegisteredInstance = instances.first(where: { $0.id == popupManager.id }) { return alreadyRegisteredInstance }

        instances.append(popupManager)
        return popupManager
    }
}

// MARK: Clean
extension PopupManagerContainer {
    static func clean() { instances = [] }
}
