//
//  StudentModel.swift
//  HezeDemo
//
//  Created by Yuu Zheng on 2019/9/10.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import Heze

class StudentModel: HezeModel {

    var name = HezeModelField(name: "NAME", type: .string, length: 10)
    var age = HezeModelField(name: "AGE", type: .int)

    override func registerFields() -> [HezeModelField] {
        return [
            name, age
        ]
    }

    override var customFields: [HezeModelSimpleField : Any] {
        return [
            "isAdult": age.intValue >= 18
        ]
    }
}
