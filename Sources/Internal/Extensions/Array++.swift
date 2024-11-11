//
//  Array++.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


extension Array {
    func modified(if value: Bool = true, _ builder: (inout [Element]) async -> ()) async -> [Element] { guard value else { return self }
        var array = self
        await builder(&array)
        return array
    }
}
