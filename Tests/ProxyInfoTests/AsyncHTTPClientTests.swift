import XCTest
import ProxyInfo
import AsyncHTTPClient
import AsyncHTTPClientProxy

final class AsyncHTTPClientTests: XCTestCase {

  func testIP() throws {
    let proxy: HTTPClient.Configuration.Proxy? = .environment(.init(parseUppercaseKey: true))
    print("using proxy: \(String(describing: proxy))")
    let http = HTTPClient(eventLoopGroupProvider: .singleton, configuration: .init(proxy: proxy))
    defer {
      try! http.syncShutdown()
    }
    func bodyString(url: String) throws -> String {
      let body = try XCTUnwrap(try http.get(url: url).wait().body)
      return try XCTUnwrap(body.getString(at: body.readerIndex, length: body.readableBytes))
    }
    print("ipv4: \(try bodyString(url: "https://api-ipv4.ip.sb/ip"))")
    print("ipv6: \(try bodyString(url: "https://api-ipv6.ip.sb/ip"))")

  }

}
