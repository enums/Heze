//
//  SPCPage.swift
//  SPiCa
//
//  Created by enum on 2019/8/3.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation

public struct VirgoEnvConfig {

    public var username: String
    public var xcodeFolderName: String

    public var macSourcePath: String
    public var linuxSourcePath: String

    public init(username: String,
                xcodeFolderName: String,
                macSourcePath: String,
                linuxSourcePath: String) {
        self.username = username
        self.xcodeFolderName = xcodeFolderName
        self.macSourcePath = macSourcePath
        self.linuxSourcePath = linuxSourcePath
    }

}

public class VirgoEnv {

    public enum Device {
        case xcode
        case macos
        case linux
    }

    public static var host: Device {
        #if os(macOS)
        if debug {
            return .xcode
        } else {
            return .macos
        }
        #else
        return .linux
        #endif
    }

    public static var debug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    private static var config: VirgoEnvConfig?

    public static func configEnv(_ config: VirgoEnvConfig) {
        self.config = config
    }

    public static var username: String {
        guard let config = config else {
            VirgoLogger.shared.abort("Env is not configed.")
        }
        return config.username
    }

    public static var xcodePath: String {
        guard let config = config else {
            VirgoLogger.shared.abort("Env is not configed.")
        }
        return config.xcodeFolderName
    }

    public static var xcodeProductPath: String {
        return "/Users/\(username)/Library/Developer/Xcode/DerivedData/\(xcodePath)/Build/Products/Debug"
    }

    public static var sourcePath: String {
        guard let config = config else {
            VirgoLogger.shared.abort("Env is not configed.")
        }
        switch host {
        case .xcode, .macos:
            return config.macSourcePath
        case .linux:
            return config.linuxSourcePath
        }
    }

    public static var productPath: String {
        switch host {
        case .xcode, .macos, .linux:
            return "\(sourcePath)/.build/release"
        }
    }
    
}
