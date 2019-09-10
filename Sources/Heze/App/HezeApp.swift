//
//  HezeApp.swift
//  Heze
//
//  Created by Yuu Zheng on 2019/8/1.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import PerfectHTTP
import PerfectHTTPServer
import PerfectMySQL
import PerfectSession
import PerfectSessionMySQL

public struct HezeAppConfig: Codable {
    public var port: Int
    public var mysql: HezeMySQLConfig?
    public var session: HezeSessionConfig?
    public var mail: HezeMailConfig?
    public var extra: [String: String]?
}

public struct HezeSessionConfig: Codable {
    public var name: String
    public var idle: Int
    public var table: String
}

public struct HezeMailConfig: Codable {
    public var smtp: String
    public var username: String
    public var password: String
    public var name: String
    public var interval: TimeInterval
}

public class HezeApp: HezeObject {

    public let queue = DispatchQueue(label: className)

    public let delegate: HezeAppDelegate

    public let server: HTTPServer
    public let database: HezeDatabase?
    public let mailClient: HezeMailClient?

    public var views = [HezeHandler]()
    public var models = [HezeMetaModel]()
    public var plugins = [HezeMetaPlugin]()

    public init(delegate: HezeAppDelegate) throws {

        HezeLogger.shared.info("App configuring...")

        self.delegate = delegate

        let path = HezePath(name: delegate.name)

        let config: HezeAppConfig = try HezeAppConfig.read(from: "\(path.workspacePath)/config.json")

        database = {
            if let mysql = config.mysql {
                let impl = HezeMySQLDatabase(config: mysql)
                impl.bindContext(delegate.context)

                let db = HezeDatabase(impl: impl)
                db.bindContext(delegate.context)

                guard db.connect() else {
                    HezeLogger.shared.abort("Connect database failed!")
                }

                HezeLogger.shared.info("Database configured.")
                return db
            } else {
                HezeLogger.shared.info("Skip database configuration.")
                return nil
            }
        }()

        if let mysql = config.mysql, let sesion = config.session {

            SessionConfig.name = sesion.name
            SessionConfig.idle = sesion.idle

            MySQLSessionConnector.table = sesion.table
            MySQLSessionConnector.host = mysql.ip
            MySQLSessionConnector.port = mysql.port
            MySQLSessionConnector.username = mysql.username
            MySQLSessionConnector.password = mysql.password
            MySQLSessionConnector.database = mysql.database

        }

        mailClient = {
            if let mail = config.mail {
                let client = HezeMailClient(config: mail)
                client.bindContext(delegate.context)
                return client
            } else {
                return nil
            }
        }()

        server = {
            let server = HTTPServer()
            server.documentRoot = path.publicPath
            server.serverPort = UInt16(config.port)

            return server
        }()

        super.init()

        bindContext(delegate.context)
        context.app = self
        context.path = path
        context.config = config
        context.server = server
        context.database = database
        context.mail = mailClient
        context.session = SessionMySQLDriver()

        let modelCache = HezeModelCacheCenter()
        modelCache.bindContext(context)
        context.modelCache = modelCache

        registerModels()
        registerViews()
        registerPlugins()

        if let ssl = delegate.registerSSL() {
            server.ssl = (ssl.0, ssl.1)
        }

        HezeLogger.shared.info("App configured.")
    }

    public required init() {
        HezeLogger.shared.abort("Cannot init app without delegate.")
    }

    private func registerViews() {
        var routes = [Route]()
        delegate.registerViews().forEach { (arg) in
            let (path, pair) = arg
            routes += pair.compactMap { (arg) in
                let (method, handler) = arg
                handler.bindContext(context)
                return Route(method: method, uri: path, handler: handler.handleThenComplete)
            }
        }
        server.addRoutes(Routes(routes))
        HezeLogger.shared.info("\(routes.count) routes have been registered.")
    }

    private func registerPlugins() {
        plugins.forEach {
            $0.unbindContext()
        }
        plugins = delegate.registerPlugins()

        let requestFilter = plugins.compactMap { $0 as? HezeRequestFilter }

        server.setRequestFilters(requestFilter.map {
            $0.bindContext(context)
            return ($0, $0.priority)
        })

        HezeLogger.shared.info("\(requestFilter.count) request filters have been registered.")

        let responseFilter = plugins.compactMap { $0 as? HezeResponseFilter }
        
        server.setResponseFilters(responseFilter.map {
            $0.bindContext(context)
            return ($0, $0.priority)
        })
        HezeLogger.shared.info("\(responseFilter.count) response filters have been registered.")
    }

    private func registerModels() {
        guard let db = database else {
            return
        }
        if !db.isDatabaseExist() {
            HezeLogger.shared.info("Database `\(db.impl.database)` not exist. Create it.")
            guard db.createDatabase() else {
                HezeLogger.shared.abort("Create database `\(db.impl.database)` failed!")
            }
            HezeLogger.shared.info("Database `\(db.impl.database)` created.")
        }
        models.forEach {
            $0.unbindContext()
        }
        models = delegate.registerModels()
        models.forEach { model in
            model.bindContext(context)
            model.bindSelf()
            if !db.isTableExist(for: model) {
                HezeLogger.shared.info("Table `\(model.table)` not exist. Create it.")
                guard db.createTable(for: model) else {
                    HezeLogger.shared.abort("Create table `\(model.table)` failed!")
                }
                HezeLogger.shared.info("Table `\(model.table)` created.")
            }
        }
    }

    private func beforeBoot() throws {
        plugins.forEach {
            $0.bindContext(context)
            $0.boot()
        }

        HezeLogger.shared.info("\(plugins.count) plugin have been booted.")

        try delegate.beforeBoot()
    }

    public func boot() throws {
        try beforeBoot()
        try server.start()
    }

    public func asyncBoot(catchError: ((Error) -> Void)? = nil) throws {
        try beforeBoot()
        queue.async {
            do {
                try self.server.start()
            } catch let(e) {
                catchError?(e)
            }
        }
    }
    
    public static func createAndBoot(with delegate: HezeAppDelegate,
                                     async: Bool = false) {
        do {
            let app = try HezeApp(delegate: delegate)
            if async {
                try app.asyncBoot()
            } else {
                try app.boot()
            }
        } catch (let e) {
            HezeLogger.shared.abort("Server aborted! Error: \(e)")
        }
    }
}
