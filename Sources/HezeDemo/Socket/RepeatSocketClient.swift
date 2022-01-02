//
//  RepeatSocketClient.swift
//  HezeDemo
//
//  Created by Yuu Zheng on 2022/1/1.
//

import Foundation
import Heze

var RepeatSocketClientStorage: HezeSocketHandler?

class RepeatSocketClient: HezeSocketClient {

    open override func receiveBytes(_ bytes: [UInt8], completion: @escaping (HezeResponsable?) -> Void) {
        completion(bytes)
    }

    override class func create(context: HezeContext) -> HezeSocketHandler? {
        if RepeatSocketClientStorage == nil {
            RepeatSocketClientStorage = super.create(context: context)
        }
        return RepeatSocketClientStorage
    }
}
