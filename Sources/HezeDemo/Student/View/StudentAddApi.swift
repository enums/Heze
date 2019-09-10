//
//  StudentAddApi.swift
//  HezeDemo
//
//  Created by Yuu Zheng on 2019/9/10.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import PerfectHTTP
import Virgo
import Heze

class StudentAddApi: HezeHandler {

    override func handle(_ req: HTTPRequest, _ res: HTTPResponse) -> HezeResponsable? {

        guard let name = req.param(name: "name"),
            let age = Int(req.param(name: "age") ?? "") else {
                return HezeResponse(false)
        }

        let s = StudentModel.create()
        s.name.value = name
        s.age.value = age

        guard s.insert() else {
            return HezeResponse(false)
        }

        return HezeResponse(true)
    }
}
