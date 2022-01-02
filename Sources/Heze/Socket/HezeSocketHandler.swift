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
    public var remoteHost: String?
    public var remotePort: UInt16?
    public var queue = DispatchQueue(label: "heze.socket.handler")
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
            let handler: HezeSocketHandler?
            if let socketProtocol = self.socketProtocol {
                guard protocols.contains(socketProtocol) else {
                    return nil
                }
                #if os(macOS)
                handler = Self.create(context: self.context)
                #else
                handler = type(of: self).create(context: self.context)
                #endif
            } else {
                #if os(macOS)
                handler = Self.create(context: self.context)
                #else
                handler = type(of: self).create(context: self.context)
                #endif
            }
            handler?.remoteHost = req.remoteAddress.host
            handler?.remotePort = req.remoteAddress.port
            return handler
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

            switch opcodeType {
            case .binary, .text, .continuation:
                guard let bytes = bytes else {
                    socket.close()
                    self.closed()
                    return
                }
                self.queue.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.handleBytes(bytes, opcodeType: opcodeType, final: final, socket: socket) { res in
                        if let bytes = res?.toBytes() {
                            self.sendBytes(bytes) { }
                        }
                    }
                }
            case .ping:
                self.ping()
            case .pong:
                self.pong()
            case .close, .invalid:
                socket.close()
                self.closed()
                return
            }

            self.handleSession(request: req, socket: socket)
        }
    }

    open func handleBytes(_ bytes: [UInt8], opcodeType: WebSocket.OpcodeType, final: Bool, socket: WebSocket, completion: @escaping (HezeResponsable?) -> Void) {
        buffer.append(contentsOf: bytes)
        if final {
            receiveBytes(buffer) { [weak self] in
                guard let self = self else {
                    completion($0)
                    return
                }
                self.buffer.removeAll(keepingCapacity: false)
                completion($0)
            }
        } else {
            completion(nil)
        }
    }

    open func receiveBytes(_ bytes: [UInt8], completion: @escaping (HezeResponsable?) -> Void) {
        completion(nil)
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

    open func ping() {

    }

    open func pong() {

    }
}
