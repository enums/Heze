//
//  VirgoKeyPathContent.swift
//  Virgo
//
//  Created by enum on 2019/8/3.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation

@dynamicMemberLookup
open class VirgoKeyPathContent<T> {

    public typealias ErrorHandler = (VirgoKeyPathContent<T>, String) -> T

    public var _data = [String: T]()
    public var _errorHandler: ErrorHandler

    public init(errorHandler: @escaping ErrorHandler) {
        self._errorHandler = errorHandler
    }

    public subscript(dynamicMember member: String) -> T {
        get {
            if let value = _data[member] {
                return value
            } else {
                return _errorHandler(self, member)
            }
        }
        set(newValue) {
            _data[member] = newValue
        }
    }
}

@dynamicMemberLookup
open class VirgoKeyPathOptionalContent<T> {

    public typealias ErrorHandler = (VirgoKeyPathOptionalContent<T>, String) -> T?

    public var _data = [String: T]()
    public var _errorHandler: ErrorHandler?

    public init(errorHandler: ErrorHandler? = nil) {
        self._errorHandler = errorHandler
    }

    public subscript(dynamicMember member: String) -> T? {
        get {
            if let value = _data[member] {
                return value
            } else {
                return _errorHandler?(self, member)
            }
        }
        set(newValue) {
            _data[member] = newValue
        }
    }
}
