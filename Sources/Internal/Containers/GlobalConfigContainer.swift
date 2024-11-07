//
//  GlobalConfigContainer.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2023 Mijick. All rights reserved.


public actor GlobalConfigContainer {
    nonisolated(unsafe) static var centre: GlobalConfigCentre = .init()
    nonisolated(unsafe) static var vertical: GlobalConfigVertical = .init()
}
