//
//  HezeHandler.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/1.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import PerfectHTTP

public typealias HezeMetaHandler = HezeHandler
public typealias HezeHandlerPath = String
public let HezeHandlerPathDefault = ""

public func HezeSimpleHandle(content: HezeResponsable?,
                             status: HTTPResponseStatus = .ok,
                             for req: HTTPRequest, and res: HTTPResponse) {
    content?.setBody(for: res)
    res.status = status
    res.completed()
}

public func HezeRedirect(_ status: HTTPResponseStatus = .found, url: String,
                         for req: HTTPRequest, and res: HTTPResponse) {
    res.status = status
    res.setHeader(.location, value: url)
    res.completed()
}

open class HezeHandler: HezeObject {

    public class var meta: HezeMetaHandler {
        let meta = self.init()
        meta.bindContext(.meta)
        return meta
    }

    public var request: HTTPRequest?

    open func requestVaild() -> Bool {
        return true
    }

    open func handleInvaild(_ req: HTTPRequest, _ res: HTTPResponse) {
        res.setBody(string: "Request Vailed Failed.")
        res.completed()
    }

    open func handle(_ req: HTTPRequest, _ res: HTTPResponse) -> HezeResponsable? {
        return nil
    }

    internal func handleThenComplete(_ req: HTTPRequest, _ res: HTTPResponse) {
        request = req
        defer {
            request = nil
        }
        guard requestVaild() else {
            handleInvaild(req, res)
            return
        }
        if let response = handle(req, res) {
            response.setBody(for: res)
            res.completed()
        }
    }

}
