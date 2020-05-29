//
//  HezeSignalTrap.swift
//  Heze
//
//  Created by Yuu Zheng on 2020/5/29.
//

import Foundation

public typealias HezeSignal = Int32
public typealias HezeSignalHandler = @convention(c) (Int32) -> (Void)

public class HezeSignalTrap {

    public static var shared = HezeSignalTrap()
    private init() { }

    public var dispatchQueue = DispatchQueue(label: "signal_trap")

    public func trap(signal: HezeSignal, handler: @escaping HezeSignalHandler) {
        var signalAction = sigaction(__sigaction_u: unsafeBitCast(handler, to: __sigaction_u.self), sa_mask: 0, sa_flags: 0)
        _ = withUnsafePointer(to: &signalAction) { actionPointer in
            sigaction(signal, actionPointer, nil)
        }
    }

}
