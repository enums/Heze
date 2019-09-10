//
//  HezeResponseFilter.swift
//  Heze
//
//  Created by enum on 2019/8/5.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import PerfectHTTP

open class HezeResponseFilter: HezePlugin, HTTPResponseFilter {

    open var priority: HTTPFilterPriority {
        return .low
    }

    open func responseFilterHeader(req: HTTPRequest, res: HTTPResponse) -> Bool { return true }

    open func responseFilterBody(req: HTTPRequest, res: HTTPResponse) -> Bool { return true }

    public func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        if responseFilterHeader(req: response.request, res: response) {
            callback(.continue)
        } else {
            callback(.done)
        }
    }

    public func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        if responseFilterBody(req: response.request, res: response) {
            callback(.continue)
        } else {
            callback(.done)
        }
    }
}
