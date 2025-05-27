// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "ProxyInfo",
  products: [
    .library(name: "ProxyInfo", targets: ["ProxyInfo"]),
    .library(name: "AsyncHTTPClientProxy", targets: ["AsyncHTTPClientProxy"]),
  ],
  dependencies: [
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.4.0"),
  ],
  targets: [
    .target(name: "ProxyInfo"),
    .target(
      name: "AsyncHTTPClientProxy",
      dependencies: [
        "ProxyInfo",
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
      ]),
    .testTarget(
      name: "ProxyInfoTests",
      dependencies: [
        "ProxyInfo",
        "AsyncHTTPClientProxy",
      ]),
  ]
)
