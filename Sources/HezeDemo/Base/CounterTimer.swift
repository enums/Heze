//
//  CounterTimer.swift
//  HezeDemo
//
//  Created by Yuu Zheng on 2019/9/10.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import Heze

var sec = 0

class CounterTimer: HezeTimer {

    override var interval: TimeInterval {
        return 1
    }

    override var delay: TimeInterval {
        return 1
    }

    override var task: HezePluginTask? {
        return {
            sec += 1
        }
    }
}
