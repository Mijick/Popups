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
    func update(popup: AnyPopup) async { if let index = popups.firstIndex(of: popup) {
        popups[index] = popup
    }}
}


// MARK: - STACK OPERATIONS



// MARK: Modify
extension PopupStack { enum StackOperation {
    case insertPopup(AnyPopup)
    case removeLastPopup, removePopup(AnyPopup), removeAllPopupsOfType(any Popup.Type), removeAllPopupsWithID(String), removeAllPopups
}}
extension PopupStack {
    func modify(_ operation: StackOperation) { Task {
        // If the popup should dismiss keyboard, dismiss it
        await hideKeyboard(operation)

        let oldPopups = popups
        let newPopups = await getNewPopups(operation)
        let newPriority = await getNewPriority(newPopups)

        await updatePopups(newPopups)
        await updatePriority(newPriority, oldPopups.count)
    }}
}
private extension PopupStack {
    nonisolated func hideKeyboard(_ operation: StackOperation) async {
        switch operation {
        case .insertPopup(let popup):
            guard popup.shouldDismissKeyboardOnPopupToggle else { return }
            await AnyView.hideKeyboard()
        default:
            guard await popups.last?.shouldDismissKeyboardOnPopupToggle ?? true else { return }
            await AnyView.hideKeyboard()
        }
    }
    nonisolated func getNewPopups(_ operation: StackOperation) async -> [AnyPopup] { switch operation {
        case .insertPopup(let popup): await insertedPopup(popup)
        case .removeLastPopup: await removedLastPopup()
        case .removePopup(let popup): await removedPopup(popup)
        case .removeAllPopupsOfType(let popupType): await removedAllPopupsOfType(popupType)
        case .removeAllPopupsWithID(let id): await removedAllPopupsWithID(id)
        case .removeAllPopups: await removedAllPopups()
    }}
    nonisolated func getNewPriority(_ newPopups: [AnyPopup]) async -> StackPriority {
        await priority.reshuffled(newPopups)
    }
    func updatePopups(_ newPopups: [AnyPopup]) async {
        popups = newPopups
    }
    func updatePriority(_ newPriority: StackPriority, _ oldPopupsCount: Int) async {
        let delayDuration = oldPopupsCount > popups.count ? Animation.duration : 0
        await Task.sleep(seconds: delayDuration)

        priority = newPriority
    }
}
private extension PopupStack {
    nonisolated func insertedPopup(_ erasedPopup: AnyPopup) async -> [AnyPopup] { await popups.modifiedAsync(if: await !popups.contains { $0.id.isSameType(as: erasedPopup.id) }) {
        $0.append(await erasedPopup.startDismissTimerIfNeeded(self))
    }}
    nonisolated func removedLastPopup() async -> [AnyPopup] { await popups.modifiedAsync(if: !popups.isEmpty) {
        $0.removeLast()
    }}
    nonisolated func removedPopup(_ popup: AnyPopup) async -> [AnyPopup] { await popups.modifiedAsync {
        $0.removeAll { $0.id.isSame(as: popup) }
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


// MARK: - STACK CONTAINER OPERATIONS



// MARK: Fetch
extension PopupStack {
    nonisolated static func fetch(id: PopupStackID) async -> PopupStack? {
        let stack = await PopupStackContainer.stacks.first(where: { $0.id == id })
        await logNoStackRegisteredErrorIfNeeded(stack: stack, id: id)
        return stack
    }
}
private extension PopupStack {
    nonisolated static func logNoStackRegisteredErrorIfNeeded(stack: PopupStack?, id: PopupStackID) async { if stack == nil {
        Logger.log(
            level: .fault,
            message: "PopupStack (\(id.rawValue)) must be registered before use. More details can be found in the documentation."
        )
    }}
}

// MARK: Register
extension PopupStack {
    static func registerStack(id: PopupStackID) -> PopupStack {
        let stackToRegister = PopupStack(id: id)
        let registeredStack = PopupStackContainer.register(stack: stackToRegister)
        return registeredStack
    }
}
