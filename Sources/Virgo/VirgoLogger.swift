//
//  VirgoLogger.swift
//  SPiCa
//
//  Created by enum on 2019/8/3.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import Rainbow

open class VirgoLogger {

    public static var shared = VirgoLogger()

    open var enabled = true
    open var debugOutput = false

    private init() { }

    open func debug(_ msg: String) {
        guard debugOutput else {
            return
        }
        log("[DEBUG]".lightBlack, msg.lightBlack)
    }

    open func info(_ msg: String) {
        log("[INFO]".cyan, msg.cyan)
    }

    open func success(_ msg: String) {
        log("[SUCCESS]".green, msg.green)
    }

    open func error(_ msg: String) {
        log("[ERROR]".red, msg.red)
    }

    open func abort(_ msg: String) -> Never {
        log("[ABORT]".onRed, msg.white.onRed)
        fatalError("Abort!")
    }

    open func log(_ tag: String, _ msg: String) {
        guard enabled else {
            return
        }
        let date = "[\(Date().stringValue)]".blue
        print("\(date)\(tag) \(msg)")
    }

}
