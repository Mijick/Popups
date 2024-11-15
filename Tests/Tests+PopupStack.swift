//
//  Tests+PopupStack.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import XCTest
import SwiftUI
@testable import MijickPopups

@MainActor final class PopupStackTests: XCTestCase {
    override func setUp() async throws {
        PopupStackContainer.clean()
    }
}



// MARK: - TEST CASES



// MARK: Register
extension PopupStackTests {
    func test_registerStack_withNoStacksToRegister() {
        let popupStacksIDs: [PopupStackID] = []

        registerStacks(ids: popupStacksIDs)
        XCTAssertEqual(popupStacksIDs, getRegisteredStacks())
    }
    func test_registerStack_withUniqueStacksToRegister() {
        let popupStacksIDs: [PopupStackID] = [
            .staremiasto,
            .grzegorzki,
            .krowodrza,
            .bronowice
        ]

        registerStacks(ids: popupStacksIDs)
        XCTAssertEqual(popupStacksIDs, getRegisteredStacks())
    }
    func test_registerStack_withRepeatingStacksToRegister() {
        let popupStacksIDs: [PopupStackID] = [
            .staremiasto,
            .grzegorzki,
            .krowodrza,
            .bronowice,
            .bronowice,
            .pradnikbialy,
            .pradnikczerwony,
            .krowodrza
        ]

        registerStacks(ids: popupStacksIDs)
        XCTAssertNotEqual(popupStacksIDs, getRegisteredStacks())
        XCTAssertEqual(getRegisteredStacks().count, 6)
    }
}

// MARK: Fetch
extension PopupStackTests {
    func test_fetchStack_whenNoStacksAreRegistered() async { Task {
        let stack = await PopupStack.fetch(id: .bronowice)
        XCTAssertNil(stack)
    }}
    func test_fetchStack_whenStackIsNotRegistered() async { Task {
        registerStacks(ids: [
            .krowodrza,
            .staremiasto,
            .pradnikczerwony,
            .pradnikbialy,
            .grzegorzki
        ])

        let stack = await PopupStack.fetch(id: .bronowice)
        XCTAssertNil(stack)
    }}
    func test_fetchStack_whenStackIsRegistered() async { Task {
        registerStacks(ids: [
            .krowodrza,
            .staremiasto,
            .grzegorzki
        ])

        let stack = await PopupStack.fetch(id: .grzegorzki)
        XCTAssertNotNil(stack)
    }}
}

// MARK: Present Popup
extension PopupStackTests {
    func test_presentPopup_withThreePopupsToBePresented() async { Task {
        await registerNewStackAndPresent(popups: [
            await AnyPopup(TestBottomPopup1()),
            await AnyPopup(TestBottomPopup2()),
            await AnyPopup(TestBottomPopup3())
        ])

        let popupsOnStack = await getPopupsForDefaultStack()
        XCTAssertEqual(popupsOnStack.count, 3)
    }}
    func test_presentPopup_withPopupsWithSameID() async { Task {
        await registerNewStackAndPresent(popups: [
            await AnyPopup(TestBottomPopup1()),
            await AnyPopup(TestBottomPopup1()),
            await AnyPopup(TestBottomPopup1()),
        ])

        let popupsOnStack = await getPopupsForDefaultStack()
        XCTAssertEqual(popupsOnStack.count, 2)
    }}
    func test_presentPopup_withCustomID() async { Task {
        await registerNewStackAndPresent(popups: [
            await AnyPopup(TestBottomPopup1()),
            await AnyPopup(TestBottomPopup1().setCustomID("2137")),
            await AnyPopup(TestBottomPopup1().setCustomID("I Pan Paweł oczywiście")),
        ])

        let popupsOnStack = await getPopupsForDefaultStack()
        XCTAssertEqual(popupsOnStack.count, 3)
    }}
    func test_presentPopup_withDismissAfter() async { Task {
        await registerNewStackAndPresent(popups: [
            await AnyPopup(TestBottomPopup1()),
            await AnyPopup(TestBottomPopup1()).dismissAfter(0.7),
            await AnyPopup(TestBottomPopup1()).dismissAfter(1.5),
        ])

        let popupsOnStack1 = await getPopupsForDefaultStack()
        XCTAssertEqual(popupsOnStack1.count, 3)

        await Task.sleep(seconds: 1)

        let popupsOnStack2 = await getPopupsForDefaultStack()
        XCTAssertEqual(popupsOnStack2.count, 2)

        await Task.sleep(seconds: 1)

        let popupsOnStack3 = await getPopupsForDefaultStack()
        XCTAssertEqual(popupsOnStack3.count, 1)
    }}
}

