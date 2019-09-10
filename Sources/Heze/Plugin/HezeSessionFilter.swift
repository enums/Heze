//
//  HezeSessionRequestFilter.swift
//  Heze
//
//  Created by enum on 2019/8/24.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import PerfectHTTP
import PerfectSessionMySQL

open class HezeSessionRequestFilter: HezeRequestFilter {

    public var session: SessionMySQLDriver {
        return context.session
    }

    open override var priority: HTTPFilterPriority {
        return session.requestFilter.1
    }

    public override func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
        return session.requestFilter.0.filter(request: request, response: response, callback: callback)
    }

}

open class HezeSessionResponseFilter: HezeResponseFilter {

    public var session: SessionMySQLDriver {
        return context.session
    }

    open override var priority: HTTPFilterPriority {
        return session.responseFilter.1
    }

    public override func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        return session.responseFilter.0.filterHeaders(response: response, callback: callback)
    }

    public override func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        return session.responseFilter.0.filterBody(response: response, callback: callback)
    }

}
