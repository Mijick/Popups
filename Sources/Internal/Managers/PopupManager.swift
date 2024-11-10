//
//  PopupManager.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2023 Mijick. All rights reserved.


import SwiftUI

@MainActor public class PopupManager: ObservableObject {
    let id: PopupManagerID
    @Published private(set) var stack: [AnyPopup] = []
    @Published private(set) var stackPriority: StackPriority = .init()

    private init(id: PopupManagerID) { self.id = id }
}

// MARK: Update
extension PopupManager {
    func updateStack(_ popup: AnyPopup) { if let index = stack.firstIndex(of: popup) {
        stack[index] = popup
    }}
}



// MARK: - STACK OPERATIONS



// MARK: Available Operations
extension PopupManager { enum StackOperation {
    case insertPopup(any Popup)
    case removeLastPopup, removePopupInstance(AnyPopup), removeAllPopupsOfType(any Popup.Type), removeAllPopupsWithID(String), removeAllPopups
}}

// MARK: Perform Operation
extension PopupManager {
    func stack(_ operation: StackOperation) { let oldStackCount = stack.count
        hideKeyboard()
        perform(operation)
        reshuffleStackPriority(oldStackCount)
    }
}
private extension PopupManager {
    func hideKeyboard() { Task {
        await AnyView.hideKeyboard()
    }}
    func perform(_ operation: StackOperation) { switch operation {
        case .insertPopup(let popup): insertPopup(popup)
        case .removeLastPopup: removeLastPopup()
        case .removePopupInstance(let popup): removePopupInstance(popup)
        case .removeAllPopupsOfType(let popupType): removeAllPopupsOfType(popupType)
        case .removeAllPopupsWithID(let id): removeAllPopupsWithID(id)
        case .removeAllPopups: removeAllPopups()
    }}
    func reshuffleStackPriority(_ oldStackCount: Int) {
        let delayDuration = oldStackCount > stack.count ? Animation.duration : 0

        DispatchQueue.main.asyncAfter(deadline: .now() + delayDuration) { [self] in
            stackPriority.reshuffle(newPopups: stack)
        }
    }
}
private extension PopupManager {
    func insertPopup(_ popup: any Popup) {
        let erasedPopup = AnyPopup(popup)
        let canPopupBeInserted = !stack.contains(where: { $0.id.isSameType(as: erasedPopup.id) })

        if canPopupBeInserted { stack.append(erasedPopup.startDismissTimerIfNeeded(self)) }
    }
    func removeLastPopup() { if !stack.isEmpty {
        stack.removeLast()
    }}
    func removePopupInstance(_ popup: AnyPopup) {
        stack.removeAll(where: { $0.id.isSameInstance(as: popup) })
    }
    func removeAllPopupsOfType(_ popupType: any Popup.Type) {
        stack.removeAll(where: { $0.id.isSameType(as: popupType) })
    }
    func removeAllPopupsWithID(_ id: String) {
        stack.removeAll(where: { $0.id.isSameType(as: id) })
    }
    func removeAllPopups() {
        stack.removeAll()
    }
}



// MARK: - INSTACE OPERATIONS



// MARK: Fetch
extension PopupManager {
    static func fetchInstance(id: PopupManagerID) -> PopupManager? {
        let managerObject = PopupManagerContainer.instances.first(where: { $0.id == id })
        logNoInstanceErrorIfNeeded(managerObject: managerObject, popupManagerID: id)
        return managerObject
    }
}
private extension PopupManager {
    static func logNoInstanceErrorIfNeeded(managerObject: PopupManager?, popupManagerID: PopupManagerID) { if managerObject == nil {
        Logger.log(
            level: .fault,
            message: "PopupManager instance (\(popupManagerID.rawValue)) must be registered before use. More details can be found in the documentation."
        )
    }}
}

// MARK: Register
extension PopupManager {
    static func registerInstance(id: PopupManagerID) -> PopupManager {
        let instanceToRegister = PopupManager(id: id)
        let registeredInstance = PopupManagerContainer.register(popupManager: instanceToRegister)
        return registeredInstance
    }
}
