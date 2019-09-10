//
//  HezeObject.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/5.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation

open class HezeObject {

    private weak var _context: HezeContext? = nil

    public var context: HezeContext {
        guard let c = _context else {
            HezeLogger.shared.abort("Context is nil.")
        }
        return c
    }

    public var className: String {
        return String(describing: Mirror(reflecting: self).subjectType)
    }

    public static var className: String {
        return String(describing: Mirror(reflecting: self).subjectType).components(separatedBy: ".")[0]
    }

    public required init() {

    }

    open func bindContext(_ context: HezeContext?) {
        _context = context
    }

    open func unbindContext() {
        _context = nil
    }

}
