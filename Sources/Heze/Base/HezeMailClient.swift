//
//  HezeMailClient.swift
//  Blog
//
//  Created by Yuu Zheng on 2019/8/29.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation
import PerfectSMTP

public class HezeMailClient: HezeObject {

    public var config: HezeMailConfig

    internal var client: SMTPClient
    internal var recipient: Recipient

    internal var queue = DispatchQueue.init(label: "mail")

    public init(config: HezeMailConfig) {
        self.config = config
        client = SMTPClient.init(url: config.smtp, username: config.username, password: config.password)
        recipient = Recipient.init(name: config.name, address: config.username)
    }

    public required init() {
        HezeLogger.shared.abort("Cannot init db without config")
    }

    public func send(title: String, content: String, to: (name: String, addr: String)) {
        let interval = config.interval
        queue.async {
            self.realSend(title: title, content: content, to: to)
            Thread.sleep(forTimeInterval: interval)
        }
    }

    private func realSend(title: String, content: String, to: (name: String, addr: String)) {
        let email = EMail.init(client: client)
        email.subject = base64Encoded(title) ?? title
        email.from = recipient
        email.html = content
        email.to.append(Recipient.init(name: to.name, address: to.addr))

        do {
            try email.send()
        } catch (let e) {
            HezeLogger.shared.error("Failed send email to \(to.name) at \(to.addr). \(e)")
        }
    }

    private func base64Encoded(_ str: String) -> String? {
        if let data = str.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
}
