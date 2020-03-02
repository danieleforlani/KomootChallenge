//
//  Scheduler.swift
//  AppFoundation
//
//  Created by Daniele Forlani on 09/08/2019.
//  Copyright © 2019 Attio. All rights reserved.
//

public protocol SchedulerType {
    func invalidateAndReschedule(at seconds: TimeInterval, block: @escaping () -> Void)
}

public class Scheduler: SchedulerType {
    var timerType: TimerType.Type = Timer.self
    var timer: TimerType?
    var timerQueue: DispatchQueue
    private var block: (() -> Void)?

    @objc
    public init(identifier: String) {
        timerQueue = DispatchQueue(label: identifier)
    }

    public func invalidateAndReschedule(at seconds: TimeInterval, block: @escaping () -> Void) {
        timerQueue.sync { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.timer?.invalidate()
            strongSelf.block = block
            strongSelf.timer = strongSelf.timerType.scheduledTimer(timeInterval: seconds,
                                             target: strongSelf,
                                             selector: #selector(strongSelf.runBlock))
        }
    }

    @objc func runBlock() {
        guard let validTimer = timer,
              validTimer.isValid else { return }
        block?()
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }
}

protocol TimerType {
    var fireDate: Date { get }
    var isValid: Bool { get }
    static func scheduledTimer(timeInterval: TimeInterval,
                               target aTarget: Any,
                               selector aSelector: Selector) -> TimerType
    func invalidate()
}

extension Timer: TimerType {
    static func scheduledTimer(timeInterval: TimeInterval,
                               target aTarget: Any,
                               selector aSelector: Selector) -> TimerType {
        return scheduledTimer(timeInterval: timeInterval,
                              target: aTarget,
                              selector: aSelector,
                              userInfo: nil,
                              repeats: false)
    }
}
