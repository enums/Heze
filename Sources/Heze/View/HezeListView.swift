//
//  HezeListView.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/9/10.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import PerfectMustache
import PerfectHTTP

public typealias HezeModelSet = [String: [HezeModel]]

open class HezeListView: HezeView {

    open var modelSet: HezeModelSet {
        return HezeModelSet()
    }

    open func customFields(in set: String, for model: HezeModel) -> HezeViewParam? {
        return nil
    }

    public override func render() -> String? {
        guard let viewFile = view else {
            return nil
        }
        let paths: HezePath = context.path
        let viewPath = "\(paths.viewPath)/\(viewFile)"
        var param = self.param

        modelSet.forEach { (arg) in
            let (name, set) = arg
            param[name] = set.map { model -> [HezeModelSimpleField: Any] in
                var content = model.archive()
                if let custom = customFields(in: name, for: model) {
                    custom.forEach {
                        content[$0.key] = $0.value
                    }
                }
                return content
            }
        }

        return try? MustacheEvaluationContext(templatePath: viewPath, map: param)
            .formulateResponse(withCollector: MustacheEvaluationOutputCollector())
    }
}
