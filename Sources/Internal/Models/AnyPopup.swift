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
    private(set) var height: CGFloat? = nil
    private(set) var dragHeight: CGFloat? = nil

    private var _dismissTimer: PopupActionScheduler? = nil
    private var _body: AnyView
    private let _onFocus: () -> ()
    private let _onDismiss: () -> ()
}



// MARK: - INITIALIZE & UPDATE



// MARK: Initialize
extension AnyPopup {
    init<P: Popup>(_ popup: P) {
        if let popup = popup as? AnyPopup { self = popup }
        else {
            self.id = .init(P.self)
            self.config = .init(popup.configurePopup(config: .init()))
            self._body = .init(popup)
            self._onFocus = popup.onFocus
            self._onDismiss = popup.onDismiss
        }
    }
}

// MARK: Update
extension AnyPopup {
    nonisolated func updatedHeight(_ newHeight: CGFloat?) async -> AnyPopup { await updatedAsync { $0.height = newHeight }}
    nonisolated func updatedDragHeight(_ newDragHeight: CGFloat?) async -> AnyPopup { await updatedAsync { $0.dragHeight = newDragHeight }}
    func updatedID(_ customID: String) -> AnyPopup { updated { $0.id = .init(customID) }}
    func updatedDismissTimer(_ secondsToDismiss: Double) -> AnyPopup { updated { $0._dismissTimer = .prepare(time: secondsToDismiss) }}
    func updatedEnvironmentObject(_ environmentObject: some ObservableObject) -> AnyPopup { updated { $0._body = .init(_body.environmentObject(environmentObject)) }}
    func startDismissTimerIfNeeded(_ popupManager: PopupManager) -> AnyPopup { updated { $0._dismissTimer?.schedule { popupManager.stack(.removePopupInstance(self)) }}}
}
private extension AnyPopup {
    func updated(_ customBuilder: (inout AnyPopup) -> ()) -> AnyPopup {
        var popup = self
        customBuilder(&popup)
        return popup
    }
    nonisolated func updatedAsync(_ customBuilder: (inout AnyPopup) async -> ()) async -> AnyPopup {
        var popup = self
        await customBuilder(&popup)
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
        id: .init(id),
        config: .init(config),
        height: nil,
        dragHeight: nil,
        _dismissTimer: nil,
        _body: .init(EmptyView()),
        _onFocus: {},
        _onDismiss: {}
    )}
}
#endif
