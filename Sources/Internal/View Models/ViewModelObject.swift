//
//  ViewModelObject.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

@MainActor protocol ViewModelObject: ObservableObject {
    func setup(updatePopupAction: @escaping (AnyPopup) -> (), closePopupAction: @escaping (AnyPopup) -> ())
    func updatePopupsValue(_ newPopups: [AnyPopup])
    func updateScreenValue(_ newScreen: Screen)
    func updateKeyboardValue(_ isActive: Bool)
}
