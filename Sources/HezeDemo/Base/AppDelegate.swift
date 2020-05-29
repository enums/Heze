//
//  AppDelegate.swift
//  HezeDemo
//
//  Created by Yuu Zheng on 2019/9/10.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import Heze
import PerfectHTTP

class AppDelegate: HezeAppDelegate {

    var name: String {
        return "HezeDemo"
    }

    var context: HezeContext {
        return .main
    }

    required init() { }

    func registerModels() -> [HezeMetaModel] {
        return [
            StudentModel.meta
        ]
    }

    func registerPlugins() -> [HezeMetaPlugin] {
        return [
            CounterTimer.meta,
            NotFoundFilter.meta
        ]
    }

    func beforeBoot() throws {
        HezeSignalTrap.shared.trap(signal: SIGINT) { _ in
            HezeLogger.shared.info("interrupted")
            exit(0)
        }
    }

    func registerViews() -> [HezeHandlerPath: [HTTPMethod: HezeMetaHandler]] {

        return [
            HezeHandlerPathDefault: [
                .get: IndexView.meta
            ],

            "student": [
                .get: StudentListView.meta,
                .post: StudentAddApi.meta,
            ]
        ]
    }
}

