//
//  HezeModelOperation.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/2.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation

public func HezeModelCreate<T>(_ model: T.Type, context: HezeContext = .main) -> T where T: HezeModel {
    let model = T.init()
    model.bindContext(context)
    model.bindSelf()
    return model
}

public func HezeModelQuery<T>(_ type: T.Type,
                              context: HezeContext = .main,
                              addition: HezeSQLAddition = HezeSQLAdditionNull) -> [T]? where T: HezeModel {
    let cacheEnable = (addition == HezeSQLAdditionNull)
    let modelCache: HezeModelCacheCenter = context.modelCache
    let meta = type.meta
    if cacheEnable, let cache: [T] = modelCache.cacheForModel(meta) {
        return cache
    }
    guard let db: HezeDatabase = context.database else {
        HezeLogger.shared.error("Cannot find database in context \(context.name ?? "nil")")
        return nil
    }
    guard let records = db.selectTable(for: T.meta, addition: addition) else {
        HezeLogger.shared.error("Select failed in table `\(meta.table)`, addition: `\(addition)`")
        return nil
    }
    guard records.count > 0 else {
        if cacheEnable {
            modelCache.cache([T]())
        }
        return []
    }

    guard meta.bindRecord(records[0]) else {
        HezeLogger.shared.error("Table `\(meta.table)` cannot match model `\(T.className)`. Please check the table fields.")
        return nil
    }
    let result: [T] = records.compactMap { record in
        let model = T.init()
        model.bindContext(context)
        model.bindSelf()
        guard model.bindRecord(record) else {
            HezeLogger.shared.abort("Table `\(meta.table)` cannot match model `\(T.className)`. Something wrong in \(#file):\(#line).")
        }
        return model
    }
    if cacheEnable {
        modelCache.cache(result)
    }
    return result
}

@discardableResult
public func HezeModelInsert<T>(_ model: T) -> Bool where T: HezeModel {
    let context = model.context
    guard let db: HezeDatabase = context.database else {
        HezeLogger.shared.error("Cannot find database in context \(context.name ?? "nil")")
        return false
    }
    let success = db.insertModel(model)
    if success {
        let modelCache: HezeModelCacheCenter = context.modelCache
        modelCache.remove(T.meta)
    }
    return success
}

@discardableResult
public func HezeModelUpdate<T>(_ model: T) -> Bool where T: HezeModel {
    let context = model.context
    guard let db: HezeDatabase = context.database else {
        HezeLogger.shared.error("Cannot find database in context \(context.name ?? "nil")")
        return false
    }
    let success = db.updateModel(model)
    if success {
        let modelCache: HezeModelCacheCenter = context.modelCache
        modelCache.remove(T.meta)
    }
    return success
}

@discardableResult
public func HezeModelUpdateByPlusOne<T>(_ model: T, _ field: HezeModelField) -> Bool where T: HezeModel {
    let context = model.context
    guard let db: HezeDatabase = context.database else {
        HezeLogger.shared.error("Cannot find database in context \(context.name ?? "nil")")
        return false
    }
    let success = db.updateModelByPlusOne(model, field)
    if success {
        let modelCache: HezeModelCacheCenter = context.modelCache
        modelCache.remove(T.meta)
    }
    return success
}

@discardableResult
public func HezeModelDelete<T>(_ model: T) -> Bool where T: HezeModel {
    let context = model.context
    guard let db: HezeDatabase = context.database else {
        HezeLogger.shared.error("Cannot find database in context \(context.name ?? "nil")")
        return false
    }
    let success = db.deleteModel(model)
    if success {
        model.id = nil
        let modelCache: HezeModelCacheCenter = context.modelCache
        modelCache.remove(T.meta)
    }
    return success
}

public protocol HezeModelQueryableProtocol { }
extension HezeModel: HezeModelQueryableProtocol { }
public extension HezeModelQueryableProtocol where Self: HezeModel {

    static func query(_ context: HezeContext = .main, addition: HezeSQLAddition = HezeSQLAdditionNull) -> [Self]? {
        return HezeModelQuery(self, context: context, addition: addition)
    }

    static func create(_ context: HezeContext = .main) -> Self {
        return HezeModelCreate(self, context: context)
    }

    @discardableResult
    func insert() -> Bool {
        return HezeModelInsert(self)
    }

    @discardableResult
    func update() -> Bool {
        return HezeModelUpdate(self)
    }

    @discardableResult
    func updateByPlusOne(_ field: HezeModelField) -> Bool {
        return HezeModelUpdateByPlusOne(self, field)
    }

    @discardableResult
    func delete() -> Bool {
        return HezeModelDelete(self)
    }
}
