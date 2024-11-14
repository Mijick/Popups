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

        register(stackIDs: popupStacksIDs)
        XCTAssertEqual(popupStacksIDs, getRegisteredStacks())
    }
    func test_registerStack_withUniqueStacksToRegister() {
        let popupStacksIDs: [PopupStackID] = [
            .staremiasto,
            .grzegorzki,
            .krowodrza,
            .bronowice
        ]

        register(stackIDs: popupStacksIDs)
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

        register(stackIDs: popupStacksIDs)
        XCTAssertNotEqual(popupStacksIDs, getRegisteredStacks())
        XCTAssertEqual(getRegisteredStacks().count, 6)
    }
}
private extension PopupStackTests {
    func register(stackIDs: [PopupStackID]) {
        stackIDs.forEach { _ = PopupStack.registerStack(id: $0) }
    }
    func getRegisteredStacks() -> [PopupStackID] {
        PopupStackContainer.stacks.map(\.id)
    }
}

// MARK: Fetch
extension PopupStackTests {
    func test_fetchStack_whenNoStacksAreRegistered() async {
        let stack = await PopupStack.fetch(id: .bronowice)
        XCTAssertNil(stack)
    }
    func test_fetchStack_whenStackIsNotRegistered() async {
        register(stackIDs: [
            .krowodrza,
            .staremiasto,
            .pradnikczerwony,
            .pradnikbialy,
            .grzegorzki
        ])

        let stack = await PopupStack.fetch(id: .bronowice)
        XCTAssertNil(stack)
    }
    func test_fetchStack_whenStackIsRegistered() async {
        register(stackIDs: [
            .krowodrza,
            .staremiasto,
            .grzegorzki
        ])

        let stack = await PopupStack.fetch(id: .grzegorzki)
        XCTAssertNotNil(stack)
    }
}

// MARK: Present Popup
extension PopupStackTests {
    func test_presentPopup_withThreePopupsToBePresented() async {
        await registerNewStackAndPresent(popups: [
            await AnyPopup(TestBottomPopup1()),
            await AnyPopup(TestBottomPopup2()),
            await AnyPopup(TestBottomPopup3())
        ])

        let popupsOnStack = await getPopupsForActiveStack()
        XCTAssertEqual(popupsOnStack.count, 3)
    }
    func test_presentPopup_withPopupsWithSameID() async {
        await registerNewStackAndPresent(popups: [
            await AnyPopup(TestBottomPopup1()),
            await AnyPopup(TestBottomPopup1()),
            await AnyPopup(TestBottomPopup1()),
        ])

        let popupsOnStack = await getPopupsForActiveStack()
        XCTAssertEqual(popupsOnStack.count, 2)
    }
    func test_presentPopup_withCustomID() async {
        await registerNewStackAndPresent(popups: [
            await AnyPopup(TestBottomPopup1()),
            await AnyPopup(TestBottomPopup1().setCustomID("2137")),
            await AnyPopup(TestBottomPopup1().setCustomID("I Pan Paweł oczywiście")),
        ])

        let popupsOnStack = await getPopupsForActiveStack()
        XCTAssertEqual(popupsOnStack.count, 3)
    }
    func test_presentPopup_withDismissAfter() async {
        await registerNewStackAndPresent(popups: [
            await AnyPopup(TestBottomPopup1()),
            await AnyPopup(TestBottomPopup1()).dismissAfter(0.7),
            await AnyPopup(TestBottomPopup1()).dismissAfter(1.5),
        ])

        let popupsOnStack1 = await getPopupsForActiveStack()
        XCTAssertEqual(popupsOnStack1.count, 3)

        await Task.sleep(seconds: 1)

        let popupsOnStack2 = await getPopupsForActiveStack()
        XCTAssertEqual(popupsOnStack2.count, 2)

        await Task.sleep(seconds: 1)

        let popupsOnStack3 = await getPopupsForActiveStack()
        XCTAssertEqual(popupsOnStack3.count, 1)
    }
}

