//
//  ID+Popup.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import Foundation

struct PopupID: Sendable {
    let rawValue: String
}

// MARK: Create
extension PopupID {
    init(_ id: String) async {
        let firstComponent = id,
            secondComponent = Self.separator,
            thirdComponent = String(describing: Date())
        self.init(rawValue: firstComponent + secondComponent + thirdComponent)
    }
    init(_ popupType: any Popup.Type) async {
        await self.init(.init(describing: popupType))
    }
}

// MARK: Comparison
extension PopupID {
    func isSame(as popup: AnyPopup) -> Bool { rawValue == popup.id.rawValue }
    func isSameType(as id: String) -> Bool { getFirstComponent(of: self) == id }
    func isSameType(as popupType: any Popup.Type) -> Bool { getFirstComponent(of: self) == String(describing: popupType) }
    func isSameType(as popupID: PopupID) -> Bool { getFirstComponent(of: self) == getFirstComponent(of: popupID) }
}


// MARK: - HELPERS



// MARK: Methods
private extension PopupID {
    func getFirstComponent(of object: Self) -> String { object.rawValue.components(separatedBy: Self.separator).first ?? "" }
}

// MARK: Variables
private extension PopupID {
    static var separator: String { "/{}/" }
}
