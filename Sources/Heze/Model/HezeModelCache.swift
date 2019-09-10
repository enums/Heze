//
//  HezeModelCache.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/14.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation

public struct HezeModelCache {

    public var time: TimeInterval
    public var records: [HezeModel]

    public init(records: [HezeModel]) {
        self.time = Date().timeIntervalSince1970
        self.records = records
    }

}

public class HezeModelCacheCenter: HezeObject {

    public var caches = [String: HezeModelCache]()

    private var locker = NSLock()

    public func cacheForModel<T>(_ meta: HezeMetaModel) -> [T]? where T: HezeModel {
        locker.lock()
        defer { locker.unlock() }
        let cls = meta.className
        guard let cache = caches[cls] else {
            return nil
        }
        let now = Date().timeIntervalSince1970
        guard cache.time + meta.cacheTime > now else {
            caches[cls] = nil
            return nil
        }

        return cache.records as? [T]
    }

    public func cache<T>(_ records: [T]) where T: HezeModel {
        locker.lock()
        defer { locker.unlock() }
        let cls = T.className
        let cache = HezeModelCache(records: records)
        caches[cls] = cache
    }

    public func remove(_ meta: HezeMetaModel) {
        locker.lock()
        defer { locker.unlock() }
        let cls = meta.className
        caches[cls] = nil
    }

}
