//
//  HezeRequestLogger.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/1.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import PerfectHTTP

open class HezeRequestLogger: HezeRequestFilter {

    open override func requestFilter(req: HTTPRequest, res: HTTPResponse) -> Bool {
        let url = (req.header(.host) ?? "nil") + req.uri
        let method = req.method
        let host = req.header(.custom(name: "watchdog-ip")) ?? req.remoteAddress.host
        let port = UInt16(req.header(.custom(name: "watchdog-port")) ?? "") ?? req.remoteAddress.port
        HezeLogger.shared.info("Req:      [\(method)][\(host)][\(port)]: \(url)")
        return true
    }


}

