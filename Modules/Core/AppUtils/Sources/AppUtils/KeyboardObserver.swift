//
//  KeyboardObserver.swift
//  AppUtils
//
//  Created by Ameya on 03/12/25.
//

import Combine
import UIKit

@MainActor
public final class KeyboardObserver: ObservableObject {
    @Published public var height: CGFloat = 0

    public init() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { notif in
            guard let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            let screenHeight = UIScreen.main.bounds.height
            self.height = max(0, screenHeight - frame.origin.y)
        }
    }
}
