//
//  Array++.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


// MARK: Modified
extension Array {
    func modifiedAsync(if value: Bool = true, _ builder: (inout [Element]) async -> ()) async -> [Element] { guard value else { return self }
        var array = self
        await builder(&array)
        return array
    }
    func modified(if value: Bool = true, _ builder: (inout [Element]) -> ()) -> [Element] { guard value else { return self }
        var array = self
        builder(&array)
        return array
    }
}

// MARK: Inverted Index
extension Array where Element: Equatable {
    func getInvertedIndex(of element: Element) -> Int {
        let index = firstIndex(of: element) ?? 0
        let invertedIndex = count - 1 - index
        return invertedIndex
    }
}
