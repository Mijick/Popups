//
//  PopupActionScheduler.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import Foundation

@MainActor
class PopupActionScheduler {
    private var time: Double = 0
    private var action: DispatchSourceTimer?
}

// MARK: Prepare
extension PopupActionScheduler {
    static func prepare(time: Double) -> PopupActionScheduler {
        let scheduler = PopupActionScheduler()
        scheduler.time = time
        return scheduler
    }
}

// MARK: Schedule
extension PopupActionScheduler {
    func schedule(action: @escaping () -> ()) {
        self.action = DispatchSource.makeTimerSource(queue: .main)
        self.action?.schedule(deadline: .now() + max(0.6, time))
        self.action?.setEventHandler(handler: action)
        self.action?.resume()
    }
}
