//
//  HezeResponsable.swift
//  Heze
//
//  Created by enum on 2019/8/2.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import Virgo
import PerfectHTTP

public protocol HezeResponsable {
    func setBody(for res: HTTPResponse)
}

public func HezeResponse(_ success: Bool, _ msg: String? = nil, data: JSON? = nil) -> JSON {
    let json: [String: Any] = [
        "success": success,
        "msg": msg ?? "nil",
        "data": data ?? NSNull()
    ]
    return JSON(json)
}

extension String: HezeResponsable {

    public func setBody(for res: HTTPResponse) {
        res.setBody(string: self)
        res.setHeader(.contentLength, value: "\(self.lengthOfBytes(using: .utf8))")
    }

}

extension Array: HezeResponsable where Element == UInt8 {

    public func setBody(for res: HTTPResponse) {
        res.setBody(bytes: self)
        res.setHeader(.contentLength, value: "\(self.count)")
    }

}

extension JSON: HezeResponsable {

    public func setBody(for res: HTTPResponse) {
        self.rawString(.utf8, options: .init(rawValue: 0))?.setBody(for: res)
    }
}
