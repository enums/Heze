//
//  HezeSocketClient.swift
//  Heze
//
//  Created by Yuu Zheng on 2022/1/1.
//

import Foundation
import PerfectWebSockets

open class HezeSocketClient: HezeSocketHandler {

    open override var socketProtocol: String? {
        return nil
    }

    public var isConnected: Bool {
        return socket?.isConnected ?? false
    }

    open override func receiveBytes(_ bytes: [UInt8]) -> HezeResponsable? {
        return nil
    }

    public func sendMessage(_ msg: String) {
        socket?.sendStringMessage(string: msg, final: true) { }
    }

    public func sendBytes(_ bytes: [UInt8]) {
        socket?.sendBinaryMessage(bytes: bytes, final: true) { }
    }

    public func close() {
        socket?.close()
    }

    open override func connected() {

    }

    open override func closed() {

    }
}
