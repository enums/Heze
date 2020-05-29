//
//  Extensions.swift
//  Virgo
//
//  Created by Yuu Zheng on 2019/8/7.
//  Copyright © 2019 Yuu Zheng. All rights reserved.
//

import Foundation

fileprivate var dateFormatter = { () -> DateFormatter in
    let that = DateFormatter.init()
    that.timeZone = TimeZone.init(secondsFromGMT: 8 * 3600)
    that.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return that
}()

fileprivate var dayFormatter = { () -> DateFormatter in
    let that = DateFormatter.init()
    that.timeZone = TimeZone.init(secondsFromGMT: 8 * 3600)
    that.dateFormat = "yyyy-MM-dd"
    return that
}()

var dateWithSecondFormatter = { () -> DateFormatter in
    let that = DateFormatter.init()
    that.timeZone = TimeZone.init(secondsFromGMT: 8 * 3600)
    that.dateFormat = "yyyy-MM-dd HH:mm"
    return that
}()

public extension Date {
    var stringValue: String {
        return dateFormatter.string(from: self)
    }

    var stringValueWithoutSecond: String {
        get {
            return dateWithSecondFormatter.string(from: self)
        }
    }

    var dayStringValue: String {
        get {
            return dayFormatter.string(from: self)
        }
    }

    static var today: Date {
        get {
            let date = Date.init()
            let todayStr = dayFormatter.string(from: date)
            return dayFormatter.date(from: todayStr)!
        }
    }

    static var tomorrow: Date {
        return Date.init(timeInterval: 3600 * 24, since: today)
    }

    static var yestoday: Date {
        get {
            return Date.init(timeInterval: -3600 * 24, since: today)
        }
    }
}

public extension String {
    var dateValue: Date? {
        return dateFormatter.date(from: self)
    }
}

public extension Int {

    static func rand(_ to: Int) -> Int {
        #if os(Linux)
        return Int.random(in: 0..<to)
        #else
        return Int(arc4random()) % to
        #endif
    }
}

public extension Array {

    func rand() -> Element {
        return self[Int.rand(self.count)]
    }

}

public extension Decodable {

    static func read(from path: String) throws -> Self {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(self, from: data)
    }

    static func fromString(_ str: String) -> Self? {
        guard let data = str.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(self, from: data)
    }

}

public extension Encodable {

    func write(to path: String) throws {
        let data = try JSONEncoder().encode(self)
        try data.write(to: URL(fileURLWithPath: path))
    }

    func toString() -> String? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

