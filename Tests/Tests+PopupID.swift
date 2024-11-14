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
    func test_createPopupID_1() {
        let dateString = String(describing: Date())

        let popupID = PopupID.create(from: TestTopPopup.self)
        let idComponents = popupID.rawValue.components(separatedBy: "/{}/")

        XCTAssertEqual(idComponents.count, 2)
        XCTAssertEqual(idComponents[0], "TestTopPopup")
        XCTAssertEqual(idComponents[1], dateString)
    }
    func test_createPopupID_2() {
        let dateString = String(describing: Date())

        let popupID = PopupID.create(from: TestCentrePopup.self)
        let idComponents = popupID.rawValue.components(separatedBy: "/{}/")

        XCTAssertEqual(idComponents.count, 2)
        XCTAssertEqual(idComponents[0], "TestCentrePopup")
        XCTAssertEqual(idComponents[1], dateString)
    }
}

// MARK: Is Same Type
extension PopupIDTests {
    func test_isSameType_1() {
        let popupID1 = PopupID.create(from: TestTopPopup.self),
            popupID2 = PopupID.create(from: TestBottomPopup.self)

        let result = popupID1.isSameType(as: popupID2)
        XCTAssertEqual(result, false)
    }
    func test_isSameType_2() {
        let popupID1 = PopupID.create(from: TestTopPopup.self),
            popupID2 = "TestTopPopup"

        let result = popupID1.isSameType(as: popupID2)
        XCTAssertEqual(result, true)
    }
    func test_isSameType_3() {
        let popupID1 = PopupID.create(from: "2137"),
            popupID2 = "2137"

        let result = popupID1.isSameType(as: popupID2)
        XCTAssertEqual(result, true)
    }
    func test_isSameType_4() {
        let popupID1 = AnyPopup(TestTopPopup().setCustomID("2137")).id,
            popupID2 = AnyPopup(TestTopPopup()).id

        let result = popupID1.isSameType(as: popupID2)
        XCTAssertEqual(result, false)
    }
    func test_isSameType_5() async {
        let popupID1 = PopupID.create(from: TestTopPopup.self)
        await Task.sleep(seconds: 1)
        let popupID2 = PopupID.create(from: TestTopPopup.self)

        let result = popupID1.isSameType(as: popupID2)
        XCTAssertEqual(result, true)
    }
}

// MARK: Is Same Instance
extension PopupIDTests {
    func test_isSameInstance_1() {
        let popupID = PopupID.create(from: TestTopPopup.self),
            popup = AnyPopup(TestCentrePopup())

        let result = popupID.isSame(as: popup)
        XCTAssertEqual(result, false)
    }
    func test_isSameInstance_2() {
        let popupID = PopupID.create(from: TestTopPopup.self),
            popup = AnyPopup(TestTopPopup())

        let result = popupID.isSame(as: popup)
        XCTAssertEqual(result, true)
    }
    func test_isSameInstance_3() async {
        let popupID = PopupID.create(from: TestTopPopup.self)
        await Task.sleep(seconds: 1)
        let popup = AnyPopup(TestTopPopup())

        let result = popupID.isSame(as: popup)
        XCTAssertEqual(result, false)
    }
}



// MARK: - HELPERS



// MARK: Test Popups
private struct TestTopPopup: TopPopup {
    var body: some View { EmptyView() }
}
private struct TestCentrePopup: CentrePopup {
    var body: some View { EmptyView() }
}
private struct TestBottomPopup: BottomPopup {
    var body: some View { EmptyView() }
}
