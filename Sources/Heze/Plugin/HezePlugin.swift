//
//  HezePlugin.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/1.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation

public typealias HezePluginTask = () -> Void

public typealias HezeMetaPlugin = HezePlugin

open class HezePlugin: HezeObject {

    public class var meta: HezeMetaPlugin {
        let meta = self.init()
        meta.bindContext(.meta)
        return meta
    }

    internal var taskQueue = DispatchQueue(label: className)

    open var task: HezePluginTask? {
        return nil
    }

    internal func boot() {
        guard let task = task else {
            return
        }
        HezeLogger.shared.info("Plugin [\(className)] boot.")
        taskQueue.async {
            task()
            HezeLogger.shared.info("Plugin [\(self.className)] done.")
        }
    }
}
