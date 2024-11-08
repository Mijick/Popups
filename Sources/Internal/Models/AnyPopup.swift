//
//  AnyPopup.swift of MijickPopups
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2023 Mijick. All rights reserved.


import SwiftUI

struct AnyPopup: Popup {
    private(set) var id: PopupID
    private(set) var config: AnyPopupConfig
    var height: CGFloat? = nil
    var dragHeight: CGFloat? = nil

    private var dismissTimer: PopupActionScheduler? = nil
    private var _body: AnyView
    private let _onFocus: () -> ()
    private let _onDismiss: () -> ()
}



// MARK: - INITIALISE & UPDATE



// MARK: Initialise
extension AnyPopup {
    init<P: Popup>(_ popup: P) {
        if let popup = popup as? AnyPopup { self = popup }
        else {
            self.id = .create(from: P.self)
            self.config = .init(popup.configurePopup(config: .init()))
            self._body = .init(popup)
            self._onFocus = popup.onFocus
            self._onDismiss = popup.onDismiss
        }
    }
}

// MARK: Update
extension AnyPopup {
    func settingCustomID(_ customID: String) -> AnyPopup { updatingPopup { $0.id = .create(from: customID) }}
    func settingDismissTimer(_ secondsToDismiss: Double) -> AnyPopup { updatingPopup { $0.dismissTimer = .prepare(time: secondsToDismiss) }}
    func startingDismissTimerIfNeeded(_ popupManager: PopupManager) -> AnyPopup { updatingPopup { $0.dismissTimer?.schedule { popupManager.stack(.removePopupInstance(self)) }}}
    func settingHeight(_ newHeight: CGFloat?) -> AnyPopup { updatingPopup { $0.height = newHeight }}
    func settingDragHeight(_ newDragHeight: CGFloat?) -> AnyPopup { updatingPopup { $0.dragHeight = newDragHeight }}
    func settingEnvironmentObject(_ environmentObject: some ObservableObject) -> AnyPopup { updatingPopup { $0._body = .init(_body.environmentObject(environmentObject)) }}
}
extension AnyPopup {
    func updatingPopup(_ customBuilder: (inout AnyPopup) -> ()) -> AnyPopup {
        var popup = self
        customBuilder(&popup)
        return popup
    }
}



// MARK: - PROTOCOLS CONFORMANCE



// MARK: Popup
extension AnyPopup { typealias Config = AnyPopupConfig
    var body: some View { _body }

    func onFocus() { _onFocus() }
    func onDismiss() { _onDismiss() }
}

// MARK: Hashable
extension AnyPopup: Hashable {
    nonisolated static func ==(lhs: AnyPopup, rhs: AnyPopup) -> Bool { lhs.id.isSameInstance(as: rhs) }
    nonisolated func hash(into hasher: inout Hasher) { hasher.combine(id.rawValue) }
}



// MARK: - TESTS
#if DEBUG



// MARK: New Object
extension AnyPopup {
    static func t_createNew(id: String = UUID().uuidString, config: LocalConfig) -> AnyPopup { .init(
        id: .create(from: id),
        config: .init(config),
        height: nil,
        dragHeight: nil,
        dismissTimer: nil,
        _body: .init(EmptyView()),
        _onFocus: {},
        _onDismiss: {}
    )}
}
#endif
