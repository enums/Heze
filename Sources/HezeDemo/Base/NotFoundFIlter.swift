//
//  NotFoundFIlter.swift
//  HezeDemo
//
//  Created by Yuu Zheng on 2019/9/10.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import Heze
import PerfectHTTP

class NotFoundFilter: HezeResponseFilter {

    override func responseFilterHeader(req: HTTPRequest, res: HTTPResponse) -> Bool {
        if case .notFound = res.status {
            HezeSimpleHandle(content: "custom 404 page", for: req, and: res)
            return false
        } else {
            return true
        }

    }

}
