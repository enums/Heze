//
//  HezeModel.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/1.
//

import Foundation
import Virgo

public typealias HezeModelId = Int64
public typealias HezeMetaModel = HezeModel
public let HezeMetaModelDefaultCacheTime: TimeInterval = 60

open class HezeModel: HezeObject {

    public class var meta: HezeMetaModel {
        let meta = self.init()
        meta.bindContext(.meta)
        meta.bindSelf()
        return meta
    }

    open var table: String {
        if className.hasSuffix("Model") {
            return String(className.dropLast(5))
        } else {
            return className
        }
    }

    open var cacheTime: TimeInterval {
        return HezeMetaModelDefaultCacheTime
    }

    public internal(set) var id: HezeModelId?

    internal var fields = [HezeModelField]()
    internal var values = [HezeModelSimpleField: HezeModelFieldDataProtocol]()

    internal var simpleFields: [HezeModelSimpleField] {
        return fields.map { $0.name }
    }

    internal func toRecord() -> HezeDatabaseRecord {
        return fields.map { $0.toRecord() }
    }

    internal func toFieldValuePair() -> [HezeDatabaseSimpleFieldValuePair] {
        return fields.map { ($0.name, $0.value?.toStr ?? "") }
    }

    open func registerFields() -> [HezeModelField] {
        return []
    }

    open var customFields: [HezeModelSimpleField: Any] {
        return [:]
    }

    open func archive() -> [HezeModelSimpleField: Any] {
        var content: [HezeModelSimpleField: Any] = values
        customFields.forEach { (key, value) in
            content[key] = value
        }
        return content
    }

    open func render() -> JSON {
        return JSON(archive())
    }

    internal func bindSelf() {
        fields.forEach {
            $0.unbindContext()
            $0.unbindModel()
        }
        fields = registerFields().map {
            $0.bindContext(context)
            $0.bindModel(self)
            return $0
        }
    }

    internal func bindRecord(_ record: HezeDatabaseRecord) -> Bool {
        guard record.count == fields.count + 1 else {
            return false
        }

        let count = fields.count
        guard let id = HezeModelId(record[0]) else {
            return false
        }
        self.id = id

        if count == 0 {
            return true
        }

        for i in 0..<count {
            guard fields[i].checkValue(record[i + 1]) else {
                return false
            }
        }

        for i in 0..<count {
            guard fields[i].setValue(from: record[i + 1]) else {
                return false
            }
        }

        return true
    }
}

public extension Array where Element: HezeModel {

    func archive() -> [HezeViewParam] {
        return map { $0.archive() }
    }

    func render() -> JSON? {
        let modelJson = JSON(self.map { $0.render() })
        guard modelJson.type == .array else {
            return nil
        }
        return modelJson
    }
}
