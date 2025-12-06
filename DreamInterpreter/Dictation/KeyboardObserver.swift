//
//  KeyboardObserver.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/5/25.
//


import SwiftUI
import Combine

class KeyboardObserver: ObservableObject {
    @Published var keyboardIsVisible: Bool = false
    @Published var keyboardHeight: CGFloat = 0 {
        didSet {
            keyboardIsVisible = !keyboardHeight.isZero
        }
    }
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .sink { [weak self] notification in
                guard let self = self else { return }

                if notification.name == UIResponder.keyboardWillHideNotification {
                    self.keyboardHeight = 0
                } else if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.keyboardHeight = frame.height
                }
            }
            .store(in: &cancellables)
    }
}
