//
//  HezeResponseLogger.swift
//  Heze
//
//  Created by enum on 2019/8/5.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import PerfectHTTP

open class HezeResponseLogger: HezeResponseFilter {

    open override func responseFilterHeader(req: HTTPRequest, res: HTTPResponse) -> Bool {
        let code = res.status.code
        let url = (req.header(.host) ?? "nil") + req.uri
        let method = req.method
        let host = req.header(.custom(name: "watchdog-ip")) ?? req.remoteAddress.host
        let port = UInt16(req.header(.custom(name: "watchdog-port")) ?? "") ?? req.remoteAddress.port
        HezeLogger.shared.info("Res: [\(code)][\(method)][\(host)][\(port)]: \(url)")
        return true
    }


}
