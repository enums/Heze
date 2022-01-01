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
    func toBytes() -> [UInt8]?
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

    public func toBytes() -> [UInt8]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        return [UInt8](data)
    }

}

extension Array: HezeResponsable where Element == UInt8 {

    public func setBody(for res: HTTPResponse) {
        res.setBody(bytes: self)
        res.setHeader(.contentLength, value: "\(self.count)")
    }

    public func toBytes() -> [UInt8]? {
        return self
    }

}

extension JSON: HezeResponsable {

    public func setBody(for res: HTTPResponse) {
        self.rawString(.utf8, options: .init(rawValue: 0))?.setBody(for: res)
    }

    public func toBytes() -> [UInt8]? {
        guard let data = try? self.rawData() else {
            return nil
        }
        return [UInt8](data)
    }
}
