//
//  HezeContext.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/5.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation

public class HezeContextBox: HezeKeyPathContent<HezeContext> {

    public static let shared = HezeContextBox() { content, member in
        let context = HezeContext() { _,_ in
            HezeLogger.shared.abort("Cannot find keypath `\(member)`.")
        }
        context.name = member
        content._data[member] = context
        return context
    }

}

public class HezeContext: HezeKeyPathContent<Any> {

    public var name: String?

    public subscript<T>(dynamicMember member: String) -> T {
        get {
            guard let obj = _data[member] else {
                HezeLogger.shared.abort("Cannot find keypath `\(member)`.")
            }
            guard let result = obj as? T else {
                HezeLogger.shared.abort("`\(obj)` is not a `\(T.self)`.")
            }
            return result
        }
        set(newValue) {
            _data[member] = newValue
        }
    }
}

public extension HezeContext {

    class var main: HezeContext {
        return HezeContextBox.shared.main
    }

    class var meta: HezeContext {
        return HezeContextBox.shared.meta
    }

}

