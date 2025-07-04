//
//  GlobalConfigContainer.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2023 Mijick. All rights reserved.

@MainActor
public class GlobalConfigContainer {
    static var center: GlobalConfigCenter = .init()
    static var vertical: GlobalConfigVertical = .init()
}
