//
//  PopupStack.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2023 Mijick. All rights reserved.


import SwiftUI

@MainActor public class PopupStack: ObservableObject {
    let id: PopupStackID
    @Published private(set) var popups: [AnyPopup] = []
    @Published private(set) var priority: StackPriority = .init()

    private init(id: PopupStackID) { self.id = id }
}

// MARK: Update
extension PopupStack {
    func update(popup: AnyPopup) { if let index = popups.firstIndex(of: popup) {
        popups[index] = popup
    }}
}



// MARK: - STACK OPERATIONS



// MARK: Available Operations
extension PopupStack { enum StackOperation {
    case insertPopup(AnyPopup)
    case removeLastPopup, removePopupInstance(AnyPopup), removeAllPopupsOfType(any Popup.Type), removeAllPopupsWithID(String), removeAllPopups
}}

// MARK: Perform Operation
extension PopupStack {
    func modify(_ operation: StackOperation) { Task {
        await hideKeyboard()

        let oldPopups = popups,
            newPopups = await getNewPopups(operation),
            newPriority = await getNewPriority(newPopups)

        await updatePopups(newPopups)
        await updatePriority(newPriority, oldPopups.count)
    }}
}
private extension PopupStack {
    nonisolated func hideKeyboard() async {
        await AnyView.hideKeyboard()
    }
    nonisolated func getNewPopups(_ operation: StackOperation) async -> [AnyPopup] { switch operation {
        case .insertPopup(let popup): await insertedPopup(popup)
        case .removeLastPopup: await removedLastPopup()
        case .removePopupInstance(let popup): await removedPopupInstance(popup)
        case .removeAllPopupsOfType(let popupType): await removedAllPopupsOfType(popupType)
        case .removeAllPopupsWithID(let id): await removedAllPopupsWithID(id)
        case .removeAllPopups: await removedAllPopups()
    }}
    nonisolated func getNewPriority(_ newPopups: [AnyPopup]) async -> StackPriority {
        await priority.reshuffled(newPopups)
    }
    nonisolated func updatePopups(_ newPopups: [AnyPopup]) async {
        Task { @MainActor in popups = newPopups }
    }
    nonisolated func updatePriority(_ newPriority: StackPriority, _ oldPopupsCount: Int) async {
        let delayDuration = await oldPopupsCount > popups.count ? Animation.duration : 0
        await Task.sleep(seconds: delayDuration)

        Task { @MainActor in priority = newPriority }
    }
}
private extension PopupStack {
    nonisolated func insertedPopup(_ erasedPopup: AnyPopup) async -> [AnyPopup] { await popups.modifiedAsync(if: await !popups.contains { $0.id.isSameType(as: erasedPopup.id) }) {
        $0.append(await erasedPopup.startDismissTimerIfNeeded(self))
    }}
    nonisolated func removedLastPopup() async -> [AnyPopup] { await popups.modifiedAsync(if: !popups.isEmpty) {
        $0.removeLast()
    }}
    nonisolated func removedPopupInstance(_ popup: AnyPopup) async -> [AnyPopup] { await popups.modifiedAsync {
        $0.removeAll { $0.id.isSameInstance(as: popup) }
    }}
    nonisolated func removedAllPopupsOfType(_ popupType: any Popup.Type) async -> [AnyPopup] { await popups.modifiedAsync {
        $0.removeAll { $0.id.isSameType(as: popupType) }
    }}
    nonisolated func removedAllPopupsWithID(_ id: String) async -> [AnyPopup] { await popups.modifiedAsync {
        $0.removeAll { $0.id.isSameType(as: id) }
    }}
    nonisolated func removedAllPopups() async -> [AnyPopup] {
        []
    }
}



// MARK: - INSTACE OPERATIONS



// MARK: Fetch
extension PopupStack {
    nonisolated static func fetchInstance(id: PopupStackID) async -> PopupStack? {
        let managerObject = await PopupStackContainer.instances.first(where: { $0.id == id })
        await logNoInstanceErrorIfNeeded(managerObject: managerObject, popupManagerID: id)
        return managerObject
    }
}
private extension PopupStack {
    nonisolated static func logNoInstanceErrorIfNeeded(managerObject: PopupStack?, popupManagerID: PopupStackID) async { if managerObject == nil {
        Logger.log(
            level: .fault,
            message: "PopupManager instance (\(popupManagerID.rawValue)) must be registered before use. More details can be found in the documentation."
        )
    }}
}

// MARK: Register
extension PopupStack {
    static func registerStack(id: PopupStackID) -> PopupStack {
        let instanceToRegister = PopupStack(id: id)
        let registeredInstance = PopupStackContainer.register(popupManager: instanceToRegister)
        return registeredInstance
    }
}
