//
//  DragGestureState.swift of MijickPopups
//
//  Created by Alina Petrovska
//    - Mail: alina.petrovskaya@mijick.com
//    - GitHub: https://github.com/alina-p-k
//
//  Copyright ©2025 Mijick. All rights reserved.
		

import SwiftUI

struct DragGestureState {
    let startLocationY: Double
    let height: Double 
}

extension DragGestureState {
    init(_ value: DragGesture.Value) {
        self.startLocationY = value.startLocation.y
        self.height = value.translation.height
    }
}
