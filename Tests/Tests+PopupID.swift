//
//  Tests+PopupID.swift of MijickPopups
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

@MainActor final class PopupIDTests: XCTestCase {}



// MARK: - TEST CASES



// MARK: Create ID
extension PopupIDTests {
    func test_createPopupID_1() async {
        let dateString = String(describing: Date())

        let popupID = await PopupID(TestTopPopup.self)
        let idComponents = popupID.rawValue.components(separatedBy: "/{}/")

        XCTAssertEqual(idComponents.count, 2)
        XCTAssertEqual(idComponents[0], "TestTopPopup")
        XCTAssertEqual(idComponents[1], dateString)
    }
    func test_createPopupID_2() async {
        let dateString = String(describing: Date())

        let popupID = await PopupID(TestCenterPopup.self)
        let idComponents = popupID.rawValue.components(separatedBy: "/{}/")

        XCTAssertEqual(idComponents.count, 2)
        XCTAssertEqual(idComponents[0], "TestCenterPopup")
        XCTAssertEqual(idComponents[1], dateString)
    }
}

// MARK: Is Same Type
extension PopupIDTests {
    func test_isSameType_1() async {
        let popupID1 = await PopupID(TestTopPopup.self),
            popupID2 = await PopupID(TestBottomPopup.self)

        let result = popupID1.isSameType(as: popupID2)
        XCTAssertEqual(result, false)
    }
    func test_isSameType_2() async {
        let popupID1 = await PopupID(TestTopPopup.self),
            popupID2 = "TestTopPopup"

        let result = popupID1.isSameType(as: popupID2)
        XCTAssertEqual(result, true)
    }
    func test_isSameType_3() async {
        let popupID1 = await PopupID("2137"),
            popupID2 = "2137"

        let result = popupID1.isSameType(as: popupID2)
        XCTAssertEqual(result, true)
    }
    func test_isSameType_4() async {
        let popupID1 = await AnyPopup(TestTopPopup().setCustomID("2137")).id,
            popupID2 = "2137"

        let result = popupID1.isSameType(as: popupID2)
        XCTAssertEqual(result, true)
    }
    func test_isSameType_5() async {
        let popupID1 = await AnyPopup(TestTopPopup().setCustomID("2137")).id,
            popupID2 = await AnyPopup(TestTopPopup()).id

        let result = popupID1.isSameType(as: popupID2)
        XCTAssertEqual(result, false)
    }
    func test_isSameType_6() async {
        let popupID1 = await PopupID(TestTopPopup.self)
        await Task.sleep(seconds: 1)
        let popupID2 = await PopupID(TestTopPopup.self)

        let result = popupID1.isSameType(as: popupID2)
        XCTAssertEqual(result, true)
    }
}

// MARK: Is Same
extension PopupIDTests {
    func test_isSame_1() async {
        let popupID = await PopupID(TestTopPopup.self),
            popup = await AnyPopup(TestCenterPopup())

        let result = popupID.isSame(as: popup)
        XCTAssertEqual(result, false)
    }
    func test_isSame_2() async {
        let popupID = await PopupID(TestTopPopup.self),
            popup = await AnyPopup(TestTopPopup())

        let result = popupID.isSame(as: popup)
        XCTAssertEqual(result, true)
    }
    func test_isSame_3() async {
        let popupID = await PopupID(TestTopPopup.self)
        await Task.sleep(seconds: 1)
        let popup = await AnyPopup(TestTopPopup())

        let result = popupID.isSame(as: popup)
        XCTAssertEqual(result, false)
    }
}



// MARK: - HELPERS



// MARK: Test Popups
private struct TestTopPopup: TopPopup {
    var body: some View { EmptyView() }
}
private struct TestCenterPopup: CenterPopup {
    var body: some View { EmptyView() }
}
private struct TestBottomPopup: BottomPopup {
    var body: some View { EmptyView() }
}
