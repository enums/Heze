//
//  HezePath.swift
//  Heze
//
//  Created by enum on 2019/8/4.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation

public struct HezePath {

    public var name: String

    public var excPath: String {
        return "\(HezeEnv.productPath)/\(name)"
    }

    public var workspacePath: String {
        return "\(HezeEnv.sourcePath)/Workspace/\(name)"
    }

    public var viewPath: String {
        return "\(workspacePath)/Views"
    }

    public var publicPath: String {
        return "\(workspacePath)/Public"
    }

    public var runtimePath: String {
        return "\(workspacePath)/Runtime"
    }

    public init(name: String) {
        self.name = name
    }
}