// MARK: Dismiss Popup
extension PopupStackTests {
    func test_dismissLastPopup_withNoPopupsOnStack() async { Task {
        await registerNewStackAndPresent(popups: [])
        await PopupStack.dismissLastPopup(popupStackID: defaultPopupStackID)

        let popupsOnStack = await getPopupsForDefaultStack()
        XCTAssertEqual(popupsOnStack.count, 0)
    }}
    func test_dismissLastPopup_withThreePopupsOnStack() async { Task {
        await registerNewStackAndPresent(popups: [
            AnyPopup(TestBottomPopup1()),
            AnyPopup(TestBottomPopup2()),
            AnyPopup(TestBottomPopup3())
        ])
        await PopupStack.dismissLastPopup(popupStackID: defaultPopupStackID)

        let popupsOnStack = await getPopupsForDefaultStack()
        XCTAssertEqual(popupsOnStack.count, 2)
    }}
    func test_dismissPopupWithType_whenPopupOnStack() async { Task {
        let popups: [AnyPopup] = await [
            .init(TestTopPopup()),
            .init(TestCenterPopup()),
            .init(TestBottomPopup1())
        ]
        await registerNewStackAndPresent(popups: popups)

        let popupsOnStackBefore = await getPopupsForDefaultStack()
        XCTAssertEqual(popups, popupsOnStackBefore)

        await PopupStack.dismissPopup(TestBottomPopup1.self, popupStackID: defaultPopupStackID)

        let popupsOnStackAfter = await getPopupsForDefaultStack()
        XCTAssertEqual([popups[0], popups[1]], popupsOnStackAfter)
    }}
    func test_dismissPopupWithType_whenPopupNotOnStack() async { Task {
        let popups: [AnyPopup] = await [
            .init(TestTopPopup()),
            .init(TestBottomPopup1())
        ]
        await registerNewStackAndPresent(popups: popups)

        let popupsOnStackBefore = await getPopupsForDefaultStack()
        XCTAssertEqual(popups, popupsOnStackBefore)

        await PopupStack.dismissPopup(TestCenterPopup.self, popupStackID: defaultPopupStackID)

        let popupsOnStackAfter = await getPopupsForDefaultStack()
        XCTAssertEqual(popups, popupsOnStackAfter)
    }}
    func test_dismissPopupWithType_whenPopupHasCustomID() async { Task {
        let popups: [AnyPopup] = await [
            .init(TestTopPopup().setCustomID("2137")),
            .init(TestBottomPopup1())
        ]
        await registerNewStackAndPresent(popups: popups)

        let popupsOnStackBefore = await getPopupsForDefaultStack()
        XCTAssertEqual(popups, popupsOnStackBefore)

        await PopupStack.dismissPopup(TestTopPopup.self, popupStackID: defaultPopupStackID)

        let popupsOnStackAfter = await getPopupsForDefaultStack()
        XCTAssertEqual(popups, popupsOnStackAfter)
    }}
    func test_dismissPopupWithID_whenPopupHasCustomID() async {  Task {
        let popups: [AnyPopup] = await [
            .init(TestTopPopup().setCustomID("2137")),
            .init(TestBottomPopup1())
        ]
        await registerNewStackAndPresent(popups: popups)

        let popupsOnStackBefore = await getPopupsForDefaultStack()
        XCTAssertEqual(popups, popupsOnStackBefore)

        await PopupStack.dismissPopup("2137", popupStackID: defaultPopupStackID)

        let popupsOnStackAfter = await getPopupsForDefaultStack()
        XCTAssertEqual([popups[1]], popupsOnStackAfter)
    }}
    func test_dismissAllPopups() async { Task {
        await registerNewStackAndPresent(popups: [
            AnyPopup(TestBottomPopup1()),
            AnyPopup(TestBottomPopup2()),
            AnyPopup(TestBottomPopup3())
        ])
        await PopupStack.dismissAllPopups(popupStackID: defaultPopupStackID)

        let popupsOnStack = await getPopupsForDefaultStack()
        XCTAssertEqual(popupsOnStack.count, 0)
    }}
}



// MARK: - HELPERS



// MARK: Methods
private extension PopupStackTests {
    func registerNewStackAndPresent(popups: [any Popup]) async {
        registerStacks(ids: [defaultPopupStackID])
        for popup in popups { await popup.present(popupStackID: defaultPopupStackID) }
    }
    func getPopupsForDefaultStack() async -> [AnyPopup] {
        await PopupStack
            .fetch(id: defaultPopupStackID)?
            .popups ?? []
    }
}
private extension PopupStackTests {
    func registerStacks(ids: [PopupStackID]) {
        ids.forEach { _ = PopupStack.registerStack(id: $0) }
    }
    func getRegisteredStacks() -> [PopupStackID] {
        PopupStackContainer.stacks.map(\.id)
    }
}

// MARK: Variables
private extension PopupStackTests {
    var defaultPopupStackID: PopupStackID { .staremiasto }
}

// MARK: Popup Stack Identifiers
private extension PopupStackID {
    static let staremiasto: Self = .init(rawValue: "staremiasto")
    static let grzegorzki: Self = .init(rawValue: "grzegorzki")
    static let pradnikczerwony: Self = .init(rawValue: "pradnikczerwony")
    static let pradnikbialy: Self = .init(rawValue: "pradnikbialy")
    static let krowodrza: Self = .init(rawValue: "krowodrza")
    static let bronowice: Self = .init(rawValue: "bronowice")
}

// MARK: Test Popups
private struct TestTopPopup: TopPopup {
    var body: some View { EmptyView() }
}
private struct TestCenterPopup: CenterPopup {
    var body: some View { EmptyView() }
}
private struct TestBottomPopup1: BottomPopup {
    var body: some View { EmptyView() }
}
private struct TestBottomPopup2: BottomPopup {
    var body: some View { EmptyView() }
}
private struct TestBottomPopup3: BottomPopup {
    var body: some View { EmptyView() }
}
