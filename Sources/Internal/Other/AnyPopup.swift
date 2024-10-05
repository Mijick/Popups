//
//  AnyPopup.swift of PopupView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import SwiftUI

struct AnyPopup: Popup, Hashable {
    func createContent() -> AnyView { _body }
    func onFocus() { _onFocus() }
    func onDismiss() { _onDismiss() }

    typealias Config = LocalConfig
    
    var id: PopupID
    let config: LocalConfig

    var dismissTimer: PopupActionScheduler? = nil

    var _onFocus: () -> () = {}
    var _onDismiss: () -> () = {}
    var height: CGFloat? = nil
    var dragHeight: CGFloat? = nil
    var _body: AnyView


    init<P: Popup>(_ popup: P, id: PopupManagerID?) {
        if let popup = popup as? AnyPopup {
            self = popup
            
        } else {


            self.id = .create(from: P.self)
            self.config = popup.configurePopup(popup: .init())

            self._onFocus = popup.onFocus
            self._onDismiss = popup.onDismiss


            self._body = AnyView(popup)
        }


        if let id {
            dismissTimer?.schedule { [self] in
                PopupManager.getInstance(id)?.performOperation(.removeExact(self.id))
            }
        }
    }
}

// MARK: - Hashable
extension AnyPopup {
    static func == (lhs: AnyPopup, rhs: AnyPopup) -> Bool { lhs.id.isSameInstance(as: rhs.id) }
    func hash(into hasher: inout Hasher) { hasher.combine(id.rawValue) }
}


// MARK: - Testing
#if DEBUG
extension AnyPopup {
    init(id: String = UUID().uuidString, config: LocalConfig) {
        self.id = .create(from: id)
        self.config = config
        self.dismissTimer = nil
        self.height = nil
        self.dragHeight = nil
        self._body = .init(erasing: EmptyView())
    }
}
#endif
