//
//  HezeAppDelegate.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/2.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import PerfectHTTP

public protocol HezeAppDelegate {

    var name: String { get }

    var context: HezeContext { get }

    init()

    func registerSSL() -> (String, String)?

    func registerPlugins() -> [HezeMetaPlugin]

    func registerModels() -> [HezeMetaModel]

    func registerViews() -> [HezeHandlerPath: [HTTPMethod: HezeMetaHandler]]

    func beforeBoot() throws

}

public extension HezeAppDelegate {

    func registerSSL() -> (String, String)? {
        return nil
    }

    func registerPlugins() -> [HezeMetaPlugin] {
        return []
    }

    func registerModels() -> [HezeMetaModel] {
        return []
    }

    func registerViews() -> [HezeHandlerPath: [HTTPMethod: HezeMetaHandler]] {
        return [:]
    }

    func beforeBoot() throws {

    }

}
