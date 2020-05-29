//
//  HezeTimer.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/1.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation

open class HezeTimer: HezePlugin {

    open var interval: TimeInterval {
        return 1
    }

    open var delay: TimeInterval {
        return 0
    }

    open var repeatTimes: Int {
        return 0
    }

    internal override func boot() {
        taskQueue.async {
            Thread.sleep(forTimeInterval: self.delay)
            if self.repeatTimes <= 0 {
                while true {
                    HezeLogger.shared.info("Plugin [\(self.className)] triggered.")
                    self.task?()
                    Thread.sleep(forTimeInterval: self.interval)
                }
            } else {
                var time = 0
                while true {
                    HezeLogger.shared.info("Plugin [\(self.className)] triggered.")
                    self.task?()
                    time += 1
                    if time >= self.repeatTimes {
                        break
                    }
                    Thread.sleep(forTimeInterval: self.interval)
                }
            }
        }
    }

}
