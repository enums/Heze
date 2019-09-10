//
//  HezeMarkdownRenderer.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/12.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import PerfectMarkdown

open class HezeMarkdownRenderer {

    open class func origin(file: String) -> String? {
        return try? String(contentsOfFile: file)
    }

    open class func render(file: String) -> String? {
        guard let content = origin(file: file) else {
            return nil
        }
        return render(content:content)
    }

    open class func render(content: String) -> String? {
        return content.markdownToHTML
    }
}
