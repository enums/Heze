// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Heze",
    products: [
        .library(name: "Heze", targets: ["Heze"]),
        .library(name: "Virgo", targets: ["Virgo"]),
    ],
    dependencies: [
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git" , from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git" , from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git" , from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Crypto.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Markdown.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Session.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Session-MySQL.git", from: "3.0.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
    ],
    targets: [
        .target(name: "HezeDemo", dependencies: ["Heze"]),
        .target(name: "Heze", dependencies: ["PerfectHTTPServer",  "PerfectMustache", "PerfectCrypto", "PerfectMySQL", "PerfectCURL", "PerfectMarkdown", "PerfectSession", "PerfectSessionMySQL", "Rainbow", "Virgo"]),
        .target(name: "Virgo", dependencies: ["Rainbow"]),
    ]
)
