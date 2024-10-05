//
//  PopupManager.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

@MainActor public class PopupManager: ObservableObject {
    @Published var views: [AnyPopup] = []

    let id: PopupManagerID
    private init(id: PopupManagerID) { self.id = id }
}

// MARK: - Operations
enum StackOperation {
    case insert(AnyPopup)
    case removeLast, removeExact(PopupID), removeWithPopupType(any Popup.Type), removeWithID(String), removeAll
}
extension PopupManager {
    func performOperation(_ operation: StackOperation) {
        hideKeyboard()
        perform(operation)
    }
}
private extension PopupManager {
    @MainActor func hideKeyboard() { KeyboardManager.hideKeyboard() }
    func perform(_ operation: StackOperation) {
        switch operation {
            case .insert(let popup): views.append(popup, if: canBeInserted(popup))
            case .removeLast: views.safelyRemoveLast()
            case .removeExact(let id): views.removeAll(where: { $0.id.isSameInstance(as: id) })
            case .removeWithPopupType(let popupType): views.removeAll(where: { $0.id.isSameType(as: popupType) })
            case .removeWithID(let id): views.removeAll(where: { $0.id.isSameType(as: id) })
            case .removeAll: views.removeAll()
        }
    }
}
private extension PopupManager {
    func canBeInserted(_ popup: AnyPopup) -> Bool { !views.contains(where: { $0.id.isSameType(as: popup.id) }) }
}














extension PopupManager {
    static func registerNewInstance(id: PopupManagerID) -> PopupManager {
        let instanceToRegister = PopupManager(id: id)

        let registeredInstance = PopupManagerRegistry.registerNewInstance(instanceToRegister)
        return registeredInstance
    }
}






extension PopupManager {
    static func getInstance(_ id: PopupManagerID) -> PopupManager? {
        let managerObject = PopupManagerRegistry.instances.first(where: { $0.id == id })

        Logger.log(if: managerObject == nil, level: .fault, message: "PopupManager instance (\(id.rawValue)) must be registered before use. More details can be found in the documentation.")
        return managerObject
    }
}
