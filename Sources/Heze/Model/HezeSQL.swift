//
//  HezeSQL.swift
//  Heze
//
//  Created by enum on 2019/8/1.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation

public class HezeSQL {

    public static func isDatabaseExist(_ database: String) -> HezeSQLStatement {
        return "SELECT 1 FROM information_schema.SCHEMATA where SCHEMA_NAME='\(database)';"
    }

    public static func createDatabase(_ database: String) -> HezeSQLStatement {
        return "CREATE SCHEMA `\(database)` DEFAULT CHARACTER SET utf8mb4;"
    }

    public static func dropDatabase(_ database: String) -> HezeSQLStatement {
        return "DROP DATABASE `\(database)`;"
    }

    public static func selectDatabase(_ database: String) -> HezeSQLStatement {
        return "SELECT * FROM information_schema.SCHEMATA where SCHEMA_NAME='\(database)';"
    }

    public static func isTableExist(_ database: String? = nil,
                                    _ table: String) -> HezeSQLStatement {
        return "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA='\(database ?? "*")' and TABLE_NAME='\(table)';"
    }

    public static func createTable(_ database: String? = nil,
                                   _ table: String,
                                   _ fields: [HezeModelField]) -> HezeSQLStatement {
        let fieldsStr = fields.reduce("") {
            $0 + ", " + $1.toSql()
        }
        return "CREATE TABLE \(fullTableName(database, table)) (`\(HezeModelSimpleFieldId)` INT AUTO_INCREMENT \(fieldsStr), PRIMARY KEY (`\(HezeModelSimpleFieldId)`));"
    }

    public static func dropTable(_ database: String? = nil,
                                 _ table: String) -> HezeSQLStatement {
        return "DROP TABLE \(fullTableName(database, table));"
    }

    public static func selectTable(_ database: String? = nil,
                                   _ table: String,
                                   _ fields: [HezeModelSimpleField] = HezeModelSimpleFieldAll,
                                   addition: HezeSQLAddition = HezeSQLAdditionNull) -> HezeSQLStatement {
        let fieldStr = fields == HezeModelSimpleFieldAll ? "*" : fields.map { "`\($0)`" }.joined(separator: ",")
        return "SELECT \(fieldStr) FROM \(fullTableName(database, table)) \(addition);"
    }

    public static func insertRecord(_ database: String? = nil,
                                    _ table: String,
                                    _ record: HezeDatabaseRecord) -> HezeSQLStatement {
        let recordStr = record.reduce("'0'") {
            "\($0), '\(($1.replacingOccurrences(of: "'", with: "\\'")))'"
        }
        return "INSERT INTO \(fullTableName(database, table)) VALUES (\(recordStr));"
    }

    public static func updateRecord(_ database: String? = nil,
                                    _ table: String,
                                    id: HezeModelId,
                                    pairs: [HezeDatabaseSimpleFieldValuePair]) -> HezeSQLStatement {
        let pairsStr = pairs.map { "`\($0)`='\($1.toStr.replacingOccurrences(of: "'", with: "\\'"))'" }.joined(separator: ",")
        return "UPDATE \(fullTableName(database, table)) SET \(pairsStr) WHERE `\(HezeModelSimpleFieldId)`='\(id)';"
    }

    public static func updateRecordByPlusOne(_ database: String? = nil,
                                             _ table: String,
                                             id: HezeModelId,
                                             field: HezeModelSimpleField) -> HezeSQLStatement {
        return "UPDATE \(fullTableName(database, table)) SET `\(field)`=`\(field)`+1 WHERE `\(HezeModelSimpleFieldId)`='\(id)';"
    }

    public static func deleteRecord(_ database: String? = nil,
                                    _ table: String,
                                    id: HezeModelId) -> HezeSQLStatement {
        return "DELETE FROM \(fullTableName(database, table)) WHERE `\(HezeModelSimpleFieldId)`='\(id)';"
    }

    public static func lastInsertId() -> HezeSQLStatement {
        return "SELECT last_insert_id();"
    }


    internal static func fullTableName(_ database: String? = nil, _ table: String) -> String {
        if let database = database {
            return "`\(database)`.`\(table)`"
        } else {
            return "`\(table)`"
        }
    }
}
