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

    open override func receiveBytes(_ bytes: [UInt8], completion: @escaping (HezeResponsable?) -> Void) {
        completion(nil)
    }

    open func close() {
        socket?.close()
    }

}
