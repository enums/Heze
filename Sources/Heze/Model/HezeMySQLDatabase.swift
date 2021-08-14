//
//  HezeMySQLDatabase.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/1.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import PerfectMySQL

public struct HezeMySQLConfig: Codable {
    public var ip: String
    public var port: Int
    public var username: String
    public var password: String
    public var database: String
}

open class HezeMySQLDatabase: HezeObject, HezeDatabaseImpl {

    public let config: HezeMySQLConfig
    private let mysql: MySQL

    public var database: String {
        return config.database
    }
    
    public var threadSafe: Bool {
        return false
    }

    public init(config: HezeMySQLConfig) {
        self.config = config
        self.mysql = MySQL()
    }

    public required init() {
        HezeLogger.shared.abort("Cannot init db impl without config.")
    }

    public func connect() -> Bool {
        guard mysql.setOption(.MYSQL_OPT_RECONNECT, true) else {
            HezeLogger.shared.error("Cannot set MYSQL_OPT_RECONNECT!")
            return false
        }
        guard mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8mb4") else {
            HezeLogger.shared.error("Cannot set MYSQL_SET_CHARSET_NAME!")
            return false
        }
        guard mysql.connect(host: config.ip, user: config.username, password: config.password, port: UInt32(config.port)) else {
            HezeLogger.shared.error("Cannot connect database!")
            return false
        }
        guard mysql.setServerOption(.MYSQL_OPTION_MULTI_STATEMENTS_ON) else {
            HezeLogger.shared.error("Cannot set MYSQL_OPTION_MULTI_STATEMENTS_ON!")
            return false
        }
        return true
    }

    public func ping() -> Bool {
        return mysql.ping()
    }

    public func query(_ sql: HezeSQLStatement) -> [HezeDatabaseRecord]? {
        guard queryWithRetryIfFailed(sql) else {
            HezeLogger.shared.debug("[SQL][Failed] \(sql)")
            HezeLogger.shared.debug("[SQL][Message] \(mysql.errorMessage())")
            return nil
        }
        HezeLogger.shared.debug("[SQL][Success] \(sql)")
        guard let results = mysql.storeResults() else {
            return []
        }
        var result = [HezeDatabaseRecord]()
        while let row = results.next() {
            result.append(row.compactMap { $0 })
        }
        return result
    }

    public func query(_ sqls: [HezeSQLStatement]) -> [[HezeDatabaseRecord]]? {
        let sql = sqls.joined(separator: " ")
        guard queryWithRetryIfFailed(sql) else {
            HezeLogger.shared.debug("[SQL][Failed] \(sql)")
            HezeLogger.shared.debug("[SQL][Message] \(mysql.errorMessage())")
            return nil
        }
        HezeLogger.shared.debug("[SQL][Success] \(sql)")
        var results = [[HezeDatabaseRecord]]()
        var next = 0
        while next == 0 {
            if let tmp = mysql.storeResults() {
                var result = [HezeDatabaseRecord]()
                while let row = tmp.next() {
                    result.append(row.map { $0 ?? "" })
                }
                results.append(result)
            } else {
                results.append([])
            }
            next = mysql.nextResult()
        }
        return results
    }

    public func isDatabaseExist() -> Bool {
        let sql = HezeSQL.isDatabaseExist(database)
        guard let result = query(sql) else {
            return false
        }
        return result.count >= 1
    }

    public func createDatabase() -> Bool {
        let sql = HezeSQL.createDatabase(database)
        return query(sql) != nil
    }

    public func dropDatabse() -> Bool {
        let sql = HezeSQL.dropDatabase(database)
        return query(sql) != nil
    }

    public func isTableExist(_ table: String) -> Bool {
        let sql = HezeSQL.isTableExist(database, table)
        guard let result = query(sql) else {
            return false
        }
        return result.count >= 1
    }

    public func createTable(_ table: String, fields: [HezeModelField]) -> Bool {
        let sql = HezeSQL.createTable(database, table, fields)
        return query(sql) != nil
    }

    public func dropTable(_ table: String) -> Bool {
        let sql = HezeSQL.dropTable(database, table)
        return query(sql) != nil
    }

    public func selectTable(_ table: String,
                            fileds: [HezeModelSimpleField] = HezeModelSimpleFieldAll,
                            addition: HezeSQLAddition = HezeSQLAdditionNull) -> [HezeDatabaseRecord]? {
        let sql = HezeSQL.selectTable(database, table, fileds, addition: addition)
        return query(sql)
    }

    public func insertRecord(table: String,
                             record: HezeDatabaseRecord) -> HezeModelId? {
        let sql = HezeSQL.insertRecord(database, table, record)
        let idSql = HezeSQL.lastInsertId()
        guard let results = query([sql, idSql]) else {
            return nil
        }
        guard results.count == 2,
            results[0].count == 0,
            results[1].count == 1, results[1][0].count == 1 ,let id = HezeModelId(results[1][0][0]) else {
            return nil
        }
        return id
    }

    public func updateRecord(table: String,
                             id: HezeModelId,
                             pairs: [HezeDatabaseSimpleFieldValuePair]) -> Bool {
        let sql = HezeSQL.updateRecord(database, table, id: id, pairs: pairs)
        return query(sql) != nil
    }

    public func updateRecordByPlusOne(table: String, id: HezeModelId, field: HezeModelSimpleField) -> Bool {
        let sql = HezeSQL.updateRecordByPlusOne(database, table, id: id, field: field)
        return query(sql) != nil
    }

    public func deleteRecord(table: String,
                             id: HezeModelId) -> Bool {
        let sql = HezeSQL.deleteRecord(database, table, id: id)
        return query(sql) != nil
    }

    private func queryWithRetryIfFailed(_ statement: String) -> Bool {
        if mysql.query(statement: statement) {
            return true
        }

        return mysql.query(statement: statement)
    }
    
}
