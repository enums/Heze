//
//  HezeView.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/1.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import PerfectMustache
import PerfectHTTP

public typealias HezeViewParam = Dictionary<String, Any>

open class HezeView: HezeHandler {

    public override class var meta: HezeView {
        let meta = self.init()
        meta.bindContext(.meta)
        return meta
    }

    open var view: String? {
        return nil
    }

    open var param: HezeViewParam {
        return HezeViewParam()
    }

    open override func handle(_ req: HTTPRequest, _ res: HTTPResponse) -> HezeResponsable? {
        guard let content = self.render() else {
            return "Oops! Something wrong on rendering view."
        }
        return content
    }

    public func render() -> String? {
        guard let viewFile = view else {
            return nil
        }
        let paths: HezePath = context.path
        let viewPath = "\(paths.viewPath)/\(viewFile)"
        return try? MustacheEvaluationContext(templatePath: viewPath, map: param)
            .formulateResponse(withCollector: MustacheEvaluationOutputCollector())
    }
    
}
