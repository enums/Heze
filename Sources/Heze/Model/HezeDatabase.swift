//
//  HezeDatabase.swift
//  Heze
//
//  Created by enum on 2019/8/1.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation

public typealias HezeSQLStatement = String
public typealias HezeSQLAddition = String
public typealias HezeDatabaseRecord = [String]
public typealias HezeDatabaseSimpleFieldValuePair = (HezeModelSimpleField, HezeModelFieldDataProtocol)

public var HezeSQLAdditionNull = ""

public protocol HezeDatabaseImpl {
    
    var database: String { get }
    var threadSafe: Bool { get }

    func connect() -> Bool
    func query(_ sql: HezeSQLStatement) -> [HezeDatabaseRecord]?
    func query(_ sqls: [HezeSQLStatement]) -> [[HezeDatabaseRecord]]?

    func isDatabaseExist() -> Bool
    func createDatabase() -> Bool
    func dropDatabse() -> Bool

    func isTableExist(_ table: String) -> Bool
    func createTable(_ table: String, fields: [HezeModelField]) -> Bool
    func dropTable(_ table: String) -> Bool
    func selectTable(_ table: String, fileds: [HezeModelSimpleField], addition: HezeSQLAddition) -> [HezeDatabaseRecord]?

    func insertRecord(table: String, record: HezeDatabaseRecord) -> HezeModelId?
    func updateRecord(table: String, id: HezeModelId, pairs: [HezeDatabaseSimpleFieldValuePair]) -> Bool
    func updateRecordByPlusOne(table: String, id: HezeModelId, field: HezeModelSimpleField) -> Bool
    func deleteRecord(table: String, id: HezeModelId) -> Bool

}

open class HezeDatabase: HezeObject {

    public var impl: HezeDatabaseImpl

    public init(impl: HezeDatabaseImpl) {
        self.impl = impl
    }

    public required init() {
        HezeLogger.shared.abort("Cannot init db without impl")
    }

    private lazy var lock = NSLock()
    
    private func lockIfNeed() {
        if !impl.threadSafe {
            lock.lock()
        }
    }
    
    private func unlockIfNeed() {
        if !impl.threadSafe {
            lock.unlock()
        }
    }
    
    internal func connect() -> Bool {
        lockIfNeed()
        defer { unlockIfNeed() }
        return impl.connect()
    }

    internal func query(_ sql: HezeSQLStatement) -> [HezeDatabaseRecord]? {
        lockIfNeed()
        defer { unlockIfNeed() }
        return impl.query(sql)
    }

    internal func isDatabaseExist() -> Bool {
        lockIfNeed()
        defer { unlockIfNeed() }
        return impl.isDatabaseExist()
    }

    internal func createDatabase() -> Bool {
        lockIfNeed()
        defer { unlockIfNeed() }
        return impl.createDatabase()
    }

    internal func dropDatabse() -> Bool {
        lockIfNeed()
        defer { unlockIfNeed() }
        return impl.dropDatabse()
    }

    internal func isTableExist(for model: HezeModel) -> Bool {
        lockIfNeed()
        defer { unlockIfNeed() }
        return impl.isTableExist(model.table)
    }

    internal func createTable(for model: HezeModel) -> Bool {
        lockIfNeed()
        defer { unlockIfNeed() }
        return impl.createTable(model.table, fields: model.fields)
    }

    internal func dropTable(for model: HezeModel) -> Bool {
        lockIfNeed()
        defer { unlockIfNeed() }
        return impl.dropTable(model.table)
    }

    internal func selectTable(for model: HezeModel,
                              addition: HezeSQLAddition) -> [HezeDatabaseRecord]? {
        lockIfNeed()
        defer { unlockIfNeed() }
        return impl.selectTable(model.table, fileds: HezeModelSimpleFieldAll, addition: addition)
    }


    @discardableResult
    internal func insertModel(_ model: HezeModel) -> Bool {
        lockIfNeed()
        defer { unlockIfNeed() }
        guard let id = impl.insertRecord(table: model.table, record: model.toRecord()) else {
            return false
        }
        model.id = id
        return true
    }

    @discardableResult
    internal func updateModel(_ model: HezeModel) -> Bool {
        guard let id = model.id else {
            HezeLogger.shared.error("Unknow model with id(nil)!")
            return false
        }
        lockIfNeed()
        defer { unlockIfNeed() }
        return impl.updateRecord(table: model.table, id: id, pairs: model.toFieldValuePair())
    }

    @discardableResult
    internal func updateModelByPlusOne(_ model: HezeModel, _ field: HezeModelField) -> Bool {
        guard let id = model.id else {
            HezeLogger.shared.error("Unknow model with id(nil)!")
            return false
        }
        guard let value = field.value else {
            HezeLogger.shared.error("Field's value is nil!")
            return false
        }
        lockIfNeed()
        defer { unlockIfNeed() }
        return impl.updateRecordByPlusOne(table: model.table, id: id, field: field.name)
    }

    @discardableResult
    internal func deleteModel(_ model: HezeModel) -> Bool {
        guard let id = model.id else {
            HezeLogger.shared.error("Unknow model with id(nil)!")
            return false
        }
        lockIfNeed()
        defer { unlockIfNeed() }
        return impl.deleteRecord(table: model.table, id: id)
    }

}
