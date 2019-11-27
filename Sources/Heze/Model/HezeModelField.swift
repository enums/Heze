//
//  HezeModelField.swift
//  Heze
//
//  Created by enum on 2019/8/1.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation

public protocol HezeModelFieldDataProtocol {
    var toStr: String { get }
    static func fromString(_ str: String) -> Self?
    static func checkValue(_ value: HezeModelFieldDataProtocol) -> Bool
}

public typealias HezeModelSimpleField = String
public var HezeModelSimpleFieldAll = ["*"]
public var HezeModelSimpleFieldId = "HEZE_ID"

open class HezeModelField: HezeObject {

    public enum DataType: String {
        case string = "VARCHAR"
        case int = "INT"
        case text = "LONGTEXT"

        func toSQL(len: Int) -> String {
            switch self {
            case .string, .int: return "\(rawValue)(\(len))"
            case .text: return rawValue
            }
        }
    }

    public var name: String
    public var type: DataType
    public var value: HezeModelFieldDataProtocol? = nil {
        willSet {
            guard checkValue(newValue) else {
                HezeLogger.shared.abort("\(newValue ?? "nil") is not a \(type)")
            }
        }
        didSet {
            syncValue()
        }
    }
    public var length: Int
    public var defaultValue: HezeModelFieldDataProtocol?
    public var nullable: Bool

    internal weak var model: HezeModel?

    public init(name: String,
                type: DataType,
                length: Int = 11,
                value: HezeModelFieldDataProtocol? = nil,
                defaultValue: HezeModelFieldDataProtocol? = nil,
                nullable: Bool = true) {
        self.name = name
        self.type = type
        self.length = length
        self.defaultValue = defaultValue
        self.nullable = nullable

        super.init()
        
        if value == nil, !nullable {
            self.value = defaultValue
        } else {
            self.value = value
        }
    }

    public required init() {
        HezeLogger.shared.abort("Connot init field without type.")
    }

    internal func bindModel(_ model: HezeModel) {
        self.model = model
        syncValue()
    }

    internal func unbindModel() {
        self.model = nil
    }

    internal func checkValue(_ value: HezeModelFieldDataProtocol?) -> Bool {
        if let value = value {
            switch type {
            case .string, .text: return String.checkValue(value)
            case .int: return Int.checkValue(value)
            }
        } else {
            return true
        }
    }

    internal func setValue(from record: String) -> Bool {
        switch type {
        case .string, .text:
            value = record
            return true
        case .int:
            guard let intValue = Int.fromString(record) else {
                return false
            }
            value = intValue
            return true
        }
    }

    internal func syncValue() {
        guard let model = model, let value = value else {
            return
        }
        model.values[name] = value
    }

    internal func toSql() -> HezeSQLStatement {
        let typeStr = type.toSQL(len: length)
        let nullStr: String
        if !nullable, let value = defaultValue {
            nullStr = "NOT NULL DEFAULT '\(value)'"
        } else {
            nullStr = "NULL"
        }
        return "`\(name)` \(typeStr) \(nullStr)"
    }

    internal func toRecord() -> String {
        guard let value = value else {
            return ""
        }
        return value.toStr
    }
}

extension String: HezeModelFieldDataProtocol {

    public var toStr: String {
        return self
    }

    public static func fromString(_ str: String) -> String? {
        return str
    }

    public static func checkValue(_ value: HezeModelFieldDataProtocol) -> Bool {
        return value is String
    }
}

extension HezeModelField {
    public var strValue: String {
        guard let value = value else {
            HezeLogger.shared.abort("Value is nil.")
        }
        guard let str = value as? String else {
            HezeLogger.shared.abort("`\(value)` is not a String.")
        }
        return str
    }
}

extension Int: HezeModelFieldDataProtocol {

    public var toStr: String {
        return "\(self)"
    }

    public static func fromString(_ str: String) -> Int? {
        return Int(str)
    }

    public static func checkValue(_ value: HezeModelFieldDataProtocol) -> Bool {
        return value is Int || {
            if let str = value as? String {
                return Int(str) != nil
            }
            return false
        }()
    }
}

extension HezeModelField {
    public var intValue: Int {
        guard let value = value else {
            HezeLogger.shared.abort("Value is nil.")
        }
        guard let int = value as? Int else {
            HezeLogger.shared.abort("`\(value)` is not a Int.")
        }
        return int
    }
}
