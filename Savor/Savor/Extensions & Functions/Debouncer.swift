//
//  Debouncer.swift
//  Savor
//
//  Created by Edgar Sia on 3/23/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Foundation

class Debouncer {
    private let delay: TimeInterval
    private var timer: Timer?

    var handler: () -> Void

    init(delay: TimeInterval, handler: @escaping () -> Void) {
        self.delay = delay
        self.handler = handler
    }

    func call() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { [weak self] _ in
            self?.handler()
        })
    }

    func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}
