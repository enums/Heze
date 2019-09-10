//
//  HezeRequestFilter.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/1.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import PerfectHTTP

open class HezeRequestFilter: HezePlugin, HTTPRequestFilter {

    open var priority: HTTPFilterPriority {
        return .low
    }

    open func requestFilter(req: HTTPRequest, res: HTTPResponse) -> Bool { return true }

    public func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
        if requestFilter(req: request, res: response) {
            callback(.continue(request, response))
        } else {
            callback(.halt(request, response))
        }
    }
}

