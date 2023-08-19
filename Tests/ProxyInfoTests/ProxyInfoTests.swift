import XCTest
import ProxyInfo

enum ProxyEnvironmentKey: String {
  case http = "http_proxy"
  case https = "https_proxy"
  case all = "all_proxy"
}

final class ProxyInfoTests: XCTestCase {
  // MARK: URLSession
  func testURLSessionProxy() {
    #if os(macOS)
    let configuration = URLSessionConfiguration.default
    let host = "localhost"
    let port = 80

    func reset() {
      configuration.connectionProxyDictionary = nil
    }

    func checkSetting(_ type: ProxyType, ok: Bool = true) {
      if ok {
        switch type {
        case .http:
          XCTAssertEqual(configuration.connectionProxyDictionary![kCFNetworkProxiesHTTPEnable] as! Bool, true)
          XCTAssertEqual(configuration.connectionProxyDictionary![kCFNetworkProxiesHTTPProxy] as! String, host)
          XCTAssertEqual(configuration.connectionProxyDictionary![kCFNetworkProxiesHTTPPort] as! Int, port)
        case .https:
          XCTAssertEqual(configuration.connectionProxyDictionary![kCFNetworkProxiesHTTPSEnable] as! Bool, true)
          XCTAssertEqual(configuration.connectionProxyDictionary![kCFNetworkProxiesHTTPSProxy] as! String, host)
          XCTAssertEqual(configuration.connectionProxyDictionary![kCFNetworkProxiesHTTPSPort] as! Int, port)
        case .socks4, .socks4Hostname, .socks5, .socks5Hostname:
          XCTAssertEqual(configuration.connectionProxyDictionary![kCFNetworkProxiesSOCKSEnable] as! Bool, true)
          XCTAssertEqual(configuration.connectionProxyDictionary![kCFNetworkProxiesSOCKSProxy] as! String, host)
          XCTAssertEqual(configuration.connectionProxyDictionary![kCFNetworkProxiesSOCKSPort] as! Int, port)
        }
      } else {
        switch type {
        case .http:
          XCTAssertNil(configuration.connectionProxyDictionary?[kCFNetworkProxiesHTTPEnable])
          XCTAssertNil(configuration.connectionProxyDictionary?[kCFNetworkProxiesHTTPProxy])
          XCTAssertNil(configuration.connectionProxyDictionary?[kCFNetworkProxiesHTTPPort])
        case .https:
          XCTAssertNil(configuration.connectionProxyDictionary?[kCFNetworkProxiesHTTPSEnable])
          XCTAssertNil(configuration.connectionProxyDictionary?[kCFNetworkProxiesHTTPSProxy])
          XCTAssertNil(configuration.connectionProxyDictionary?[kCFNetworkProxiesHTTPSPort])
        case .socks4, .socks4Hostname, .socks5, .socks5Hostname:
          XCTAssertNil(configuration.connectionProxyDictionary?[kCFNetworkProxiesSOCKSEnable])
          XCTAssertNil(configuration.connectionProxyDictionary?[kCFNetworkProxiesSOCKSProxy])
          XCTAssertNil(configuration.connectionProxyDictionary?[kCFNetworkProxiesSOCKSPort])
        }
      }

    }

    configuration.disableProxy()

    XCTAssertNotNil(configuration.connectionProxyDictionary)
    XCTAssertFalse(configuration.connectionProxyDictionary![kCFNetworkProxiesHTTPEnable] as! Bool)
    XCTAssertFalse(configuration.connectionProxyDictionary![kCFNetworkProxiesHTTPSEnable] as! Bool)
    XCTAssertFalse(configuration.connectionProxyDictionary![kCFNetworkProxiesSOCKSEnable]  as! Bool)

    reset()
    configuration.set(proxyInfo: ProxyInfo(type: .http, host: host, port: port))
    checkSetting(.http)

    reset()
    configuration.set(proxyInfo: ProxyInfo(type: .https, host: host, port: port))
    checkSetting(.https)

    reset()
    configuration.set(proxyInfo: ProxyInfo(type: .socks5, host: host, port: port))
    checkSetting(.socks5)

    reset()
    let allSocks5Environment = [
      ProxyEnvironmentKey.all.rawValue : "socks5://\(host):\(port)"
    ]
    configuration.setProxy(environment: allSocks5Environment)
    checkSetting(.socks5)

    reset()
    let allUppercasedSocks5Environment = [
      ProxyEnvironmentKey.all.rawValue.uppercased() : "socks5://\(host):\(port)"
    ]
    configuration.setProxy(environment: allUppercasedSocks5Environment, parseUppercaseKey: true)
    checkSetting(.socks5)

    reset()
    let allNoSchemeEnvironment = [
      ProxyEnvironmentKey.all.rawValue : "\(host):\(port)"
    ]
    configuration.setProxy(environment: allNoSchemeEnvironment)
    checkSetting(.http, ok: false)

    reset()
    let allInvalidSchemeEnvironment = [
      ProxyEnvironmentKey.all.rawValue : "invalid://\(host):\(port)"
    ]
    configuration.setProxy(environment: allInvalidSchemeEnvironment)
    checkSetting(.http, ok: false)

    reset()
    let allHttpEnvironment = [
      ProxyEnvironmentKey.all.rawValue : "http://\(host):\(port)"
    ]
    configuration.setProxy(environment: allHttpEnvironment)
    checkSetting(.http)


    reset()
    let httpAndHttpsEnvironment = [
      ProxyEnvironmentKey.http.rawValue : "http://\(host):\(port)",
      ProxyEnvironmentKey.https.rawValue : "http://\(host):\(port)"
    ]
    configuration.setProxy(environment: httpAndHttpsEnvironment)
    checkSetting(.https)
    checkSetting(.http)

    reset()
    let httpUseSocks5Environment = [
      ProxyEnvironmentKey.http.rawValue : "socks5://\(host):\(port)"
    ]
    configuration.setProxy(environment: httpUseSocks5Environment)
    checkSetting(.socks5)

    reset()
    let httpsUseSocks5Environment = [
      ProxyEnvironmentKey.https.rawValue : "socks5://\(host):\(port)"
    ]
    configuration.setProxy(environment: httpsUseSocks5Environment)
    checkSetting(.socks5)
    #endif
  }
}