// MARK: Dismiss Popup
extension PopupStackTests {
    func test_dismissLastPopup_withNoPopupsOnStack() async {
        await registerNewStackAndPresent(popups: [])
        await PopupStack.dismissLastPopup(popupStackID: defaultPopupStackID)

        let popupsOnStack = await getPopupsForActiveStack()
        XCTAssertEqual(popupsOnStack.count, 0)
    }
    func test_dismissLastPopup_withThreePopupsOnStack() async {
        await registerNewStackAndPresent(popups: [
            AnyPopup(TestBottomPopup1()),
            AnyPopup(TestBottomPopup2()),
            AnyPopup(TestBottomPopup3())
        ])
        await PopupStack.dismissLastPopup(popupStackID: defaultPopupStackID)

        let popupsOnStack = await getPopupsForActiveStack()
        XCTAssertEqual(popupsOnStack.count, 2)
    }
    func test_dismissPopupWithType_whenPopupOnStack() async {
        let popups: [AnyPopup] = await [
            .init(TestTopPopup()),
            .init(TestCenterPopup()),
            .init(TestBottomPopup1())
        ]
        await registerNewStackAndPresent(popups: popups)

        let popupsOnStackBefore = await getPopupsForActiveStack()
        XCTAssertEqual(popups, popupsOnStackBefore)

        await PopupStack.dismissPopup(TestBottomPopup1.self, popupStackID: defaultPopupStackID)

        let popupsOnStackAfter = await getPopupsForActiveStack()
        XCTAssertEqual([popups[0], popups[1]], popupsOnStackAfter)
    }
    func test_dismissPopupWithType_whenPopupNotOnStack() {
        let popups: [AnyPopup] = [
            .init(TestTopPopup()),
            .init(TestBottomPopup())
        ]
        await registerNewStackAndPresent(popups: popups)

        let popupsOnStackBefore = getPopupsForActiveStack()
        XCTAssertEqual(popups, popupsOnStackBefore)

        PopupStack.dismissPopup(TestCenterPopup.self, popupManagerID: defaultPopupManagerID)

        let popupsOnStackAfter = getPopupsForActiveStack()
        XCTAssertEqual(popups, popupsOnStackAfter)
    }
    func test_dismissPopupWithType_whenPopupHasCustomID() {
        let popups: [AnyPopup] = [
            .init(TestTopPopup().setCustomID("2137")),
            .init(TestBottomPopup())
        ]
        await registerNewStackAndPresent(popups: popups)

        let popupsOnStackBefore = getPopupsForActiveStack()
        XCTAssertEqual(popups, popupsOnStackBefore)

        PopupStack.dismissPopup(TestTopPopup.self, popupManagerID: defaultPopupManagerID)

        let popupsOnStackAfter = getPopupsForActiveStack()
        XCTAssertEqual(popups, popupsOnStackAfter)
    }
    func test_dismissPopupWithID_whenPopupHasCustomID() {
        let popups: [AnyPopup] = [
            .init(TestTopPopup().setCustomID("2137")),
            .init(TestBottomPopup())
        ]
        await registerNewStackAndPresent(popups: popups)

        let popupsOnStackBefore = getPopupsForActiveStack()
        XCTAssertEqual(popups, popupsOnStackBefore)

        PopupStack.dismissPopup("2137", popupManagerID: defaultPopupManagerID)

        let popupsOnStackAfter = getPopupsForActiveStack()
        XCTAssertEqual([popups[1]], popupsOnStackAfter)
    }
    func test_dismissAllPopups() {
        registerNewInstanceAndPresentPopups(popups: [
            AnyPopup.t_createNew(config: LocalConfigVertical.Bottom()),
            AnyPopup.t_createNew(config: LocalConfigVertical.Bottom()),
            AnyPopup.t_createNew(config: LocalConfigVertical.Bottom())
        ])
        PopupStack.dismissAllPopups(popupManagerID: defaultPopupManagerID)

        let popupsOnStack = getPopupsForActiveStack()
        XCTAssertEqual(popupsOnStack.count, 0)
    }
}



// MARK: - HELPERS



// MARK: Methods
private extension PopupStackTests {
    func registerNewStackAndPresent(popups: [any Popup]) async {
        register(stackIDs: [defaultPopupStackID])
        for popup in popups { await popup.present(popupStackID: defaultPopupStackID) }
    }
    func getPopupsForActiveStack() async -> [AnyPopup] {
        await PopupStack
            .fetch(id: defaultPopupStackID)?
            .popups ?? []
    }
}

// MARK: Variables
private extension PopupStackTests {
    var defaultPopupStackID: PopupStackID { .staremiasto }
}

// MARK: Popup Manager Identifiers
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
