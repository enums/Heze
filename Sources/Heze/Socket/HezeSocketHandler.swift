//
//  HezeSocketHandler.swift
//  Heze
//
//  Created by Yuu Zheng on 2022/1/1.
//

import Foundation
import PerfectHTTP
import PerfectWebSockets

open class HezeSocketHandler: HezeHandler, WebSocketSessionHandler {

    public var socket: WebSocket? = nil
    public var buffer = [UInt8]()

    open var socketProtocol: String? {
        return nil
    }

    open class func create(context: HezeContext = .main) -> HezeSocketHandler? {
        #if os(macOS)
        let instance = Self.init()
        #else
        let instance = self.init()
        #endif
        instance.bindContext(context)
        return instance
    }

    open override func handleThenComplete(_ req: HTTPRequest, _ res: HTTPResponse) {
        request = req
        defer {
            request = nil
        }
        guard requestVaild() else {
            handleInvaild(req, res)
            return
        }
        WebSocketHandler(handlerProducer: { (request, protocols) in
            if let socketProtocol = self.socketProtocol {
                guard protocols.contains(socketProtocol) else {
                    return nil
                }
                #if os(macOS)
                return Self.create(context: self.context)
                #else
                return type(of: self).create(context: self.context)
                #endif
            } else {
                #if os(macOS)
                return Self.create(context: self.context)
                #else
                return type(of: self).create(context: self.context)
                #endif
            }
        }).handleRequest(request: req, response: res)
    }

    open func handleSession(request req: HTTPRequest, socket: WebSocket) {
        if self.socket != socket {
            self.socket = socket
            connected()
        }
        socket.readBytesMessage { [weak self] bytes, opcodeType, final in
            guard let self = self else {
                return
            }
            guard let bytes = bytes else {
                socket.close()
                self.closed()
                return
            }
            if let bytes = self.handleBytes(bytes, opcodeType: opcodeType, final: final, socket: socket)?.toBytes() {
                self.sendBytes(bytes) {
                    self.handleSession(request: req, socket: socket)
                }
            } else {
                self.handleSession(request: req, socket: socket)
            }
        }
    }

    open func handleBytes(_ bytes: [UInt8], opcodeType: WebSocket.OpcodeType, final: Bool, socket: WebSocket) -> HezeResponsable? {
        buffer.append(contentsOf: bytes)
        if final {
            defer {
                buffer.removeAll(keepingCapacity: false)
            }
            return receiveBytes(buffer)
        } else {
            return nil
        }
    }

    open func receiveBytes(_ bytes: [UInt8]) -> HezeResponsable? {
        return nil
    }

    open func sendMessage(_ msg: String, completion: @escaping () -> Void) {
        sendBytes([UInt8](msg.utf8), completion: completion)
    }

    open func sendBytes(_ bytes: [UInt8], completion: @escaping () -> Void) {
        socket?.sendBinaryMessage(bytes: bytes, final: true, completion: completion)
    }

    open func connected() {

    }

    open func closed() {

    }
}
