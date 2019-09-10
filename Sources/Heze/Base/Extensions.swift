//
//  Extensions.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/1.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import Virgo
import PerfectHTTP

public extension HTTPRequest {

    func urlParam(_ key: String) -> String? {
        return self.param(name: key)
    }

    func postParams() -> JSON? {
        guard let str = self.postBodyString else {
            return nil
        }
        return JSON(parseJSON: str)
    }

    func postParam(_ key: String) -> String? {
        return postParams()?[key].string
    }

}
